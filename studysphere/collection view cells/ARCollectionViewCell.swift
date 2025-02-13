//
//  ARCollectionViewCell.swift
//  studysphere
//
//  Created by Dev on 19/11/24.
//

import UIKit

class ARCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var continueButtonTapped: UIButton!
    
    @IBOutlet weak var subjectButtonAR: UIButton!
    
    
    var buttonTapped: (() -> Void)?
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        buttonTapped?()
    }
    
    @IBOutlet weak var viewSr: RoundNShadow!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewSr.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewSr.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            viewSr.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3),
            viewSr.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            viewSr.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ])
    }
    
}
