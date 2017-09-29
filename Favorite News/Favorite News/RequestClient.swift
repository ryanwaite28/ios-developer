//
//  RequestClient.swift
//  Favorite News
//
//  Created by Ryan Waite on 9/29/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit

final class API {
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    
    static let shared = API()
    
    // MARK: Local Variable
    
    func httpRequest(view: UIViewController, requestDICT: [String:Any], Completion callback: @escaping (_ Error: Bool, _ Data: [String:AnyObject]?) -> Void) {
        
        // check for required key
        guard requestDICT["request"] != nil else {
            showAlertController(view: view, title: "Missing Data", message: "Request was not given...")
            return
        }
        
        let task = URLSession.shared.dataTask(with: requestDICT["request"] as! URLRequest) {(data, resp, error) in
            if error != nil { // Handle error…
                callback(true, nil)
                return
            }
            
            print("data: \(data) --- error: \(error) ---")
            let range = Range(5..<data!.count)
            let newData = data!.subdata(in: range) /* subset response data! */
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            var parsedResult: [String:AnyObject]!
            do {
                // Try to parse with root as dictionary
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
                callback(false, parsedResult)
                return
            } catch {
                do {
                    // lets try the original data format
                    print("First parse attempt failed. Trying to parse again")
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                    callback(false, parsedResult)
                    return
                }
                catch {
                    print("Could not parse the data as JSON: '\(parsedResult)'")
                    callback(true, nil)
                }
            }
        }
        task.resume()
        
    }
    
}
