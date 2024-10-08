// Copyright © 2018 DexCare. All rights reserved.

import AVFoundation
import Foundation

class MicrophonePermissionChecker: MicrophonePermissionChecking {
    func requestPermission() async -> RequestedPermissionStatus {
        return await withCheckedContinuation { (continuation: CheckedContinuation<RequestedPermissionStatus, Never>) in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted ? .granted : .denied)
            }
        }
    }
}
