//
//  job_form_object.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 05/08/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import Foundation
import Firebase


class job_form_object {
    
    var short_desc:String?
    var desc:String?
    var individual_items:[Any] = []
    
    init() {
        
    }
    
    
    
    func add_dropdown(snapshot:DocumentSnapshot) -> dropdown_object?{
        
        let drop_obj = dropdown_object(snapshot: snapshot)
        
        if (drop_obj.dropdown_title != nil && drop_obj.dropdown_elements.count > 0){
            self.individual_items.append(drop_obj)
            return drop_obj
        }else{
            return nil
        }
        
    }
    

    func add_check_box(snapshot:DocumentSnapshot) -> check_box_object? {
        
        let check_obj = check_box_object(snapshot: snapshot)
        
        if (check_obj.check_box_title != nil && check_obj.individual_check_boxes.count > 0){
            self.individual_items.append(check_obj)
            return check_obj
        }else{
            return nil
        }
        
        
    }
    
    
    func add_radio_button(snapshot:DocumentSnapshot)-> radio_button_object? {
        
        let radio_obj = radio_button_object(snapshot: snapshot)
        
        if (radio_obj.radio_button_title != nil && radio_obj.individual_radio_buttons.count > 0){
            self.individual_items.append(radio_obj)
            return radio_obj
        }else{
            return nil
        }
        
    }
    
    
    
}
