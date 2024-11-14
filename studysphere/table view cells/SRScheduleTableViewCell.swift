//
//  SRScheduleTableViewCell.swift
//  studysphere
//
//  Created by dark on 05/11/24.
//

import UIKit

class SRScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var completionImage: UIImageView!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var timeL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
                
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
