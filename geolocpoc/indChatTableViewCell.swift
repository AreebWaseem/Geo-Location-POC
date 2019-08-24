//
//  indChatTableViewCell.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 28/07/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class indChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label_outer_view: UIView!
    
    @IBOutlet weak var user_image: UIImageView!
    
    @IBOutlet weak var message_time_label: UILabel!
    
    @IBOutlet weak var ind_message_label: UILabel!
    
    var storage:Storage!
    
    
    @IBOutlet weak var user_name_label: UILabel!
    
    var image_url_string:String?
    
    var current_call = 0
    
    var over_uid:String?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        round_corners()
        storage = Storage.storage()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
      //  self.user_image.image = UIImage(named: "user_icon")
    }
    
    func round_corners()
    {
        
        let color = hexStringToUIColor(hex: "#3b3744")
        
        
        self.user_image.layer.borderWidth = 2.0
        
        self.user_image.layer.borderColor = color.cgColor
        
        self.user_image.layer.cornerRadius = self.user_image.frame.size.width/2
        
        self.user_image.clipsToBounds = true
        
        label_outer_view.layer.cornerRadius = 6.0
        
    }
    
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
        
    }
    
    func get_picture(ms_uid : String){
        
        if(!ms_uid.isEmpty)
        {
            
            
                let ref = self.storage.reference()
                
                self.user_image.sd_cancelCurrentImageLoad()
                
                self.user_image.image = UIImage(named: "user_icon")
            
                let curr_uid = ms_uid
            
                over_uid = curr_uid
                
                ref.child(ms_uid).child("profile_picture").downloadURL { (url, error) in
                    if (error != nil)
                    {
                       // self.user_image.image = UIImage(named: "user_icon")
                        print("No url")
                    }else{
                        
                        
                        if (url != nil)
                        {
                            if(curr_uid == self.over_uid)
                            {
                                
                            self.user_image.sd_cancelCurrentImageLoad()
                                
                            SDWebImageManager.shared.loadImage(with: url, progress: nil, completed: { (image, data, error, type, bool, url) in
                                
                                if(curr_uid == self.over_uid){
                                    
                                if(image != nil)
                                {
                                    self.user_image.image = image!
                                }else{
                                       self.user_image.image = UIImage(named: "user_icon")
                                }
                                    
                                }
                                
                            })
                                
                            }
                            
                           // self.user_image.sd_setImage(with: url, placeholderImage: UIImage(named: "user_icon"))
                        }else{
                            
                            if(curr_uid == self.over_uid)
                            {
                                  self.user_image.image = UIImage(named: "user_icon")
                            }
                            //self.user_image.image = UIImage(named: "user_icon")
                        }
                        
                    }
                    
                }
            
        }
        
    }
    
    
}
