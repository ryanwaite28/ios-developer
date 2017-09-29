//
//  Image+CoreDataProperties.swift
//  My Virtual Tourist
//
//  Created by Ryan Waite on 9/28/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var creationdate: NSDate?
    @NSManaged public var databytes: NSData?
    @NSManaged public var originlink: String?
    @NSManaged public var ownerLat: Double
    @NSManaged public var ownerLng: Double
    @NSManaged public var place: Place?

}
