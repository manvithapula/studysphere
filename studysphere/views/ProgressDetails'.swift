//
//  ProgressDetails'.swift
//  studysphere
//
//  Created by dark on 02/11/24.
//

import UIKit

class ProgressDetails: RoundNShadow {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
                
        let backgroundView = UIView(frame: bounds)
        backgroundView.backgroundColor = UIColor(named: "Main")
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.layer.cornerRadius = 16
        backgroundView.layer.masksToBounds = true
        insertSubview(backgroundView, at: 0)
    }
}
