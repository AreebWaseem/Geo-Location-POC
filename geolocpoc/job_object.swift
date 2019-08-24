//
//  job_object.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 20/07/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import Foundation
import FirebaseFirestore
import GoogleMaps



class job_object{

var id:String!
var title:String?
var description:String?
var job_location:GeoPoint?
var marker:GMSMarker?
var image_paths:[String] = []
var videos:[String] = []
var currently_working_users:[String] = []
var is_complete:String?
var current_user_distance:Double = 0.0000000

    init(snapshot:DocumentSnapshot) {
        
        self.id = snapshot.documentID
    
        if let title = snapshot.get("title") as? String{
            self.title = title
        }else{
            self.title = ""
        }
        
        if let job_loc = snapshot.get("job_location") as? GeoPoint{
            self.job_location = job_loc
        }
        
        if let desc = snapshot.get("description") as? String{
            
            self.description = desc
            
        }else{
            self.description = ""
        }
        
        if let images_array = snapshot.get("images") as? [String]{
            self.image_paths = images_array
        }
        if let videos_array = snapshot.get("videos") as? [String]{
            self.videos = videos_array
        }
        if let cur_work_users_array = snapshot.get("currently_working") as? [String]{
            self.currently_working_users = cur_work_users_array
        }
        if let comp_status = snapshot.get("is_complete") as? String {
            self.is_complete = comp_status
        }
        
        
    }
    
    
    
    
}
