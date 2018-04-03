//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by VERDU SANJAY on 03/04/18.
//  Copyright © 2018 VERDU SANJAY. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var imageURLs = [String]()
    var images = [UIImage]()
    var pinData : Pin!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var collectionCount : Int = 0
    var photos = [Photo]()
    var lastImageTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //collectionViewDelegate
        collectionViewSetDelegate()
        
        //Load Images
        loadImages()
    }
    
    //Done Button Tapped
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //New Collection Button Tapped
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        
        
        imageURLs = []
        images = []
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
        
        downloadImages()
        
        
    }
    
    //CollectionViewDelegate
    func collectionViewSetDelegate(){
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    func disableNewCollectionButton(){
        
        newCollectionButton.isEnabled = false
        
    }
    
    func downloadImages(){
        
        collectionCount = 0
        images = []
        
        for photo in photos{
            
            context.delete(photo)
            
        }
        
        save()
        collectionView.reloadData()
        
        disableNewCollectionButton()

            
            FlickrAPI.getImageURLs(lat: pinData.latitude,lon :  pinData.longitude) { (url_array, success, error) in
                
                if success{
                    
                    self.imageURLs = url_array
                    
                    self.collectionCount = self.imageURLs.count
                    
                    print(self.imageURLs)
                    
                    self.displayDownloadedImages()
                    
                }else{
                    
                    print(error)
                    
                }
                
            }
        
    }
    
    //Display download images
    func displayDownloadedImages(){
        
        lastImageTapped = false
        
        disableNewCollectionButton()
        
        var count = 1
        
        for url in imageURLs{
            
            print(count)
            
            let image = DownloadImages.download(image_url: url)
            
            images.append(image)
            
            let newImage = Photo(context: context)
            newImage.image = UIImagePNGRepresentation(image) as Data?
            newImage.parentPin = pinData
            photos.append(newImage)
            save()
            
            count = count + 1
            
            print(count,imageURLs.count)
            
            if count == imageURLs.count{
                
                DispatchQueue.main.async {
                    self.newCollectionButton.isEnabled = true
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
        
        
    }
    
    func displaySavedImages(){
        
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
            
        }
        
        
        
    }
    
    //collection Views Datamethods and Delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CustomCell
        
        print("Index: \(indexPath.item)")
        
        if images.count >= indexPath.item + 1 {
            
            DispatchQueue.main.async {
                cell.imageView.image = self.images[indexPath.row]
            }
            
            
            
        }else{
            
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(named: "loading.jpg")
            }
        
            
        }
        
        return cell
        
    }
    
    //Save Images
    func save(){
        
        do{
            
            try context.save()
        }catch{
            print("error")
        }
        
    }
    
    //Load Images
    
    func loadImages(){
        
        images = []
        
        let request : NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let predicate = NSPredicate(format: "parentPin == %@", pinData)
        
        request.predicate = predicate
        
        do{
            
            let fetched_images = try context.fetch(request)
            
            photos = fetched_images
            
            for image in fetched_images{
                
                let fetched_image = UIImage(data: image.image!)
                images.append(fetched_image!)
            }
            
            if images.count == 0 && lastImageTapped == false {
                
                downloadImages()
                
                
                
            }else{
                
                collectionCount = images.count
                displaySavedImages()
                
            }
            
            
            
        }catch{
            
            print("error")
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if images.count == 1{
            lastImageTapped = true
        }
        
        context.delete(photos[indexPath.item])
        save()
        
        loadImages()
        
    }
    
}
