//
//  PinPreviewViewCtrl.swift
//  On The Map
//
//  Created by Ryan Waite on 9/22/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation


class PinPreviewViewCtrl: UIViewController, UITextFieldDelegate,
UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate,
UIScrollViewDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var loadIcon: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    
    var parentView: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {

    }
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeFromKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadIcon.hidesWhenStopped = true
        subscribeFromKeyboardNotifications()
        
        print("Session dataExists: \(session.dataExists)")
        print("You: \(session.you!)")
        
        self.linkField.delegate = self
        self.mapView.delegate = self
        
        if session.dataExists == true {
            self.linkField.text = session.you!.mediaURL
        }
        
        //
        
        let lat = CLLocationDegrees(session.tempLat)
        let long = CLLocationDegrees(session.tempLng)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = session.tempLocation
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 9, longitudeDelta: 9))

        self.mapView.addAnnotation(annotation)
        self.mapView.setCenter(coordinate, animated: true)
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    @IBAction func cancelBtnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: {() -> Void in
            
        })
    }
    
    @IBAction func submitBtnClick(_ sender: Any) {
        loadIcon.startAnimating()
        configButtonEnable(btn: self.cancelBtn, state: false)
        configButtonEnable(btn: self.submitBtn, state: false)
        
        if linkField.text == nil {
            linkField.text = ""
        }
        
        if !Reachability.isConnectedToNetwork() {
            self.loadIcon.stopAnimating()
            configButtonEnable(btn: self.cancelBtn, state: true)
            configButtonEnable(btn: self.submitBtn, state: true)
            
            showAlertController(view: self, title: "No Internet", message: "This App Requires An Internet Connection")
            
            return
        }
        
        let Action: String = session.dataExists == true ? keys.update : keys.create
        
        modifyUserLocation(view: self, action: Action, location: session.tempLocation, link: self.linkField.text ?? "", fname: session.you!.firstName, lname: session.you!.lastName, lat: session.tempLat, lng: session.tempLng) {(error) in
            performUIUpdatesOnMain {
                self.loadIcon.stopAnimating()
                configButtonEnable(btn: self.cancelBtn, state: true)
                configButtonEnable(btn: self.submitBtn, state: true)
                
                
                
                if error == false {
                    self.parentView?.navigationController?.popViewController(animated: true)
                    
                    showAlertController(view: self, title: keys.success, message: "Updates Posted!"){
                        self.dismiss(animated: true, completion: {() -> Void in
                            
                            
                        })
                        
                    }
                }
                else {
                    showAlertController(view: self, title: keys.error, message: "Updates Failed")
                }
            }
        }
    }
    
}
