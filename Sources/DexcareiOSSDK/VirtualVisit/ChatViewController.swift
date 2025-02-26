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
    let semaphore = DispatchSemaphore(value: 1)

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

        configureMessageCollectionView()
        configureMessageInputBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Removing this as HM has found a bug that puts the chat behind the nav bar, not showing a chat bubble when the keyboard shows.
        // messageInputBar.inputTextView.becomeFirstResponder()
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
        maintainPositionOnKeyboardFrameChanged = true

        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            assertionFailure("collectionViewLayout is NOT MessagesCollectionViewFlowLayout. Something has gone wrong.")
            return
        }

        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = .zero

        let incomingEdge = layout.textMessageSizeCalculator.incomingMessagePadding
        let outgoingEdge = layout.textMessageSizeCalculator.outgoingMessagePadding

        layout.textMessageSizeCalculator.incomingMessageTopLabelAlignment.textInsets = incomingEdge
        layout.textMessageSizeCalculator.outgoingMessageTopLabelAlignment.textInsets = outgoingEdge
        layout.textMessageSizeCalculator.incomingMessageBottomLabelAlignment.textInsets = incomingEdge
        layout.textMessageSizeCalculator.outgoingMessageBottomLabelAlignment.textInsets = outgoingEdge
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

            let shouldScrollToBottom = self.shouldScrollToBottom()

            self.setTypingIndicatorViewHidden(true, animated: false)
            self.messages = chatMessages

            if shouldScrollToBottom {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
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
    func currentSender() -> SenderType {
        return userSender
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

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard showingBottomLabel(indexPath: indexPath) else { return nil }
        let dateString = message.sentDate.relativeTime(from: Date())
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.caption2])
    }
}

extension ChatViewController: MessageCellDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
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
        guard showingBottomLabel(indexPath: indexPath) else { return 0 }
        return UIFont.caption2.lineHeight + 7
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        manager?.setUserIsTyping(false)
        manager?.sendChatMessage(text)
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

struct ChatMessage: MessageType {
    static var empty: Self = ChatMessage(sender: ChatSender(id: "", displayName: ""), messageId: "", sentDate: Date(), kind: .text(""))

    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

extension SignalInstantMessage {
    var asChatMessage: ChatMessage {
        return ChatMessage(
            sender: ChatSender(id: senderId ?? fromParticipant, displayName: fromParticipant),
            messageId: uniqueId,
            sentDate: creationTime,
            kind: .text(message)
        )
    }
}
