//
//  ViewController.swift
//  My Virtual Tourist
//
//  Created by Ryan Waite on 9/23/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var deleteMode: Bool = false
    @IBOutlet weak var editBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(longPressGesture)
        
        try! session.stack.dropAllData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ann - \(self.mapView.annotations.count)")
        if self.mapView.annotations.count > 0 {
            print("linger")
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        self.mapView.delegate = self
        self.navigationItem.title = "Map"
        
        let places = getPlaces()
        print("Places Count: \(places.count)")
        self.setMarkers(places: places)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    // --- //
    
    func setMarkers(places: [Place]){
         var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
        for place in places {
            let lat = CLLocationDegrees(place.lat)
            let long = CLLocationDegrees(place.lng)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    func getPlaces() -> [Place] {
        let placesFetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityNames.place)
        
        do {
            let places = try session.stack.context.fetch(placesFetch) as! [Place]
            return places
        } catch {
            fatalError("Failed to fetch places: \(error)")
        }
    }
    
    // snippet found at: https://stackoverflow.com/questions/40844336/create-long-press-gesture-recognizer-with-annotation-pin
    func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        if !Reachability.isConnectedToNetwork() {
            showAlertController(view: self, title: "No Internet", message: "This App Requires An Internet Connection")
            
            return
        }
        
        if gesture.state == .began {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            //Now use this coordinate to add annotation on map.
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate

            self.mapView.addAnnotation(annotation)
            
            let coords: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let lat = coordinate.latitude
            let lng = coordinate.longitude
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(coords){
                placemarks, error in
                print("error: \(String(describing: error)) \n")

                guard let placemark = placemarks?.first else {
                        print("Geocode Error")
                        return
                }
                
                let title = "\(placemark.locality!), \(placemark.administrativeArea!)"
                self.addPlace(title: title, lat: lat, lng: lng)
            }
        }
    }
    func addPlace(title: String, lat: Double, lng: Double) {
        
        let place: Place = Place(title: title, lat: lat, lng: lng, context: session.stack.context)
        session.stack.save()
        
        self.navigationItem.title = "Loading..."
        getPhotosFromLatLng(place: place, lat: lat, lng: lng){(error, linklist) in
            print("error in adding place - \(error)")
            
            if error == false {
                // if all went well, save the changes
                DispatchQueue.global(qos: .background).async {
                    DispatchQueue.main.async {
                        for link in linklist! {
                            Image(creationdate: Date(), databytes: nil, originlink: link, ownerLat: lat, ownerLng: lng, place: place, context: session.stack.context)
                        }
                        self.navigationItem.title = "Map"
                        place.hasPhotos = true
                        session.stack.save()
                    }
                    
                }
                
            }
        }
    }
    
    func findPlace(annotation: MKAnnotation) -> Place? {
        let places = getPlaces()
        guard places.count > 0 else {
            print("places is empty")
            return nil
        }
        
        var Place: Place?
        for place in places {
            if place.lat == annotation.coordinate.latitude || place.lng == annotation.coordinate.longitude {
                Place = place
            }
        }
        
        return Place ?? nil
    }
    
    @IBAction func editBtnClick(_ sender: Any) {
        self.deleteMode = !self.deleteMode
        if self.deleteMode == true {
            self.editBtn.title = "Done"
            self.mapView.frame.origin.y -= 50
        }
        else {
            self.editBtn.title  = "Edit"
            self.mapView.frame.origin.y += 50
        }
    }
    
    //

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let place: Place? = findPlace(annotation: view.annotation!)
        
        guard place != nil else {
            self.mapView.removeAnnotation(view.annotation!)
            print("cannot locate place")
            return
        }
        
        if self.deleteMode == true {
            self.mapView.removeAnnotation(view.annotation!)
            session.stack.context.delete(place!)
            session.stack.save()
            return
        }
        else {
            let PlaceViewCtrl = self.storyboard?.instantiateViewController(withIdentifier: "PlaceViewController") as! PlaceViewController
            
            PlaceViewCtrl.place = place

            self.present(PlaceViewCtrl, animated: true)
            print("removed")
        }
    }

}

