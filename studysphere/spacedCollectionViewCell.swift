//
//  spacedCollectionViewCell.swift
//  studysphere
//
//  Created by dark on 29/10/24.
//

import UIKit

class spacedCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    @IBOutlet weak var stack: UIStackView!
    
    override func awakeFromNib() {
            super.awakeFromNib()

            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.layer.shadowOpacity = 0.1
            self.layer.shadowRadius = 3
            self.layer.masksToBounds = false

        layer.cornerRadius = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    stack.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
                    stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
                    stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
                    stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
                ])
        }

}
