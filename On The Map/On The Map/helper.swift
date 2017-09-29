//
//  helper.swift
//  On The Map
//
//  Created by Ryan Waite on 9/21/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit
import MapKit


public struct keys {
    static let error: String = "Error"
    static let success: String = "Success"
    static let update: String = "Update"
    static let create: String = "Create"
}

public struct session {
    static var annotations = [MKPointAnnotation]()
    static var studentLocations = [Student]()
    static var accountKey: String = ""
    static var sessionID: String = ""
    static var objID: String = ""
    static var uniqueKey: String = ""
    static var you: Student?
    static var dataExists: Bool = false // previous user data
    
    static var tempLat: Double = 0.0
    static var tempLng: Double = 0.0
    static var tempLocation: String = ""
}

// public user struct
public struct Student {
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    var createdAt: String
    var updatedAt: String
    
    init(dict: [String:Any]) {
        self.objectId = dict["objectId"] as! String
        self.uniqueKey = dict["uniqueKey"] as! String
        self.firstName = dict["firstName"] as! String
        self.lastName = dict["lastName"] as! String
        self.mapString = dict["mapString"] as! String
        self.mediaURL = dict["mediaURL"] as! String
        self.latitude = dict["latitude"] as! Double
        self.longitude = dict["longitude"] as! Double
        self.createdAt = dict["createdAt"] as! String
        self.updatedAt = dict["updatedAt"] as! String
    }
    
    mutating func update(dict: [String:Any]) {
        self.objectId = dict["objectId"] as! String
        self.uniqueKey = dict["uniqueKey"] as! String
        self.firstName = dict["firstName"] as! String
        self.lastName = dict["lastName"] as! String
        self.mapString = dict["mapString"] as! String
        self.mediaURL = dict["mediaURL"] as! String
        self.latitude = dict["latitude"] as! Double
        self.longitude = dict["longitude"] as! Double
        self.createdAt = dict["createdAt"] as! String
        self.updatedAt = dict["updatedAt"] as! String
    }
}
