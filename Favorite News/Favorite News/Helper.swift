//
//  Helper.swift
//  Favorite News
//
//  Created by Ryan Waite on 9/28/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

public struct vault {
    static let stack = CoreDataStack(modelName: "NewsModel")!
    static let api_key: String = "52ed7b1a514043208bd970208177f48c"
}

public struct presentArticle {
    static var article_id: String = ""
    static var byline: String = ""
    static var date: String = ""
    static var headline: String = ""
    static var snippet: String = ""
    static var weblink: String = ""
    static var ready: Bool = false
}

public struct tempArticle {
    var article_id: String
    var byline: String
    var date: String
    var headline: String
    var snippet: String
    var weblink: String
    
    init(article_id: String, byline: String, date: String, headline: String, snippet: String, weblink: String){
        self.article_id = article_id
        self.byline = byline
        self.date = date
        self.headline = headline
        self.snippet = snippet
        self.weblink = weblink
    }
}

public func requestURLformatter(query: String) -> String {
    return "http://api.nytimes.com/svc/search/v2/articlesearch.json?q=\(query)&sort=newest&api-key=52ed7b1a514043208bd970208177f48c"
}

// since swift took awat cgrectmake, i found this - https://stackoverflow.com/questions/38335046/update-cgrectmake-to-cgrect-in-swift-3-automatically
extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}

// found at - https://coderwall.com/p/su1t1a/ios-customized-activity-indicator-with-swift
// modfied a few things because of new swift 4 syntax
func getActivityIndicator(uiView: UIView) -> UIView {
    var container: UIView = UIView()
    container.frame = uiView.frame
    container.center = uiView.center
    container.backgroundColor = UIColor.black
    container.alpha = 0.5
    
    var loadingView: UIView = UIView()
    loadingView.frame = CGRect(0, 0, 80, 80)
    loadingView.center = uiView.center
    loadingView.backgroundColor = UIColor.black
    loadingView.alpha = 0.5
    loadingView.clipsToBounds = true
    loadingView.layer.cornerRadius = 10
    
    var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    actInd.hidesWhenStopped = true
    actInd.frame = CGRect(0.0, 0.0, 40.0, 40.0);
    actInd.activityIndicatorViewStyle =
        UIActivityIndicatorViewStyle.whiteLarge
    actInd.center = CGPoint(x: loadingView.frame.size.width / 2,
                            y: loadingView.frame.size.height / 2);
    actInd.startAnimating()
    loadingView.addSubview(actInd)
    container.addSubview(loadingView)
    
    return container
    
    // uiView.addSubview(container)
    // actInd.startAnimating()
}

// MARK: HTTP utility function

public func buildRequestObject(view: UIViewController, params: [String:Any]) -> NSMutableURLRequest? {
    
    guard let url = params["url"] else {
        print("[URL] error constructing request object...")
        showAlertController(view: view, title: "Exception", message: "Error Building Request...")
        return nil
    }
    guard let method = params["method"] else {
        print("[METHOD] error constructing request object...")
        showAlertController(view: view, title: "Exception", message: "Error Building Request...")
        return nil
    }
    
    let request = NSMutableURLRequest(url: URL(string: url as! String)!)
    request.httpMethod = method as! String
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let body = params["httpBody"] {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
            request.httpBody = jsonData as Data
        }
        catch {
            print("error constructing request object...")
            return nil
        }
    }
    
    if let headers = params["headers"] {
        let headers = headers as! [String:String]
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
    }
    
    return request
}

public func viewTOviewStack(baseView: UIViewController, targetView: String, Completion callback:  (() -> Void)? = nil) {
    
    let ctrl = baseView.storyboard!.instantiateViewController(withIdentifier: targetView)
    
    if callback != nil {
        baseView.show(ctrl){
            callback!()
        }
    }
    else {
        baseView.show(ctrl, sender: nil)
    }
}
public func viewTOviewPresent(baseView: UIViewController, targetView: String, Completion callback:  (() -> Void)? = nil) {
    
    let ctrl = baseView.storyboard!.instantiateViewController(withIdentifier: targetView)
    
    if callback != nil {
        baseView.present(ctrl, animated: true){
            callback!()
        }
    }
    else {
        baseView.present(ctrl, animated: true)
    }
}


// MARK: Public Alert Controller
public func showAlertController(view: UIViewController, title: String, message: String, Completion callback: (() -> Void)? = nil) {
    let controller = UIAlertController()
    controller.title = title
    controller.message = message
    
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { action in
        if callback != nil {
            callback!()
        }
    }
    
    controller.addAction(okAction)
    view.present(controller, animated: true, completion: nil)
}


// found this code snippet from: https://stackoverflow.com/questions/30743408/check-for-internet-connection-with-swift
public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}
