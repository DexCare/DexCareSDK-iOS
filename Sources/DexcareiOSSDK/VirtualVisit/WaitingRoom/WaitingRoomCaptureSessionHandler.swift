// Copyright © 2019 DexCare. All rights reserved.

import Foundation
import AVKit

enum SessionSetupResult {
    case success
    case configurationFailed
}

protocol CaptureSessionHandler: AnyObject {
    var captureSession: AVCaptureSession { get }
    
    func configureAVCaptureSession(completion: @escaping () -> Void)
    func startCaptureSession()
    func stopCaptureSession()
}

// MARK: - Capture session handling
class WaitingRoomCaptureSessionHandler: CaptureSessionHandler {
    let captureSession = AVCaptureSession()
    private let captureSessionQueue = DispatchQueue(label: "capture session queue", qos: .userInteractive)
    private var setupSessionResult: SessionSetupResult = .success
    
    private let photoOutput = AVCapturePhotoOutput()
    
    func configureAVCaptureSession(completion: @escaping () -> Void) {
        captureSessionQueue.async {
            guard self.setupSessionResult == .success else {
                assertionFailure("Configuring AVCaptureSession after it had already failed!")
                return
            }
            
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            
            // Add video input and photo output
            guard
                let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                let videoDeviceInput = try? AVCaptureDeviceInput(device: frontCameraDevice),
                self.captureSession.canAddInput(videoDeviceInput),
                self.captureSession.canAddOutput(self.photoOutput)
            else {
                self.setupSessionResult = .configurationFailed
                return
            }
            
            self.captureSession.addInput(videoDeviceInput)
            self.captureSession.addOutput(self.photoOutput)
            
            DispatchQueue.main.async {
                completion()
            }
            
            self.captureSession.commitConfiguration()
        }
    }
    
    func startCaptureSession() {
        captureSessionQueue.async {
            guard
                !self.captureSession.isRunning,
                self.setupSessionResult == .success
            else { return }
            self.captureSession.startRunning()
        }
    }
    
    func stopCaptureSession() {
        captureSessionQueue.async {
            guard self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
        }
    }
}
