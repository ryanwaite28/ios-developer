//
//  ViewController.swift
//  On The Map
//
//  Created by Ryan Waite on 9/17/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate,
UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate {
    
    // var editBottom = false

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pswrdField: UITextField!
    var lastEditedField: UITextField?
    
    @IBOutlet weak var loadIcon: UIActivityIndicatorView!
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBAction func submitBtnClick(_ sender: Any) {
        lastEditedField?.resignFirstResponder()
        loadIcon.startAnimating()
        configButtonEnable(btn: submitBtn, state: false)
 
        // found this code snippet from: https://stackoverflow.com/questions/30743408/check-for-internet-connection-with-swift
        if !Reachability.isConnectedToNetwork() {
            loadIcon.stopAnimating()
            configButtonEnable(btn: submitBtn, state: true)
            showAlertController(view: self, title: "No Internet", message: "This App Requires An Internet Connection")
            return
        }
        print("Internet Connected")
        
        if(emailField.text == "" || emailField.text == nil) {
            loadIcon.stopAnimating()
            configButtonEnable(btn: submitBtn, state: true)
            showAlertController(view: self, title: "Missing Info", message: "Email Is Required")
            return
        }
        if(pswrdField.text == "" || pswrdField.text == nil) {
            loadIcon.stopAnimating()
            configButtonEnable(btn: submitBtn, state: true)
            showAlertController(view: self, title: "Missing Info", message: "Password Is Required")
            return
        }
        
        loginUser(view: self, email: emailField.text ?? "", pswrd: pswrdField.text ?? "") {(infoDict) in
            performUIUpdatesOnMain {
                
                
                if(infoDict["result"] == keys.error) {
                    self.loadIcon.stopAnimating()
                    configButtonEnable(btn: self.submitBtn, state: true)
                    showAlertController(view: self, title: "Unsuccessful", message: "Account Not Found")
                    return
                }
                else if(infoDict["result"] == keys.success) {
                    
                    getStudentLocation(view: self, key: session.accountKey){(error) in
                        performUIUpdatesOnMain {
                            if error == true {
                                self.loadIcon.stopAnimating()
                                configButtonEnable(btn: self.submitBtn, state: true)
                                showAlertController(view: self, title: "Exception", message: "Error Fetching Data...")
                                return
                            }
                            
                            setLocationsToSession(view: self){(resp) in
                                performUIUpdatesOnMain {
                                    self.loadIcon.stopAnimating()
                                    configButtonEnable(btn: self.submitBtn, state: true)
                                    if resp == keys.error {
                                        
                                        showAlertController(view: self, title: "Exception", message: "Error Processing Data...")
                                        return
                                    }
    
                                    viewTOviewPresent(baseView: self, targetView: "TabViewCtrl")
                                    
                                }
                            }
                        }
                    }
                }
                else {
                    self.loadIcon.stopAnimating()
                    configButtonEnable(btn: self.submitBtn, state: true)
                    showAlertController(view: self, title: "Exception", message: "Unknown Error...")
                    return
                }
            }
        }
    }
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.emailField.delegate = self
        self.pswrdField.delegate = self
        
        self.emailField.text = ""
        self.pswrdField.text = ""
        
        self.loadIcon.hidesWhenStopped = true
        
        subscribeToKeyboardNotifications()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //
    
    func keyboardWillShow(notification: NSNotification) {
        //self.view.frame.origin.y -= getKeyboardHeight(notification as Notification)
    }
    func keyboardWillHide(notification: NSNotification) {
        //self.view.frame.origin.y = 0
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        lastEditedField = textField
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}

