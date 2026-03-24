// Copyright © 2024 DexCare. All rights reserved.

import SwiftUI
import UIKit

class WaitingRoomHostingController: UIHostingController<WaitingRoomSwiftUIView> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

class VisitHostingController: UIHostingController<VisitSwiftUIView> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
