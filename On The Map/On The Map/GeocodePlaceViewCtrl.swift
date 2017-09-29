//
//  GeocodePlaceViewCtrl.swift
//  On The Map
//
//  Created by Ryan Waite on 9/22/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class GeocodePlaceViewCtrl: UIViewController, UITextFieldDelegate,
UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate,
UIScrollViewDelegate {
    
    @IBOutlet weak var loadIcon: UIActivityIndicatorView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    
    func keyboardWillShow(notification: NSNotification) {

    }
    func keyboardWillHide(notification: NSNotification) {
        
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
        print("You: \(session.you)")
        
        self.locationField.delegate = self
        
        
    }
    
}
