// Copyright © 2019 DexCare. All rights reserved.

import Foundation

struct VirtualFeedbackRequest: Encodable {
    let appId: String
    let appVersion: String
    let appHostEnvironment: String
    let userIdentifier: String
    let conferenceId: String
    let conferenceSessionId: String
    let userDisplayName: String
    let userRole: String
    let startTime: String
    let endTime: String
    let feedbacks: [VirtualFeedbackQuestion]
}

struct VirtualFeedbackQuestion: Encodable, Equatable {
    let id: String
    let text: String
    let type: String
    let answers: [VirtualFeedbackAnswer]
}

struct VirtualFeedbackAnswer: Encodable, Equatable {
    let id: String
    let text: String
    let type: String
    let value: String
}

/// An enum that represents a type of feedback this is supported.
/// A different question string can be passed in. If not, a default question is saved
@frozen
public enum VirtualFeedback {
    /// A rating integer feedback, with a 0-10 scale.
    /// The default question is `"On a scale of 0-10, how likely are you to recommend ExpressCare Virtual to a friend or family? 0 - not likely at all, 10 - extremely likely"` see `defaultQuestionString`
    case rating(question: String?, rating: Int)
    /// A feedback open string response
    /// The default question is `"In your own words, tell us how we did"` see `defaultQuestionString`
    case feedback(question: String?, answer: String)
    /// A follow up boolean response
    /// The default question is `"May we contact you to follow-up on your experience?"` see `defaultQuestionString`
    case followUp(question: String?, answer: Bool)

    /// The default questions that are used if no question is filled in each case
    public var defaultQuestionString: String {
        switch self {
        case .rating:
            return "On a scale of 0-10, how likely are you to recommend this service to a friend or family? 0 - not likely at all, 10 - extremely likely"
        case .feedback:
            return "In your own words, tell us how we did"
        case .followUp:
            return "May we contact you to follow-up on your experience?"
        }
    }

    var questionKey: String {
        switch self {
        case .rating:
            return "rating"
        case .feedback:
            return "feedback"
        case .followUp:
            return "followUp"
        }
    }

    var answerKey: String {
        switch self {
        case .rating:
            return "ratingAnswer"
        case .feedback:
            return "feedbackAnswer"
        case .followUp:
            return "followUpAnswer"
        }
    }

    var type: String {
        switch self {
        case .rating:
            return "number"
        case .feedback:
            return "string"
        case .followUp:
            return "boolean"
        }
    }

    var questionString: String {
        switch self {
        case let .rating(question, _):
            return question ?? defaultQuestionString
        case let .feedback(question, _):
            return question ?? defaultQuestionString
        case let .followUp(question, _):
            return question ?? defaultQuestionString
        }
    }

    var answerString: String {
        switch self {
        case let .rating(_, rating):
            return "\(rating)"
        case let .feedback(_, answer):
            return answer
        case let .followUp(_, answer):
            return "\(answer ? "true" : "false")"
        }
    }

    func toVirtualFeedbackQuestion() -> VirtualFeedbackQuestion {
        return VirtualFeedbackQuestion(id: self.questionKey, text: questionString, type: self.type, answers: [
            VirtualFeedbackAnswer(id: self.answerKey, text: .empty, type: self.type, value: answerString),
        ])
    }

    func validate() throws {
        guard case let .rating(question, rating) = self else {
            // only handling rating
            return
        }

        if (question ?? "empty").isEmpty {
            throw "Question is missing some text for rating"
        }
        if !((0 ... 10) ~= rating) {
            throw "Rating needs to be between 0 and 10"
        }
    }
}

extension VirtualFeedbackRequest {
    init(patientId: String, startTime: Date?, endTime: Date?, feedbacks: [VirtualFeedback]) {
        let convertedFeedbacks = feedbacks.map { $0.toVirtualFeedbackQuestion() }

        self.init(
            appId: Bundle.main.bundleIdentifier ?? "N/A",
            appVersion: DexcareAppVersion.versionWithBuild,
            appHostEnvironment: "iOS",
            userIdentifier: patientId,
            // Use for web only atm and will be removed in a later api version
            // ------------------
            conferenceId: .empty,
            conferenceSessionId: .empty,
            userDisplayName: .empty,
            // ------------------
            userRole: "patient",
            startTime: startTime?.asUTCString() ?? .empty,
            endTime: endTime?.asUTCString() ?? .empty,
            feedbacks: convertedFeedbacks
        )
    }
}
