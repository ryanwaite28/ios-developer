//
//  Place+CoreDataClass.swift
//  My Virtual Tourist
//
//  Created by Ryan Waite on 9/28/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Place)
public class Place: NSManagedObject {
    
    var coords: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lat, lng)
    }
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(title: String, lat: Double, lng: Double, context: NSManagedObjectContext) {
        let ent = NSEntityDescription.entity(forEntityName: entityNames.place, in: context)
        super.init(entity: ent!, insertInto: context)
        
        self.title = title
        self.lat = lat
        self.lng = lng
        self.hasPhotos = false
    }
}
