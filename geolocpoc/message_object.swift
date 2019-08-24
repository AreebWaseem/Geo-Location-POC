//
//  message_object.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 28/07/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import Foundation
import Firebase

class message_object {
    
    var message_text:String?
    var message_from_uid:String?
    var message_time:Timestamp?
    var message_id:String!
    var message_from_name:String?
    
    init(snapshot:DocumentSnapshot)
    {
        
        self.message_id = snapshot.documentID
        
        if let msg_txt = snapshot.get("message_text") as? String{
            self.message_text = msg_txt
        }
        
        if let msg_from_ud = snapshot.get("message_from_uid") as? String{
            self.message_from_uid = msg_from_ud
        }
        if let msg_fr_nm = snapshot.get("message_from_name") as? String{
            self.message_from_name = msg_fr_nm
        }
        if let msg_time = snapshot.get("message_time") as? Timestamp{
            self.message_time = msg_time
        }
    }
    
    
    
    
    
}
