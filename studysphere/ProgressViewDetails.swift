//
//  ProgressViewDetails.swift
//  Studysphere2
//
//  Created by Dev on 06/11/24.
//

import UIKit

class ProgressViewDetails: UIView {
        
        override func awakeFromNib() {
            super.awakeFromNib()
            
            
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 3)
            self.layer.shadowOpacity = 0.8
            self.layer.shadowRadius = 5
            self.layer.masksToBounds = false
            self.layer.cornerRadius = 10
        }
        
    }
