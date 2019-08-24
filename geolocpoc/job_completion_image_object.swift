//
//  job_completion_image_object.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 04/08/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import Foundation
import UIKit


class job_completion_image_object{
    
    
    var image:UIImage?
    var image_desc:String?
    var path:String?
    var taskMap:[String:Any]?
    
    init(img:UIImage,desc:String, path:String,taskMap:[String:Any]) {
        
        self.image = img
        self.image_desc = desc
        self.path = path
       self.taskMap = taskMap
    }
    
}
