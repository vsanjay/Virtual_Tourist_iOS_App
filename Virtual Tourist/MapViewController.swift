//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by VERDU SANJAY on 02/04/18.
//  Copyright © 2018 VERDU SANJAY. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController,MKMapViewDelegate {
    
    //Map View
    @IBOutlet weak var myMapView: MKMapView!
    
    //PinsArray
    var pinsArray = [Pin]()
    
    //Pin data to send
    var pinDataToSend : Pin!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Map Delegate
        mapViewDelegate()
        
        //Add Long press touch Recogniser
        addLongPressRecogniser()
        
        //DBlink
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first)
        
        //Load Pins
        showPins()
        
    }
    
    // Map Delegate
    func mapViewDelegate(){
        
        myMapView.delegate = self
        
    }
    
    //Add long press recogniser
    
    func addLongPressRecogniser(){
        
        let recogniser = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)) )
        
        recogniser.minimumPressDuration = 1.5
        myMapView.addGestureRecognizer(recogniser)
        
    }
    
    //After long press add Annotation
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = myMapView.convert(gestureRecognizer.location(in: myMapView), toCoordinateFrom: myMapView)
            
            let newPin = Pin(context: context)
            newPin.latitude = annotation.coordinate.latitude
            newPin.longitude = annotation.coordinate.longitude
            pinsArray.append(newPin)
            
            //SaveData
            
            saveToDB()
            
            self.myMapView.addAnnotation(annotation)
            
        }
    }
    
    
    //Map view Delegates
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinView = MKPinAnnotationView()
        pinView.animatesDrop = true
        
        return pinView
        
    }
    
    //Save
    func saveToDB(){
        
        do{
            
            try context.save()
            
        }catch{
            
            print(error)
            
        }
        
    }
    
    //Show Pins
    
    func showPins(){
        
        let request : NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do{
            
             pinsArray = try context.fetch(request)
            
            for pin in pinsArray {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                myMapView.addAnnotation(annotation)
                
            }
            
            
        }
        catch{
            
            print("error")
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            for pin in pinsArray{
                if pin.latitude == view.annotation?.coordinate.latitude && pin.longitude == view.annotation?.coordinate.longitude{
                    
                    pinDataToSend = pin
                    
                    performSegue(withIdentifier: "goToPhotos", sender: self)
                    
                }
                
            }
        
        myMapView.deselectAnnotation(view.annotation, animated: true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! PhotoAlbumViewController
        
        destinationVC.pinData = pinDataToSend
        
    }
    
    
    
}
