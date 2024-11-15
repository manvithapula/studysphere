//
//  subjectListTableViewCell.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit

class subjectListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subjectListButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subjectListButton.layer.cornerRadius = 10
        subjectListButton.contentHorizontalAlignment = .left
        
        let chevronImage = UIImage(systemName:"chevron.right")
        let chevronImageView = UIImageView(image: chevronImage)
        
        chevronImageView.tintColor = .black
        chevronImageView.contentMode = .scaleAspectFit
        subjectListButton.addSubview(chevronImageView)
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chevronImageView.centerYAnchor.constraint(equalTo: subjectListButton.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: subjectListButton.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

