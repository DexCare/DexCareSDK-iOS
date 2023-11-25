import Foundation

enum TechCheckValue: String, Codable {
    case pass
    case fail
}
/// A Struct to send up when the local device passes it's tech checks.
struct VirtualTechCheck: Codable {
    let status: TechCheckValue
    let camStatus: TechCheckValue
    let micStatus: TechCheckValue
    let networkStatus: TechCheckValue
    let mediaPermissionStatus: TechCheckValue
    
    init() {
        status = .pass
        camStatus = .pass
        micStatus = .pass
        networkStatus = .pass
        mediaPermissionStatus = .pass
    }
    
    init(withPermissions permissions: Permissions) {
        // assume true since we can't really check it.
        networkStatus = .pass
        mediaPermissionStatus = .pass
        
        camStatus = (permissions.camera == .granted) ? .pass : .fail
        micStatus = (permissions.microphone == .granted) ? .pass : .fail
        
        status = permissions.granted ? .pass : .fail
    }
}

struct WaitingRoomEventsRequest: Codable {
    let techCheck: VirtualTechCheck
}
