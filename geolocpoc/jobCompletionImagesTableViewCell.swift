//
//  jobCompletionImagesTableViewCell.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 04/08/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit

class jobCompletionImagesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ind_image: UIImageView!
    
    @IBOutlet weak var description_label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
