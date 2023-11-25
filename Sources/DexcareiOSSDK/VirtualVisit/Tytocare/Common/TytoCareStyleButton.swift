import Foundation
import UIKit

// the blue button
class TytoCareStyleButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
 
    func setupButton() {
        self.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.setTitleColor(UIColor.white, for: .normal)
    }
    
    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }

}
