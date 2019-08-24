//
//  dropdown_object.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 05/08/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import Foundation
import Firebase


class dropdown_object{
    
    var id:String!
    var dropdown_title:String?
    var dropdown_elements:[String] = []
    
    init(snapshot:DocumentSnapshot) {
        
        self.id = snapshot.documentID
        if let title = snapshot.get("dropdown_title") as? String{
            self.dropdown_title = title
        }
        
        if let elements = snapshot.get("dropdown_elements") as? [String]{
            self.dropdown_elements.append(contentsOf: elements)
        }
        
    }
    
}
