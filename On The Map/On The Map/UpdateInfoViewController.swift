//
//  UpdateInfoViewController.swift
//  On The Map
//
//  Created by Ryan Waite on 9/19/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class UpdateInfoViewController: UIViewController, UITextFieldDelegate,
UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate {
    
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var fnameField: UITextField!
    @IBOutlet weak var lnameField: UITextField!
    
    var lastEditedField: UITextField?
    @IBOutlet weak var loadIcon: UIActivityIndicatorView!
    
    var editBottom = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if( editBottom == true ){
            view.frame.origin.y -= getKeyboardHeight(notification as Notification)
        }
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
        lastEditedField = textField
        if(textField.tag == 3 || textField.tag == 4){
            editBottom = true
        }
        else {
            editBottom = false
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        editBottom = false
        
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.loadIcon.hidesWhenStopped = true
        subscribeFromKeyboardNotifications()
        
        print("Session dataExists: \(session.dataExists)")
        print("You: \(session.you)")
        
        self.locationField.delegate = self
        self.fnameField.delegate = self
        self.lnameField.delegate = self
        
        if session.dataExists == true {
            
            self.locationField.text = session.you!.mapString
            
            if session.you!.firstName == "" {
                self.fnameField.isEnabled = true
            }
            else {
                self.fnameField.text = session.you!.firstName
                self.fnameField.isEnabled = false
            }
            
            if session.you!.lastName == "" {
                self.lnameField.isEnabled = true
            }
            else {
                self.lnameField.text = session.you!.lastName
                self.lnameField.isEnabled = false
            }
            
        }
    }
    

    @IBAction func submitBtnClick(_ sender: Any) {
        lastEditedField?.resignFirstResponder()
        loadIcon.startAnimating()
        configButtonEnable(btn: self.submitBtn, state: false)
        
        if !Reachability.isConnectedToNetwork() {
            self.loadIcon.stopAnimating()
            configButtonEnable(btn: self.submitBtn, state: true)
            showAlertController(view: self, title: "No Internet", message: "This App Requires An Internet Connection")
            
            return
        }
        
        guard locationField.text != "" else {
            self.loadIcon.stopAnimating()
            configButtonEnable(btn: self.submitBtn, state: true)
            showAlertController(view: self, title: "Missing Data", message: "Location is Required - \"city, state\"")
            
            return
        }
        guard fnameField.text != "" else {
            self.loadIcon.stopAnimating()
            configButtonEnable(btn: self.submitBtn, state: true)
            showAlertController(view: self, title: "Missing Data", message: "First Name is Required")
            
            return
        }
        guard lnameField.text != "" else {
            self.loadIcon.stopAnimating()
            configButtonEnable(btn: self.submitBtn, state: true)
            showAlertController(view: self, title: "Missing Data", message: "Last Name is Required")
            
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.locationField.text!) {
            placemarks, error in
            
            guard let placemark = placemarks?.first,
            let lat = placemark.location?.coordinate.latitude,
            let lon = placemark.location?.coordinate.longitude else {
                self.loadIcon.stopAnimating()
                configButtonEnable(btn: self.submitBtn, state: true)
                
                showAlertController(view: self, title: "Error", message: "Could Not Geocode Location...")
                return
            }
            
            session.tempLat = lat
            session.tempLng = lon
            session.tempLocation = self.locationField.text!
            
            self.loadIcon.stopAnimating()
            configButtonEnable(btn: self.submitBtn, state: true)
            
            let pinPreview = self.storyboard!.instantiateViewController(withIdentifier: "PinPreview") as! PinPreviewViewCtrl
            pinPreview.parentView = self
            
            self.present(pinPreview, animated: true)
            
        }
    }
    
    

}
