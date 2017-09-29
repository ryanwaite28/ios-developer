//
//  SearchViewController.swift
//  Favorite News
//
//  Created by Ryan Waite on 9/28/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {
    
    var articlesList: [tempArticle] = [tempArticle]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Search Articles"
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    //
    
    @objc func keyboardWillShow(_ notification:Notification) {

    }
    @objc func keyboardWillHide(_ notification:Notification){

    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:))    , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:))    , name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func escapeString(value: String) -> String {
        // string it
        let stringValue = "\(value)"
        
        // escape it
        let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        // return it
        return escapedValue!
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard searchBar.text != "" else {
            return
        }
        guard searchBar.text != nil else {
            return
        }
        
        searchArticles(query: escapeString(value: searchBar.text!))
    }
    
    func searchArticles(query: String) {
        // found this code snippet from: https://stackoverflow.com/questions/30743408/check-for-internet-connection-with-swift
        if !Reachability.isConnectedToNetwork() {
            showAlertController(view: self, title: "No Internet", message: "This App Requires An Internet Connection")
            return
        }
        print("Internet Connected")
        self.navigationItem.title = "Loading..."
        let overlay = getActivityIndicator(uiView: self.navigationController!.view)
        self.view.addSubview(overlay)
        
        var requestDICT: [String:Any] = [
            "url": requestURLformatter(query: query),
            "method": "GET"
        ]
        let request = buildRequestObject(view: self, params: requestDICT)
        requestDICT["request"] = request
        
        API.shared.httpRequest(view: self, requestDICT: requestDICT, Completion: {(error, data) in
            print("error - \(error)")
            if let resp = data!["response"], let docs = resp["docs"] {
                print("unwrapping...")
                self.articlesList.removeAll()
                for doc in docs as! [[String:AnyObject]] {
                    // print("doc - \(doc)")
                    
                    if let article_id = doc["_id"],
                    let byline = doc["byline"]?["original"],
                    let date = doc["pub_date"],
                    let headline = doc["headline"]?["main"],
                    let snippet = doc["snippet"],
                    let weblink = doc["web_url"] {
                        guard byline != nil else {
                                continue
                        }
                        let temp = tempArticle(article_id: article_id as! String, byline: byline as? String ?? "author not stated...", date: date as! String, headline: headline as! String, snippet: snippet as! String, weblink: weblink as! String)
                        
                        self.articlesList.append(temp)
                    }
                    else {
                        continue
                    }
                    
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    overlay.removeFromSuperview()
                    self.navigationItem.title = "Search Articles"
                    print("articles: \(self.articlesList) - count: \(self.articlesList.count)")
                    print("reload...")
                }
            }
            else {
                DispatchQueue.main.async {
                    overlay.removeFromSuperview()
                    self.navigationItem.title = "Search Articles"
                    showAlertController(view: self, title: "Empty", message: "No Results...")
                    print("unwrap error...")
                }
            }
        })
    }
    
    // MARK: Table Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("articles count - \(articlesList.count)")
        return articlesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell")!
        let article = articlesList[indexPath.row]
        
        cell.textLabel?.text = article.headline
        cell.detailTextLabel?.text = article.date
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articlesList[indexPath.row]
        
        presentArticle.article_id = article.article_id
        presentArticle.byline = article.byline
        presentArticle.date = article.date
        presentArticle.headline = article.headline
        presentArticle.snippet = article.snippet
        presentArticle.weblink = article.weblink
        presentArticle.ready = true
        
        let detailArticleView = self.storyboard!.instantiateViewController(withIdentifier: "DetailArticleViewController")
        self.present(detailArticleView, animated: true, completion: nil)
    }
    
}
