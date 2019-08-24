//
//  job_table_view_cell.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 20/07/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit

class job_table_view_cell: UITableViewCell {
    
    
    @IBOutlet weak var title_label: UILabel!
    
    
    @IBOutlet weak var distance_label: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
