//
//  ARScheduleTableViewCell.swift
//  studysphere
//
//  Created by Dev on 16/11/24.
//

import UIKit

class ARScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var ARcompletionImage: UIImageView!
    @IBOutlet weak var ARtitle: UILabel!
    @IBOutlet weak var ARdate: UILabel!
    @IBOutlet weak var ARtime: UILabel!
        

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
