//
//  FavsViewController.swift
//  Favorite News
//
//  Created by Ryan Waite on 9/28/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FavsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var favoriteArticlesList: [Article]!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Favorite Articles"
        tableView.delegate = self
        
        setFavoriteArticles()
    }
    
    func setFavoriteArticles() {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        fr.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: vault.stack.context!, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        try! fetchedResultsController.performFetch()
        tableView.reloadData()
    }
    
    func getFavoriteArticles() -> [Article]? {
        let articlesFetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Article")
        
        do {
            let articles = try vault.stack.context.fetch(articlesFetch) as! [Article]
            return articles
        } catch {
            fatalError("Failed to fetch articles: \(error)")
        }
    }
    
    //
    
    // MARK: Table Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("articles count - \(articlesList.count)")
        return fetchedResultsController.fetchedObjects!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell")!
        let article = fetchedResultsController!.object(at: indexPath) as! Article
        
        cell.textLabel?.text = article.headline
        cell.detailTextLabel?.text = article.date
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = fetchedResultsController!.object(at: indexPath) as! Article
        
        presentArticle.article_id = article.article_id!
        presentArticle.byline = article.byline!
        presentArticle.date = article.date!
        presentArticle.headline = article.headline!
        presentArticle.snippet = article.snippet!
        presentArticle.weblink = article.weblink!
        presentArticle.ready = true
        
        let detailArticleView = self.storyboard!.instantiateViewController(withIdentifier: "DetailArticleViewController")
        self.present(detailArticleView, animated: true, completion: nil)
    }
    
}
