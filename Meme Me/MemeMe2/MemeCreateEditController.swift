//
//  MemeCreateEditController.swift
//  MemeMe2
//
//  Created by Ryan Waite on 9/18/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.20

//

import Foundation
import UIKit

class MemeCreateEditController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate {
    
    var editBottom = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var bottomBar: UIToolbar!
    
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -5.0
    ]
    
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setTextField(UIelm: UITextField, text: String, cy: Int, tag: Int){
        UIelm.delegate = self
        UIelm.defaultTextAttributes = memeTextAttributes
        UIelm.text = text
        UIelm.textAlignment = NSTextAlignment.center
        UIelm.adjustsFontSizeToFitWidth = true
        UIelm.center.x = self.view.center.x
        UIelm.center.y = CGFloat(cy)
        UIelm.minimumFontSize = 25
        UIelm.tag = tag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        // view.backgroundColor = UIColor.black
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showActivityController))
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        
        let toptextY = self.view.frame.origin.y + 150
        setTextField(UIelm: topText, text: "TOP", cy: Int(toptextY), tag: 1)
        
        let bottomtextY = self.view.frame.height - 150
        setTextField(UIelm: bottomText, text: "BOTTOM", cy: Int(bottomtextY), tag: 2)
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //
    
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeCreateEditController.keyboardWillShow(_:))    , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemeCreateEditController.keyboardWillHide(_:))    , name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if( editBottom == true ){
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        // print(view.frame.origin.y)
    }
    func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
        // print(view.frame.origin.y)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @IBAction func cancelBtnCllick(_ sender: Any) {
        dismissPopoverView(view: self)
    }
    func imgSelect(sourceType: UIImagePickerControllerSourceType){
        let ImagePickerController = UIImagePickerController()
        ImagePickerController.delegate = self
        
        ImagePickerController.sourceType = sourceType
        ImagePickerController.allowsEditing = false
        self.present(ImagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        imgSelect(sourceType: UIImagePickerControllerSourceType.photoLibrary)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            print("picked")
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func checkMemeInputs() -> Bool {
        /*let toptext_value: String = topText.text!
         let bottomtext_value: String = bottomText.text!
         
         print(toptext_value)
         print(bottomtext_value)
         
         if(toptext_value == "TOP" || toptext_value == ""){
         return false
         }
         if(bottomtext_value == "BOTTOM" || bottomtext_value == ""){
         return false
         }*/
        if(imageView.image == nil){
            return false
        }
        
        return true
    }
    
    
    @IBAction func shareBtnClick(_ sender: Any) {
        let result: Bool = checkMemeInputs()
        if(result == false){
            showAlertController(title: "Missing Data", message: "No image is present")
            return
        }
        else {
            showActivityController()
        }
        
        
    }
    func showActivityController() {
        
            let img: UIImage = generateMemedImage()
            let controller = UIActivityViewController(activityItems: [img], applicationActivities: nil)
            controller.completionWithItemsHandler = {
                (activity, success, items, error) in
                if(success && error == nil){
                    //Do Work
                    self.saveMEME(topText: self.topText.text!, bottomText: self.bottomText.text!, ogIMG: self.imageView.image!, memeIMG: img)
                    dismissPopoverView(view: self)
                }
                else if (error != nil){
                    //log the error
                }
            }
            self.present(controller, animated: true, completion: nil)
        
    }
    
    func showAlertController(title: String, message: String) {
        let controller = UIAlertController()
        controller.title = title
        controller.message = message
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) { action in self.dismiss(animated: true, completion: nil)
        }
        
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func openCamera(_ sender: Any) {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            print("camera exists")
            imgSelect(sourceType: UIImagePickerControllerSourceType.camera)
            
        }
        else {
            showAlertController(title: "Unsuccessful", message: "This Device Does Not Have A Camera")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // print(textField.tag)
        if(textField.tag == 2){
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
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        topBar.isHidden = true
        bottomBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        topBar.isHidden = false
        bottomBar.isHidden = false
        
        return memedImage
    }
    
    
    func saveMEME(topText: String, bottomText: String, ogIMG: UIImage, memeIMG: UIImage){
        let meme = Meme(t: topText, b: bottomText, o: ogIMG, m: memeIMG)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
}

