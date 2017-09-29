//
//  Vault.swift
//  On The Map
//
//  Created by Ryan Waite on 9/19/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import SystemConfiguration
import Foundation
import UIKit
import CoreLocation
import MapKit

/*
 The following function makes HTTP requests
 and passes the results/data in the callback
 to the function that called this
 
 They even takes a View Controller as an argument
 so the function knows what controller called it
 */

// MARK: HTTP utility function
public func httpRequest(view: UIViewController, requestDICT: [String:Any], Completion callback: @escaping (_ Error: Bool, _ Data: [String:AnyObject]?) -> Void) {

    // check for required key
    guard requestDICT["request"] != nil else {
        showAlertController(view: view, title: "Missing Data", message: "Request was not given...")
        return
    }
    
    //
    
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


// MARK: dissmiss popover utility
public func dismissPopoverView(view: UIViewController) {
    view.dismiss(animated: true, completion: {() -> Void in
        
    })
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

public func alertASK(view: UIViewController, title: String, message: String, optionONE: String, optionTWO: String, Completion callback:@escaping (_ resp: String) -> Void) {
    let controller = UIAlertController()
    controller.title = title
    controller.message = message
    
    let okAction = UIAlertAction(title: optionONE, style: UIAlertActionStyle.default) { action in
        callback(optionONE)
    }
    let cancelAction = UIAlertAction(title: optionTWO, style: UIAlertActionStyle.default) { action in
        callback(optionTWO)
    }
    
    controller.addAction(okAction)
    controller.addAction(cancelAction)
    view.present(controller, animated: true, completion: {() in
       
    })
}

// Logs In User
public func loginUser(view: UIViewController, email: String, pswrd: String, Completion callback: @escaping (_ infoDICT: [String:String]) -> Void) {
    
    var reqDICT: [String: Any] = [String:Any]()
    
    reqDICT["url"] = "https://www.udacity.com/api/session"
    reqDICT["method"] = "POST"
    reqDICT["httpBody"] = [
        "udacity": [
            "username": escapeString(value: email),
            "password": escapeString(value: pswrd)
        ]
    ]
    let request = NSMutableURLRequest(url: URL(string: reqDICT["url"] as! String)!)
    request.httpMethod = reqDICT["method"] as! String
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    do {
        let jsonData: Data = try JSONSerialization.data(withJSONObject: reqDICT["httpBody"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
        request.httpBody = jsonData as Data
    }
    catch {
        print("error constructing request object")
        
        showAlertController(view: view, title: "Exception", message: "Error Processing Data...")
        return
    }
    reqDICT["request"] = request
    
    // send the request
    httpRequest(view: view, requestDICT: reqDICT) {(error, data) in
        var infoDict: [String:String] = [String:String]()
        
        if error == true { // Handle error…
            infoDict["result"] = keys.error
            callback(infoDict)
            return
        }
        
            if data != nil {
                if let accountKey = data?["account"]?["key"], let sessionID = data?["session"]?["id"] {
                    infoDict["result"] = keys.success
                    session.accountKey = accountKey as! String
                    session.sessionID = sessionID as! String
                    
                    // protecting nil keys, usually first time users.
                    let newDICT: [String:Any] = [
                        "objectId": "",
                        "uniqueKey": accountKey as! String,
                        "firstName": "",
                        "lastName": "",
                        "mapString": "",
                        "mediaURL": "",
                        "latitude": 0.0,
                        "longitude": 0.0,
                        "createdAt": "",
                        "updatedAt": ""
                    ]
                    
                    let newStudent = Student(dict: newDICT)
                    session.you = newStudent
                    session.studentLocations.append(session.you!)
                    
                    callback(infoDict)
                    return
                }
                else {
                    print("Could not deep parse the data as JSON: '\(String(describing: data))'")
                    infoDict["result"] = keys.error
                    callback(infoDict)
                }
            }
        
        
    }
    
}
public func getStudentLocation(view: UIViewController, key: String, Completion callback: @escaping (_ Error: Bool) -> Void) {
    
    var reqDICT: [String: Any] = [String:Any]()
    
    reqDICT["url"] = "https://parse.udacity.com/parse/classes/StudentLocation?where={\"uniqueKey\":\"\(key)\"}"
    reqDICT["method"] = "GET"
    let request = NSMutableURLRequest(url: URL(string: escapeString(value: reqDICT["url"] as! String))!)
    request.httpMethod = reqDICT["method"] as! String
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
    reqDICT["request"] = request
    
    httpRequest(view: view, requestDICT: reqDICT) {(error, data) in
        print("error: \(error) ; data: \(data!)")
        
        if let results = data!["results"], results.count > 0 {
            let Res = results as! [[String:AnyObject]]
            let student = Res[0] as AnyObject
            
            print("student: \(student) --- results exist: \(results.count) --- results: \(results)")
            
            // protecting nil keys, usually first time users.
            let newDICT: [String:Any] = [
                "objectId": student["objectId"] as? String ?? "",
                "uniqueKey": student["uniqueKey"] as? String ?? "",
                "firstName": student["firstName"] as? String ?? "",
                "lastName": student["lastName"] as? String ?? "",
                "mapString": student["mapString"] as? String ?? "",
                "mediaURL": student["mediaURL"] as? String ?? "",
                "latitude": student["latitude"] as? Double ?? 0.0,
                "longitude": student["longitude"] as? Double ?? 0.0,
                "createdAt": student["createdAt"] as? String ?? "",
                "updatedAt": student["updatedAt"] as? String ?? ""
            ]
            
            session.you!.update(dict: newDICT)
            session.studentLocations[0] = session.you!
            session.objID = student["objectId"] as! String
            
            session.dataExists = true
            
        }
        else {
            session.dataExists = false
        }
        
        callback(error)
    }
    
}

// Logs out User
public func logoutUser(view: UIViewController, Completion callback: @escaping (_ Error: Bool) -> Void) {

    var reqDICT: [String: Any] = [String:Any]()
    
    reqDICT["url"] = "https://www.udacity.com/api/session"
    reqDICT["method"] = "DELETE"
    let request = NSMutableURLRequest(url: URL(string: reqDICT["url"] as! String)!)
    request.httpMethod = reqDICT["method"] as! String
    var xsrfCookie: HTTPCookie? = nil
    let sharedCookieStorage = HTTPCookieStorage.shared
    for cookie in sharedCookieStorage.cookies! {
        if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
    }
    if let xsrfCookie = xsrfCookie {
        request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
    }
    reqDICT["request"] = request

    httpRequest(view: view, requestDICT: reqDICT){(error, data) in
        session.studentLocations = [Student]()
        session.you = nil
        callback(error)
    }
    
}

// update user info
public func modifyUserLocation(view: UIViewController, action: String, location: String, link: String, fname: String, lname: String, lat: Double, lng: Double, Completion callback: @escaping (_ Error: Bool) -> Void) {
    var reqDICT: [String: Any] = [String:Any]()
    
    if(action == keys.update) {
        reqDICT["url"] = "https://parse.udacity.com/parse/classes/StudentLocation/\(session.objID)"
        reqDICT["method"] = "PUT"
    }
    else if(action == keys.create) {
        reqDICT["url"] = "https://parse.udacity.com/parse/classes/StudentLocation/"
        reqDICT["method"] = "POST"
    }
    else {
        print("unknown action...")
    }
    
    reqDICT["httpBody"] = [
        "uniqueKey": session.accountKey,
        "mapString": location,
        "mediaURL": link,
        "firstName" : escapeString(value: fname),
        "lastName": escapeString(value: lname),
        "latitude": lat,
        "longitude": lng
    ]
    let request = NSMutableURLRequest(url: URL(string: reqDICT["url"] as! String)!)
    request.httpMethod = reqDICT["method"] as! String
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    do {
        let jsonData: Data = try JSONSerialization.data(withJSONObject: reqDICT["httpBody"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
        request.httpBody = jsonData as Data
    }
    catch {
        print("error constructing request object")
        return
    }
    reqDICT["request"] = request
    
    httpRequest(view: view, requestDICT: reqDICT) {(error, data) in
        print("Modifications: \(data!)")
        let Data = data!
        
        session.you!.mapString = location
        session.you!.mediaURL = link
        session.you!.firstName = fname
        session.you!.lastName = lname
        session.you!.latitude = lat
        session.you!.longitude = lng
        
        if(action == keys.update) {
            session.you!.updatedAt = Data["updatedAt"] as! String
        }
        else if(action == keys.create) {
            session.you!.createdAt = Data["createdAt"] as! String
            session.you!.objectId = Data["objectId"] as! String
        }
        
        session.studentLocations[0] = session.you!
        
        callback(error)
        
    }
    
}

// Load student locations
public func getStudentLocations(view: UIViewController, Completion callback: @escaping (_ Error: Bool, _ Data: [String:AnyObject]?) -> Void) {
    var reqDICT: [String: Any] = [String:Any]()
    
    reqDICT["url"] = "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt"
    reqDICT["method"] = "GET"
    
    let request = NSMutableURLRequest(url: URL(string: reqDICT["url"] as! String)!)
    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
    reqDICT["request"] = request
    
    httpRequest(view: view, requestDICT: reqDICT){(error, data) in
        
        callback(error, data)
    }
}

// Load student locations

public func setLocationsToSession(view: UIViewController, Completion callback: @escaping (_ status: String) -> Void) {
    getStudentLocations(view: view){(error, data) in
        print("setting session --- data: \(data!)")
        
        if let results = data!["results"] {
            for student in results as! [AnyObject] {
                // check the object for the required keys/subscripts
                if let objectId = student["objectId"], let uniqueKey = student["uniqueKey"], let fname = student["firstName"], let lname = student["lastName"], let mapString = student["mapString"], let mediaURL = student["mediaURL"], let lat = student["latitude"], let lng = student["longitude"], let createdAt = student["createdAt"], let updatedAt = student["updatedAt"] {
                    // some other students are forgetting to POST/PUT the required key-value pairs in their request(s), 
                    // and it breaks my code/app. So this is why i have all of these optional defaults
                    guard objectId != nil, uniqueKey != nil, fname != nil, lname != nil, mapString != nil, mediaURL != nil, lat != nil, lng != nil, createdAt != nil, updatedAt != nil else {
                        continue
                    }
                    if(fname as! String == "" || lname as! String == "" || uniqueKey as! String == session.accountKey) {
                        // ignore the bad ones, and possible duplicates of your own. 
                        // the code already got yours and set it as the first in the list
                        continue
                    }
                    let newDICT: [String:Any] = [
                        "objectId": objectId as! String,
                        "uniqueKey": uniqueKey as! String,
                        "firstName": fname as! String,
                        "lastName": lname as! String,
                        "mapString": mapString as! String,
                        "mediaURL": mediaURL as? String ?? "",
                        "latitude": lat as? Double ?? 0.0,
                        "longitude": lng as? Double ?? 0.0,
                        "createdAt": createdAt as? String ?? "",
                        "updatedAt": updatedAt as? String ?? ""
                    ]
                    let newStudent = Student(dict: newDICT)
                    session.studentLocations.append(newStudent)
                }
                else {
                    continue
                }
                
            }
        }
        else {
            let value = keys.error
            callback(value)
        }
        
        let value = error == true ? keys.error : keys.success
        callback(value)
    }
}


// MARK: Public Activity Controller
public func showActivityController(view: UIViewController, data: Any) {
    
    let controller = UIActivityViewController(activityItems: [data], applicationActivities: nil)
    controller.completionWithItemsHandler = {
        (activity, success, items, error) in
        if(success && error == nil){
            //Do Work
            dismissPopoverView(view: view)
        }
        else if (error != nil){
            //log the error
        }
    }
    view.present(controller, animated: true, completion: nil)
    
}

public func escapeString(value: String) -> String {
    // string it
    let stringValue = "\(value)"
    
    // escape it
    let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    
    // return it
    return escapedValue!
}

public func configButtonEnable(btn: UIButton, state: Bool) -> Void {
    btn.isEnabled = state
}

// Perform UI updates on the main thread
public func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

// Open url - found code snippet at: 
public func openURLaddress(link: String) {
    let url = URL(string: link)!
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
}

public func refreshAnnotation(map: MKMapView, old_a: MKPointAnnotation, new_a: MKPointAnnotation) {
    
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
