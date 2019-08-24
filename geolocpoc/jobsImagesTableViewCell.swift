//
//  jobsImagesTableViewCell.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 21/07/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class jobsImagesTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var progress_bar: UIActivityIndicatorView!
    
    var image_path:String?
    
    var storage:Storage!
    
    @IBOutlet weak var ind_job_image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        storage = Storage.storage()
        
        load_image()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func load_image(){
        
        DispatchQueue.main.async {
            
            if(self.image_path != nil)
            {
                
            print(self.image_path!)
                
            
            let ref = self.storage.reference()
            
           self.ind_job_image.isHidden = true
           self.progress_bar.startAnimating()
            
            ref.child(self.image_path!).downloadURL { (url, error) in
                if (error != nil)
                {
                    self.ind_job_image.isHidden = false
                    self.progress_bar.stopAnimating()
                    print("No url")
                }else{
                    
                    if (url != nil)
                    {
                        self.ind_job_image.sd_setImage(with: url,placeholderImage: UIImage(named: "repairing"), completed: { (image, error, cachetype, url) in
                            self.ind_job_image.isHidden = false
                            self.progress_bar.stopAnimating()
                            if (image != nil)
                            {
                                print("got image")
                                //self.save_image_to_db(image: image!)
                            }
                            if(error != nil)
                            {
                                print(error?.localizedDescription ?? "Error")
                            }
                        })
                        /*
                        self.ind_job_image.sd_setImage(with: url, placeholderImage: UIImage(named: "repairing"), options: SDWebImageOptions.refreshCached) { (image, error, cache_type, url) in
                        
                        }
 */
                    }else{
                        self.ind_job_image.isHidden = false
                        self.progress_bar.stopAnimating()
                    }
                    
                }
            }
            }else{
                print("null path")
            }
        }
    }
    
}
