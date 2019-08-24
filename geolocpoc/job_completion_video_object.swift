//
//  job_completion_video_object.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 04/08/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import Foundation
import UIKit

class job_completion_video_object{
    
    var thumb:UIImage?
    var url:URL?
    var video_desc:String?
    var path:String?
    var taskMap:[String:Any]?
    
    init(loc: URL,desc:String, thumb: UIImage?, path:String, taskMap:[String:Any]) {
        
        self.url = loc
        self.video_desc = desc
        self.thumb = thumb
        self.path = path
        self.taskMap = taskMap
    }
    
}
