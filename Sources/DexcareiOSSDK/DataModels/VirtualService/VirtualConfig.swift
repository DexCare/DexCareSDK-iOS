import Foundation

/// Contains various values that are optionally customizable, and are specific to the Virtual Visit experience.
public struct VirtualConfig: Equatable {
    /// Whether or not to display a YouTube video on the virtual waiting room screen.
    /// Defaults to true
    public var showWaitingRoomVideo: Bool?

    /**
     The local url for the video that is shown in the waiting room
     File must be a type that can be played with `AVPlayerItem`, usually mp4
     Videos with 640x360 resolution/aspect ratio play best. Remember, this is on a device, and high resolution videos are not needed.
     ~~~
     // Load URL from an embedded mp4 file in your app
     videoURL = Bundle.main.url(forResource: "waitingRoom", withExtension: "mp4")
     ~~~

     */
    public var waitingRoomVideoURL: URL?

    /// Initializes the VirtualConfig options
    /// - Parameters:
    ///   - showWaitingRoomVideo: Shows the waiting room video at the top of the view. Defaults to **true**
    ///   - waitingRoomVideoURL: a local url of the video that is displayed. If nil - will show DexCare's welcome video
    public init(showWaitingRoomVideo: Bool? = true, waitingRoomVideoURL: URL? = nil) {
        self.showWaitingRoomVideo = showWaitingRoomVideo
        self.waitingRoomVideoURL = waitingRoomVideoURL
    }
}
