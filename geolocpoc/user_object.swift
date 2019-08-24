//
//  user_object.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 7/13/19.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import Foundation
import FirebaseFirestore
import GoogleMaps


class user_object {
    
    var id:String!
    var name:String?
    var designation:String?
    var email:String?
    var type:String?
    var user_location:GeoPoint?
    var marker:GMSMarker?
    
    init(doc_snapshot:DocumentSnapshot) {

        self.id = doc_snapshot.documentID
        
        if let name = doc_snapshot.get("name") as? String{
        self.name = name
        }
        if let designation = doc_snapshot.get("designation") as? String
        {
        self.designation = designation
        }
        if let email = doc_snapshot.get("email") as? String{
        self.email = email
        }
        if let type = doc_snapshot.get("type") as? String{
        self.type = type
        }
        
        if let user_location = doc_snapshot.get("user_location") as? GeoPoint
        {
        self.user_location = user_location
        }
        
    }
    
    func set_marker(user_loc:GeoPoint?)->GMSMarker?{
        
        guard let lat = user_loc?.latitude, let lon = user_loc?.longitude else {
            return nil
        }
        
        self.user_location = user_loc
        
        let marker_Location = CLLocationCoordinate2DMake(lat, lon)
        
        
        if(marker == nil)
        {
            
        self.marker = GMSMarker(position: marker_Location)
            
        self.marker?.title = self.name ?? ""
            
        var user_data = Dictionary<String, String>()
        user_data["user_uid"] = self.id
        self.marker?.userData = user_data
        self.marker?.icon = UIImage(named: "user_icon-1")
        self.marker?.appearAnimation = GMSMarkerAnimation.pop

        return self.marker
            
        }else{
           self.marker?.position = marker_Location
           return self.marker
        }
        

    }
    
}
