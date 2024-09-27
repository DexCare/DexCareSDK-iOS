import Foundation

// A configuration object containing information used to show and setup the tytocare integration
public struct TytoCareConfig: Equatable {
    /// a url that is shown on the main view when setting up Tytocare. This allows a user to click on the link for more information.
    public let helpURL: URL?
    // there might be more later

    public init(helpURL: URL?) {
        self.helpURL = helpURL
    }
}
