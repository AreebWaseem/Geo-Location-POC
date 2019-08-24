//
//  rightindMessageTableViewCell.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 28/07/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit

class rightindMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var time_label: UILabel!
    
    @IBOutlet weak var right_ind_message_label: UILabel!
    
    
    @IBOutlet weak var label_outer_view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        round_corners()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func round_corners(){
        label_outer_view.layer.cornerRadius = 6.0
    }
    
}
