// Copyright © 2019 DexCare. All rights reserved.

import Foundation
import InputBarAccessoryView
import MessageKit
import UIKit

protocol ExternalLinkHandler {
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?)
}

extension UIApplication: ExternalLinkHandler {}

protocol ChatView: AnyObject {
    var manager: VirtualVisitManagerType? { get set }
    var navigationTitle: String? { get set }

    func remoteTypingStarted()
    func remoteTypingStopped()
    func refresh(chatMessages: [ChatMessage])
}

class ChatViewController: MessagesViewController, ChatView {
    weak var manager: VirtualVisitManagerType?
    private var serverLogger: LoggingService?
    lazy var linkHandler: ExternalLinkHandler = UIApplication.shared

    // Add a small (but not too big) delay on when to refresh the collection view or typing state
    // We cancel any previous request if the next one comes in before the delay
    // We do need it to be quick enough so we get some immediate feedback when typing in a new message
    // This delay has been added to throttle the cascade of messages that are received when a user resumes a visits
    // Since only the last message is needed in that scenario
    lazy var workItemDelay = 0.1
    var typingIndicatorWorkItem: DispatchWorkItem?
    var refreshWorkItem: DispatchWorkItem?

    var navigationTitle: String? {
        didSet {
            title = navigationTitle
        }
    }

    private let userSender: ChatSender
    var messages: [ChatMessage] = []
    private var previousMessageCount: Int = 0
    let semaphore = DispatchSemaphore(value: 1)

    private var isBannerDismissed = false
    private var headerView: UIView?
    private var headerHeightConstraint: NSLayoutConstraint?
    private var messagesTopToHeaderConstraint: NSLayoutConstraint?
    private var messagesTopToSafeAreaConstraint: NSLayoutConstraint?

    private static let botOptionsViewTag = 9001

    private var backBarButtonItem: UIBarButtonItem {
        // We create a custom back button to accomodate the fact that some implementation will
        // update the navigation tint color globally to white.
        // 'UINavigationBar.appearance().tintColor = .white'
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .link
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.link, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }

    init(
        manager: VirtualVisitManagerType,
        serverLogger: LoggingService?
    ) {
        self.manager = manager
        self.serverLogger = serverLogger
        userSender = ChatSender(id: manager.userId, displayName: manager.chatDisplayName)
        super.init(nibName: nil, bundle: nil)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeaderView()
        configureMessageCollectionView()
        configureMessageInputBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Removing this as HM has found a bug that puts the chat behind the nav bar, not showing a chat bubble when the keyboard shows.
        // messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    private func configureHeaderView() {
        let banner = UIView()
        banner.tag = 100
        banner.backgroundColor = .systemBlue
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.clipsToBounds = true

        let headerLabel = UILabel()
        headerLabel.text = localizeString("chatView_header_text")
        headerLabel.textColor = .white
        headerLabel.textAlignment = .justified
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.numberOfLines = 0
        headerLabel.lineBreakMode = .byWordWrapping

        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle(localizeString("chatView_banner_dismiss"), for: .normal)
        dismissButton.setTitleColor(.white, for: .normal)
        dismissButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: #selector(dismissBannerTapped), for: .touchUpInside)

        banner.addSubview(headerLabel)
        banner.addSubview(dismissButton)
        view.addSubview(banner)
        self.headerView = banner

        messagesCollectionView.removeFromSuperview()
        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messagesCollectionView)

        let topToHeader = messagesCollectionView.topAnchor.constraint(equalTo: banner.bottomAnchor)
        let topToSafeArea = messagesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        topToSafeArea.isActive = false
        self.messagesTopToHeaderConstraint = topToHeader
        self.messagesTopToSafeAreaConstraint = topToSafeArea

        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            headerLabel.topAnchor.constraint(equalTo: banner.topAnchor, constant: 8),
            headerLabel.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -16),

            dismissButton.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 4),
            dismissButton.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -16),
            dismissButton.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -8),

            topToHeader,
            messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messagesCollectionView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor)
        ])
    }

    @objc private func dismissBannerTapped() {
        guard !isBannerDismissed else { return }
        isBannerDismissed = true

        messagesTopToSafeAreaConstraint?.isActive = true
        messagesTopToHeaderConstraint?.isActive = false

        UIView.animate(withDuration: 0.3) {
            self.headerView?.alpha = 0
            self.headerView?.isHidden = true
            self.view.layoutIfNeeded()
        }
    }

    func configureMessageCollectionView() {
        // Trying a few things for HM where sometimes their messages go under their nav bar.
        self.edgesForExtendedLayout = []
        messagesCollectionView.clipsToBounds = true

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnInputBarHeightChanged = true

        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            assertionFailure("collectionViewLayout is NOT MessagesCollectionViewFlowLayout. Something has gone wrong.")
            return
        }

        let avatarSize = CGSize(width: 32, height: 32)
        layout.setMessageIncomingAvatarSize(avatarSize)
        layout.setMessageOutgoingAvatarSize(.zero)
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = avatarSize
        layout.textMessageSizeCalculator.incomingAvatarPosition = .init(vertical: .messageTop)

        let incomingEdge = layout.textMessageSizeCalculator.incomingMessagePadding
        let outgoingEdge = layout.textMessageSizeCalculator.outgoingMessagePadding

        layout.textMessageSizeCalculator.incomingMessageTopLabelAlignment.textInsets = incomingEdge
        layout.textMessageSizeCalculator.outgoingMessageTopLabelAlignment.textInsets = outgoingEdge
        layout.textMessageSizeCalculator.incomingMessageBottomLabelAlignment.textInsets = incomingEdge
        layout.textMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets = outgoingEdge
        layout.textMessageSizeCalculator.incomingCellBottomLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: incomingEdge)
        layout.textMessageSizeCalculator.outgoingCellBottomLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: outgoingEdge)
    }

    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .buttonColor
        messageInputBar.inputTextView.placeholder = localizeString("chatView_hint_emptyChat")
        messageInputBar.sendButton.setTitleColor(.buttonColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.buttonColor.withAlphaComponent(0.3),
            for: .highlighted
        )
        messageInputBar.sendButton.title = localizeString("chatView_button_send")
    }

    func shouldScrollToBottom() -> Bool {
        let lastIndexPath = IndexPath(item: 0, section: self.messages.count - 1)
        let isLastSectionVisible = messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
        return isLastSectionVisible || messagesCollectionView.indexPathsForVisibleItems.isEmpty
    }

    func remoteTypingStarted() {
        refreshTypingIndicator(shown: true)
    }

    func remoteTypingStopped() {
        refreshTypingIndicator(shown: false)
    }

    func refresh(chatMessages: [ChatMessage]) {
        // Cancel any existing workItem if there is any
        if let currentWorkItem = refreshWorkItem {
            currentWorkItem.cancel()
            refreshWorkItem = nil
        }

        // Dispatch the work item based on wall time
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            self.semaphore.wait()

            let messageCountChanged = chatMessages.count != self.previousMessageCount
            let shouldScrollToBottom = messageCountChanged || self.shouldScrollToBottom()

            self.setTypingIndicatorViewHidden(true, animated: false)
            self.previousMessageCount = chatMessages.count
            self.messages = chatMessages

            if shouldScrollToBottom {
                self.messagesCollectionView.reloadData()
                if !chatMessages.isEmpty {
                    self.messagesCollectionView.scrollToLastItem(animated: messageCountChanged)
                }
            } else {
                self.messagesCollectionView.reloadDataAndKeepOffset()
            }

            self.semaphore.signal()
        }
        refreshWorkItem = workItem
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + workItemDelay, execute: workItem)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func refreshTypingIndicator(shown: Bool) {
        // Cancel any existing workItem if there is any
        if let currentWorkItem = typingIndicatorWorkItem {
            currentWorkItem.cancel()
            typingIndicatorWorkItem = nil
        }

        // Dispatch the work item based on wall time
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            // don't do anything if we are already in the right state
            guard self.isTypingIndicatorHidden == shown else { return }

            self.semaphore.wait()

            self.setTypingIndicatorViewHidden(!shown, animated: false)
            if self.shouldScrollToBottom() {
                self.messagesCollectionView.scrollToLastItem()
            }

            self.semaphore.signal()
        }
        typingIndicatorWorkItem = workItem
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + workItemDelay, execute: workItem)
    }

    // MARK: - Bot Options

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)

        cell.contentView.viewWithTag(Self.botOptionsViewTag)?.removeFromSuperview()

        guard let chatMessage = messages[safe: indexPath.section],
              chatMessage.isBot,
              let options = chatMessage.botOptions,
              !options.isEmpty else {
            return cell
        }

        let optionsView = createBotOptionsView(
            options: options,
            isAnswered: chatMessage.botOptionSelected,
            messageId: chatMessage.messageId
        )
        optionsView.tag = Self.botOptionsViewTag
        optionsView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(optionsView)

        if let messageCell = cell as? TextMessageCell {
            NSLayoutConstraint.activate([
                optionsView.topAnchor.constraint(equalTo: messageCell.messageContainerView.bottomAnchor, constant: 6),
                optionsView.leadingAnchor.constraint(equalTo: messageCell.messageContainerView.leadingAnchor),
                optionsView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                optionsView.heightAnchor.constraint(equalToConstant: 36)
            ])
        }

        return cell
    }

    private func createBotOptionsView(options: [BotOptionUi], isAnswered: Bool, messageId: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8

        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option.label, for: .normal)
            button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            button.isEnabled = !isAnswered

            if option.primary {
                button.backgroundColor = .buttonColor
                button.setTitleColor(.white, for: .normal)
                button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
                if isAnswered {
                    button.backgroundColor = UIColor.buttonColor.withAlphaComponent(0.5)
                }
            } else {
                button.backgroundColor = .clear
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.buttonColor.cgColor
                button.setTitleColor(.buttonColor, for: .normal)
                button.setTitleColor(UIColor.buttonColor.withAlphaComponent(0.5), for: .disabled)
                if isAnswered {
                    button.layer.borderColor = UIColor.buttonColor.withAlphaComponent(0.5).cgColor
                }
            }

            button.addAction(UIAction { [weak self] _ in
                self?.manager?.sendBotOptionResponse(messageId: messageId, option: option)
            }, for: .touchUpInside)

            stack.addArrangedSubview(button)
        }

        return stack
    }
}

extension ChatViewController {
    func showingTopLabel(indexPath: IndexPath) -> Bool {
        guard
            let currentMessage = messages[safe: indexPath.section],
            let previousMessage = messages[safe: indexPath.section - 1]
        else {
            return true
        }

        return previousMessage.sender.senderId != currentMessage.sender.senderId
    }

    func showingBottomLabel(indexPath: IndexPath) -> Bool {
        guard
            let currentMessage = messages[safe: indexPath.section],
            let nextMessage = messages[safe: indexPath.section + 1],
            nextMessage.sender.senderId == currentMessage.sender.senderId
        else {
            return true
        }

        return currentMessage.sentDate.minutesFrom(nextMessage.sentDate) >= 1
    }
}

struct ChatSender: SenderType {
    var id: String
    var displayName: String
    var senderId: String { return id }
}

extension ChatViewController: MessagesDataSource {
    var currentSender: any MessageKit.SenderType {
        userSender
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        /// There is an issue where the message does not exit at the given index.
        /// Unfortunetly, we are unable to reproduce the issue.
        /// We added extra logs to track the issue and help us reproduce it.
        ///
        /// Internal Issue: ENG-11367
        ///
        /// Update July 22, 2024
        /// The above issue is caused when the user has minimized the app and is receiving messages.
        /// The issue can also be resolved by removing workItemDelay mechanism or revamping the chat throttling mechanism.
        /// Simply returning a empty chat message appears to have no ill effects (the empty chat mesasges do not appear).
        if let message = messages[safe: indexPath.section] {
            return message
        }
        serverLogger?.postMessage(message: "ChatViewController::messageForItem(at \(indexPath.section)) is out of range")
        return ChatMessage.empty
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func isFromCurrentSender(message: MessageType) -> Bool {
        return message.sender.senderId == userSender.id
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard showingTopLabel(indexPath: indexPath) else { return nil }
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.caption1])
    }

    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard showingBottomLabel(indexPath: indexPath) else { return nil }
        let dateString = message.sentDate.relativeTime(from: Date())
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.caption2])
    }
}

extension ChatViewController: MessageCellDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if let chatMessage = messages[safe: indexPath.section], chatMessage.isBot {
            avatarView.isHidden = false
            avatarView.image = UIImage(named: "ic_bot_avatar", in: .dexcareSDK, compatibleWith: nil)
        } else {
            avatarView.isHidden = true
            avatarView.image = nil
        }
    }

    func didSelectAddress(_ addressComponents: [String: String]) {
        let components = [
            addressComponents[NSTextCheckingKey.street.rawValue],
            addressComponents[NSTextCheckingKey.city.rawValue],
            addressComponents[NSTextCheckingKey.state.rawValue],
            addressComponents[NSTextCheckingKey.zip.rawValue],
        ]

        let addressText = components.compactMap { $0 }.joined(separator: ",").replacingOccurrences(of: " ", with: "+")
        guard let addressUrl = URL(string: "http://maps.apple.com/?address=\(addressText)") else { return }
        linkHandler.open(addressUrl, options: [:], completionHandler: nil)
    }

    func didSelectPhoneNumber(_ phoneNumber: String) {
        let numbers = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard let numberUrl = URL(string: "tel://" + numbers) else { return }
        linkHandler.open(numberUrl, options: [:], completionHandler: nil)
    }

    func didSelectURL(_ url: URL) {
        linkHandler.open(url, options: [:], completionHandler: nil)
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard showingTopLabel(indexPath: indexPath) else { return 0 }
        return UIFont.caption1.lineHeight + 10
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard let chatMessage = messages[safe: indexPath.section],
              chatMessage.isBot,
              let options = chatMessage.botOptions,
              !options.isEmpty else {
            return 0
        }
        return 48
    }

    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return showingBottomLabel(indexPath: indexPath) ? UIFont.caption2.lineHeight + 7 : 0
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        manager?.setUserIsTyping(false)
        manager?.sendChatMessage(text, selectedBotOption: nil, botPrompt: nil)
        messageInputBar.inputTextView.text = ""
    }

    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text.isNotEmpty {
            manager?.setUserIsTyping(true)
        } else {
            manager?.setUserIsTyping(false)
        }
    }
}

private extension UIFont {
    static var caption1 = UIFont.preferredFont(forTextStyle: .caption1)
    static var caption2 = UIFont.preferredFont(forTextStyle: .caption2)
}

extension ChatViewController: MessagesDisplayDelegate {
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .address, .phoneNumber, .url:
            return [.foregroundColor: UIColor.link]
        default: return MessageLabel.defaultAttributes
        }
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.address, .phoneNumber, .url]
    }
}

struct BotOptionUi {
    var label: String
    var value: String
    var primary: Bool

    init(label: String, value: String, primary: Bool = false) {
        self.label = label
        self.value = value
        self.primary = primary
    }
}

struct ChatMessage: MessageType {
    static var empty: Self = ChatMessage(sender: ChatSender(id: "", displayName: ""), messageId: "", sentDate: Date(), kind: .text(""))

    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var isBot: Bool = false
    var botOptions: [BotOptionUi]?
    var botOptionSelected: Bool = false
}

extension SignalInstantMessage {
    var asChatMessage: ChatMessage {
        return ChatMessage(
            sender: ChatSender(id: senderId ?? fromParticipant, displayName: fromParticipant),
            messageId: uniqueId,
            sentDate: creationTime,
            kind: .text(message),
            isBot: isBot,
            botOptions: botOptions?.map { BotOptionUi(label: $0.label, value: $0.value, primary: $0.primary) }
        )
    }
}
