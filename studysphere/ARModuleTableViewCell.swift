//
//  ARModuleTableViewCell.swift
//  Studysphere2
//
//  Created by Dev on 06/11/24.
//

import UIKit

class ARModuleTableViewCell: UITableViewCell {
    @IBOutlet weak var titleL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 5
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
