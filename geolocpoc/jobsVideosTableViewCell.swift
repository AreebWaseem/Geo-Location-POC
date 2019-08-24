//
//  jobsVideosTableViewCell.swift
//  geolocpoc
//
//  Created by Areeb Waseem on 22/07/2019.
//  Copyright © 2019 Areeb Waseem. All rights reserved.
//

import UIKit
import AVFoundation

class jobsVideosTableViewCell: UITableViewCell {
    
    
    var video_path:String?
    
    @IBOutlet weak var video_thumb_nail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        /*
        if(video_path != nil)
        {
            print("here")
            generate_thumbnail(url_str: self.video_path!)
        }else{
            print("here nil")
        }
 */
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func thumbnail(url_string:String) {
        
        print("here")
        
        if let thumbnail_url = NSURL(string: url_string){
            
              print("here1")
            
            let request = NSURLRequest(url: thumbnail_url as URL)
            let session = URLSession.shared
    
          	session.dataTask(with: request as URLRequest) { (data, response, error) in
                  print("here2")
                if(error != nil)
                {
                    print("error getting image")
                }
                if(data != nil)
                {
                    self.video_thumb_nail.image = UIImage(data: data!)
                    print("set")
                }else{
                    print("error another")
                }
            }
            
        }else{
            print("null url")
        }
        
    }
    
    func generate_thumbnail(url_str: String){
        
        DispatchQueue.global().async {
            
            if let url = URL(string: url_str)
            {
                print("here1")
                let asset = AVAsset(url: url)
            let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTimeMake(value: 1, timescale: 2)
            let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            if img != nil {
                print("here2")
                let frameImg  = UIImage(cgImage: img!)
                DispatchQueue.main.async(execute: {
                    print("here3")
                    self.video_thumb_nail.image = frameImg
                    // assign your image to UIImageView
                })
            }else{
                
                }
                
            }
        }
        
    }

}
