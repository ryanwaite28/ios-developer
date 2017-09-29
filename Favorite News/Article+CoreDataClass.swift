//
//  Article+CoreDataClass.swift
//  Favorite News
//
//  Created by Ryan Waite on 9/28/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Article)
public class Article: NSManagedObject {
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(article_id: String, byline: String, date: String, headline: String, snippet: String, weblink: String, context: NSManagedObjectContext) {
        let ent = NSEntityDescription.entity(forEntityName: "Article", in: context)!
        super.init(entity: ent, insertInto: context)
        
        self.article_id = article_id
        self.byline = byline
        self.date = date
        self.headline = headline
        self.snippet = snippet
        self.weblink = weblink
    }
}
