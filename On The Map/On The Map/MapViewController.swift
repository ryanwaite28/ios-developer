//
//  MapViewController.swift
//  On The Map
//
//  Created by Ryan Waite on 9/19/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadIcon: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setMarkers()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        // Left bar button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(updateInfo))
        
        // Right bar button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.reply, target: self, action: #selector(logout))
        
        // Title
        self.navigationItem.title = "Map"
        
        //
        self.mapView.delegate = self
        
        self.loadIcon.hidesWhenStopped = true
        if session.you != nil {
            self.mapView.removeAnnotation(session.annotations[0])
            setMarker(student: session.you!)
        }
        
        
    }
    
    func setMarker(student: Student){
        let lat = CLLocationDegrees(student.latitude)
        let long = CLLocationDegrees(student.longitude)
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let first = student.firstName 
        let last = student.lastName 
        let mediaURL = student.mediaURL 
        
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(first) \(last)"
        annotation.subtitle = mediaURL
        
        // Finally we place the annotation in an array of annotations.
        session.annotations[0] = annotation
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotation(annotation)
    }
    func setMarkers(){
        for student in session.studentLocations {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            session.annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(session.annotations)
    }
    
    //
    
    func logout() -> Void {
        self.loadIcon.startAnimating()
        logoutUser(view: self){(error) in
            performUIUpdatesOnMain {
                self.loadIcon.stopAnimating()
                if error == false {
                    dismissPopoverView(view: self.parent!)
                    return
                }
                showAlertController(view: self, title: "Error", message: "Error Processing...")
            }
        }
    }
    
    func updateInfo() -> Void {
        
        viewTOviewStack(baseView: self, targetView: "UpdateInfoViewController")
        
    }
    
    //
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure) as UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                openURLaddress(link: toOpen)
            }
        }
    }

}
