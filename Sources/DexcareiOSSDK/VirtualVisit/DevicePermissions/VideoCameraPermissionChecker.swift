// Copyright © 2018 DexCare. All rights reserved.

import AVFoundation
import Foundation

class VideoCameraPermissionChecker: VideoCameraPermissionChecking {
    func requestPermission() async -> RequestedPermissionStatus {
        return await withCheckedContinuation { (continuation: CheckedContinuation<RequestedPermissionStatus, Never>) in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted ? .granted : .denied)
            }
        }
    }
}
