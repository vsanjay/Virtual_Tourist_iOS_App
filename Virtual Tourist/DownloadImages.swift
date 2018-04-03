//
//  DownloadImages.swift
//  Virtual Tourist
//
//  Created by VERDU SANJAY on 03/04/18.
//  Copyright © 2018 VERDU SANJAY. All rights reserved.
//

import Foundation
import UIKit


struct DownloadImages{
    
    static func download(image_url : String) -> UIImage{
        
        let url = URL(string : image_url)
        
        let data = try! Data(contentsOf: url!)
        
        let image = UIImage(data: data)
        
        return image!
        
    }

}
