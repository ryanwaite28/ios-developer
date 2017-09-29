//
//  vault.swift
//  MemeMe2
//
//  Created by Ryan Waite on 9/18/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import UIKit

public struct Meme {
    var topText: String
    var bottomText: String
    var ogIMG: UIImage
    var memeIMG: UIImage
    
    init(t: String, b: String, o: UIImage, m: UIImage){
        self.topText = t
        self.bottomText = b
        self.ogIMG = o
        self.memeIMG = m
    }
}

public func dismissPopoverView(view: UIViewController) {
    view.dismiss(animated: true, completion: {() -> Void in
        
    })
}
