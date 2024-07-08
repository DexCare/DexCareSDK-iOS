// Copyright © 2019 DexCare. All rights reserved.

import UIKit
import AVFoundation

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        // swiftlint:disable force_cast
        // This is guaranteed to be try true by UIKit
        return layer as! AVCaptureVideoPreviewLayer
        // swiftlint:enable force_cast
    }
}
