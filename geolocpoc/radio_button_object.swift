//
//  radio_button_object.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 05/08/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import Foundation
import Firebase

class radio_button_object {
    
    var id:String!
    var radio_button_title:String?
    var individual_radio_buttons:[String] = []
    
    init(snapshot:DocumentSnapshot) {
        
        self.id = snapshot.documentID
        
        if let title = snapshot.get("radio_button_title") as? String{
            self.radio_button_title = title
        }
        
        if let ind_buttons = snapshot.get("individual_radio_buttons") as? [String]{
            self.individual_radio_buttons.append(contentsOf: ind_buttons)
        }
        
    }
    
    
}
