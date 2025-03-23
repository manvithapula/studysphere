//
//  test.swift
//  studysphere
//
//  Created by dark on 29/10/24.
//

import UIKit

class RoundNShadow: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 3
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 16
    }
}
