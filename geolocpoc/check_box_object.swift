//
//  check_box_object.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 05/08/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import Foundation
import Firebase

class check_box_object {
    
    var check_box_title:String?
    var individual_check_boxes:[String] = []
    
    var id:String!
    
    init(snapshot:DocumentSnapshot) {
        
        self.id = snapshot.documentID
        
        if let title = snapshot.get("check_box_title") as? String{
            self.check_box_title = title
        }
        
        if let ind_boxes = snapshot.get("individual_check_boxes") as? [String]{
            self.individual_check_boxes.append(contentsOf: ind_boxes)
        }
    
    }
    
}
