//
//  MemeSentTableController.swift
//  MemeMe2
//
//  Created by Ryan Waite on 9/18/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit

class MemeSentTableController: UITableViewController {
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let strings = ["this","",""]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.reloadData()
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return appDelegate.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("begin")
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCell")!
        print("get cell")
        let meme = appDelegate.memes[indexPath.row]
        print("got meme")
        
        cell.textLabel?.text = meme.topText + "..." + meme.bottomText
        cell.imageView?.image = meme.memeIMG
        
        print("cell return")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let meme = appDelegate.memes[indexPath.row]
        let memeViewController = self.storyboard!.instantiateViewController(withIdentifier: "MemeView") as! MemeViewController
        memeViewController.meme = meme
        
        self.navigationController!.pushViewController(memeViewController, animated: true)
    }
    
    
}
