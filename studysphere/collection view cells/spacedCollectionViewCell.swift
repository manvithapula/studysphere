//
//  spacedCollectionViewCell.swift
//  studysphere
//
//  Created by dark on 29/10/24.
//

import UIKit

class spacedCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var continueButtonTapped: UIButton!
    
    
    
            var buttonTapped: (() -> Void)?
            
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        buttonTapped?()
    }
    
    override class func awakeFromNib() {
            super.awakeFromNib()
        }
        }


