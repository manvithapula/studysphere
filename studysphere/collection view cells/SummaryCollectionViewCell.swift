//
//  SummaryCollectionViewCell.swift
//  studysphere
//
//  Created by admin64 on 07/11/24.
//

import UIKit

class SummaryCollectionViewCell: UICollectionViewCell {
    
       
        @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var subTitleLabel: UILabel!
        @IBOutlet weak var continueButton: UIButton!
        
 
        var buttonTapped: (() -> Void)?
        
    @IBOutlet weak var view: RoundNShadow!
    
        @IBAction func continueButtonTapped(_ sender: UIButton) {
            buttonTapped?()
        }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            view.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
                            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3),
                            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
                            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
                        ])
                }
    }

