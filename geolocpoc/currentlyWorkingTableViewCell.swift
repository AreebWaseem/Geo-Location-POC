//
//  currentlyWorkingTableViewCell.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 27/07/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase


class currentlyWorkingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var user_image_view: UIImageView!
    
    @IBOutlet weak var user_name_label: UILabel!
    
    var image_path:String?
    
    var storage:Storage!
    
    var firestore:Firestore!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        firestore = Firestore.firestore()
        storage = Storage.storage()
        round_corners()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
        
        
        // Configure the view for the selected state
    }
    
    func load_image(user_uid: String){
        
        DispatchQueue.main.async {
                
                
                let ref = self.storage.reference()
                
                ref.child(user_uid).child("profile_picture").downloadURL { (url, error) in
                    if (error != nil)
                    {
                        print("No url")
                    }else{
                        
                        if (url != nil)
                        {
                            self.user_image_view.sd_setImage(with: url, placeholderImage: UIImage(named: "user_icon"))
                            }
                        }
                    
                }
        }
        
    }
    
    func load_name(user_uid: String){
        
        firestore.collection("Users").document(user_uid).getDocument { (snapshot, error) in
            if(error == nil)
            {
               self.user_name_label.text = snapshot?.get("name") as? String ?? "User Name"
            }else{
                
            }
        }
    }
    
    func round_corners()
    {
        
        let color = hexStringToUIColor(hex: "#3b3744")
        
        
        self.user_image_view.layer.borderWidth = 2.0
        
        self.user_image_view.layer.borderColor = color.cgColor
        
        self.user_image_view.layer.cornerRadius = self.user_image_view.frame.size.width/2
        
        self.user_image_view.clipsToBounds = true
        
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
    
    
}
