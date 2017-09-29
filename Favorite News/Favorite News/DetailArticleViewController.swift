//
//  DetailArticleViewController.swift
//  Favorite News
//
//  Created by Ryan Waite on 9/28/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DetailArticleViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var trashBtn: UIBarButtonItem!
    
    @IBAction func returnButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func shareBtnClick(_ sender: Any) {
        let message: String = "Check out this article - \(presentArticle.weblink)"
        let controller = UIActivityViewController(activityItems: [message, URL(string: presentArticle.weblink)], applicationActivities: nil)
        controller.completionWithItemsHandler = {
            (activity, success, items, error) in
            if(success && error == nil){
                //Do Work
                showAlertController(view: self, title: "Success", message: "Message Shared")
            }
            else if (error != nil){
                //log the error
            }
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func saveBtnClick(_ sender: Any) {
        toggleSaveDeleteArticle()
    }
    @IBAction func trashBtnClick(_ sender: Any) {
        toggleSaveDeleteArticle()
    }
    @IBAction func openLinkBtn(_ sender: Any) {
        openURLaddress(link: presentArticle.weblink)
    }
    
    // Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        headingLabel.text = presentArticle.headline
         authorLabel.text = presentArticle.byline
         dateLabel.text = presentArticle.date
         summaryLabel.text = presentArticle.snippet
        
        let article: Article? = searchFavsBy_id(id: presentArticle.article_id)
        if article == nil { // article not in memory
            self.saveBtn.isEnabled = true
            self.trashBtn.isEnabled = false
        }
        else {
            self.saveBtn.isEnabled = false
            self.trashBtn.isEnabled = true
        }
    }
    
    //
    
    public func openURLaddress(link: String) {
        let url = URL(string: link)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func searchFavsBy_id(id: String) -> Article? {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        fr.predicate = NSPredicate(format: "article_id == %@", id)
        fr.sortDescriptors = []
        
        do {
            let res = try vault.stack.context.fetch(fr) as! [Article]
            if let article = res.first {
                return article
            }
            else {
                print("article does not exist in memory")
                return nil
            }
        }
        catch {
            fatalError("Failed to fetch article: \(error)")
        }
    }
    
    func toggleSaveDeleteArticle(){
        let article: Article? = searchFavsBy_id(id: presentArticle.article_id)
        if article == nil { // article not in memory
            Article(article_id: presentArticle.article_id, byline: presentArticle.byline, date: presentArticle.date, headline: presentArticle.headline, snippet: presentArticle.snippet, weblink: presentArticle.weblink, context: vault.stack.context)
            vault.stack.save()
            
            showAlertController(view: self, title: "Success", message: "Article Saved!")
            self.saveBtn.isEnabled = false
            self.trashBtn.isEnabled = true
        }
        else {
            vault.stack.context.delete(article!)
            vault.stack.save()
            
            showAlertController(view: self, title: "Success", message: "Article Deleted!")
            self.saveBtn.isEnabled = true
            self.trashBtn.isEnabled = false
        }
    }
}
