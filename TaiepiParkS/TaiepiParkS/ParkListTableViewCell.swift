//
//  ParkListTableViewCell.swift
//  TaiepiParkS
//
//  Created by Richard on 2018/02/14.
//  Copyright © 2018年 Snowowl. All rights reserved.
//

import UIKit

class ParkListTableViewCell: UITableViewCell {

    @IBOutlet weak var parkImageView: UIImageView!
    
    @IBOutlet weak var parkNameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var parkIntroLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
