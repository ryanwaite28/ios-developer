//
//  LocationsTableViewController.swift
//  On The Map
//
//  Created by Ryan Waite on 9/19/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit

class LocationsTableViewController: UITableViewController {
    
    var leftBtn: UIBarButtonItem?
    var rightBtn: UIBarButtonItem?
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Left bar button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(updateInfo))
        
        // Right bar button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.reply, target: self, action: #selector(logout))
        
        self.leftBtn = self.navigationItem.leftBarButtonItem
        self.rightBtn = self.navigationItem.rightBarButtonItem
        
        self.navigationItem.title = "Students"
        tableView.reloadData()
    }
    
    //
    
    
    func logout() -> Void {
        leftBtn?.isEnabled = false
        rightBtn?.isEnabled = false
        self.navigationItem.title = "Leaving..."
        
        logoutUser(view: self){(error) in
            performUIUpdatesOnMain {
                self.leftBtn?.isEnabled = true
                self.rightBtn?.isEnabled = true
                
                if error == false {
                    self.navigationItem.title = keys.success
                    dismissPopoverView(view: self.parent!)
                    return
                }
                self.navigationItem.title = "Students"
                showAlertController(view: self, title: "Error", message: "Error Processing...")
            }
        }
        
    }
    
    func updateInfo() -> Void {
        
        viewTOviewStack(baseView: self, targetView: "UpdateInfoViewController")
        
    }
    
    //
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return session.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentInfoCell")!
        let student = session.studentLocations[indexPath.row]
        
        cell.textLabel?.text = student.firstName + " " + student.lastName
        cell.detailTextLabel?.text = student.mapString
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let student = session.studentLocations[indexPath.row]
        openURLaddress(link: student.mediaURL)
        
    }

}
