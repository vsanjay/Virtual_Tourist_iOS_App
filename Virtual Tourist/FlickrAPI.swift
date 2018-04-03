//
//  FlickrAPI.swift
//  Virtual Tourist
//
//  Created by VERDU SANJAY on 03/04/18.
//  Copyright © 2018 VERDU SANJAY. All rights reserved.
//

import Foundation


class FlickrAPI{
    
    let limit = 20
    
    //Get Number of Pages
    static func getNumberOfPages(url : String,_ completion : @escaping (_ pages: Int32,_ success : Bool,_ error : String) -> Void){
        
        let url = URL(string : url)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil{
                
                completion(1, false, "error")
                
            }else{
                
                let jsonData = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
                
                let photos = jsonData["photos"]
                
                let numberOfPages = photos!["pages"]
                
                completion(numberOfPages as! Int32, true, "")
                
            }
            
        }
        
        task.resume()
        
    }
    
    
    //Get images from that page
    static func getImageURLs(lat : Double,lon : Double,_ completion : @escaping (_ DataArray : [String],_ success : Bool,_ error : String) -> Void ){
        
        var imageURLs = [String]()
        
        let request_url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Constants.API_KEY)&lat=\(lat)&lon=\(lon)&extras=url_m&format=json&nojsoncallback=1&radius=5"
        
        getNumberOfPages(url: request_url) { (pages, success, error) in
            
            if !success{
                
                completion(imageURLs, false, "error")
                
            }
            
            let random_page = arc4random_uniform(UInt32(pages)) + 1
            
            let url = URL(string : request_url + "&page=\(random_page)")
            
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                if error != nil{
                    
                    completion(imageURLs, false, "")
                    
                }else{
                    
                    let jsonData = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
                    let photos = jsonData["photos"]
                    let photo = photos!["photo"] as! [[String : AnyObject]]
                    
                    var count_images = 0
                    
                    for each_photo in photo {
                        
                        if count_images == 20{
                            break
                        }
                        
                        imageURLs.append(each_photo["url_m"] as! String)
                        count_images += 1
                        
                    }
                    
                    completion(imageURLs, true, "")
                    
                }
                
            }
            
            task.resume()
            
        }
        
        
    }
    
    
    
}
