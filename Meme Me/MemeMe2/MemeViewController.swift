//
//  MemeViewController.swift
//  MemeMe2
//
//  Created by Ryan Waite on 9/18/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit

class MemeViewController: UIViewController {
    
    var meme: Meme!
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(shareMeme))
        
        self.imageView.image = meme.memeIMG
        self.imageView.contentMode = .scaleAspectFit
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func closeBtnClick(_ sender: Any) {
        dismissPopoverView(view: self)
    }
    @IBAction func shareBtnClick(_ sender: Any) {
        shareMeme()
    }
    
    func shareMeme() {
        let img = self.meme.memeIMG
        let controller = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        controller.completionWithItemsHandler = {
            (activity, success, items, error) in
            if(success && error == nil){
                //Do Work

            }
            else if (error != nil){
                //log the error
            }
        }
        self.present(controller, animated: true, completion: nil)
    }
    
}
