//
//  subjectCellCollectionViewCell.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit


class subjectCellCollectionViewCell: UICollectionViewCell {
        // Outlets for the UI elements
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var continueButtonTapped: UIButton!
   
    @IBOutlet weak var subTitleLabel: UILabel!
    var buttonTapped: (() -> Void)?
    @IBAction func continueButtonTapped(_ sender: Any)
      
    {
            buttonTapped?()
        }
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    }

