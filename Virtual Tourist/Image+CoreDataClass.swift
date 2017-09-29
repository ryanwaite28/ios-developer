//
//  Image+CoreDataClass.swift
//  My Virtual Tourist
//
//  Created by Ryan Waite on 9/28/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import CoreData

@objc(Image)
public class Image: NSManagedObject {
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(creationdate: Date, databytes: NSData? = nil, originlink: String, ownerLat: Double, ownerLng: Double, place: Place, context: NSManagedObjectContext) {
        let ent = NSEntityDescription.entity(forEntityName: "Image", in: context)
        super.init(entity: ent!, insertInto: context)
        
        self.place = place
        self.creationdate = creationdate as NSDate
        self.databytes = databytes
        self.originlink = originlink
        self.ownerLat = ownerLat
        self.ownerLng = ownerLng
    }
    
}
