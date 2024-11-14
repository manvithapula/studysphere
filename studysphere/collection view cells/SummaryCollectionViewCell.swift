//
//  SummaryCollectionViewCell.swift
//  studysphere
//
//  Created by admin64 on 07/11/24.
//

import UIKit

class SummaryCollectionViewCell: UICollectionViewCell {
    
        // Outlets for the UI elements
        @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var subTitleLabel: UILabel!
        @IBOutlet weak var continueButton: UIButton!
        
        // Closure for button tap action
        var buttonTapped: (() -> Void)?
        
        // Action for the button tap
        @IBAction func continueButtonTapped(_ sender: UIButton) {
            buttonTapped?()  // Trigger the closure when the button is tapped
        }
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    }

