//
//  jobCompletionVideoTableViewCell.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 04/08/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit

class jobCompletionVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var video_image_view: UIImageView!
    
    
    @IBOutlet weak var video_description: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
