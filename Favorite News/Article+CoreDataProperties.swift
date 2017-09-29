//
//  Article+CoreDataProperties.swift
//  Favorite News
//
//  Created by Ryan Waite on 9/28/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var byline: String?
    @NSManaged public var headline: String?
    @NSManaged public var snippet: String?
    @NSManaged public var article_id: String?
    @NSManaged public var date: String?
    @NSManaged public var weblink: String?

}
