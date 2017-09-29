//
//  Vault.swift
//  My Virtual Tourist
//
//  Created by Ryan Waite on 9/25/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
import SystemConfiguration

public struct session {
    static var appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let stack = CoreDataStack(modelName: "TourSpot")!
}

public struct entityNames {
    static let place = "Place"
    static let image = "Image"
}

public func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}

public func getPhotosFromLatLng(place: Place, lat: Double, lng: Double, Completion callback: @escaping (_ error: Bool, _ list: [String]?) -> Void) {
    let nums: [Int] = [1,2,3,4,5,6,7,8,9]
    let random = Int(arc4random_uniform(UInt32(nums.count)))
    
    // prepare the request
    let api_url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3909720ecbeba83d318a1dd0a7578f03&lat=\(lat)&lon=\(lng)&extras=url_m&page=\(random)&per_page=18&format=json&nojsoncallback=1"
    
    var request = URLRequest(url: URL(string: api_url)!)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let task = URLSession.shared.dataTask(with: request) {(data, resp, error) in
        if error != nil { // Handle error…
            callback(true, nil)
            return
        }
        
        print("data: \(data) --- error: \(error) ---")
        let range = Range(5..<data!.count)
        let newData = data!.subdata(in: range) /* subset response data! */
        print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
        
        // parse the result
        var parsedResult: [String:AnyObject]!
        do {
            // Try to parse with root as dictionary
            parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            return
        } catch {
            do {
                // lets try the original data format
                print("First parse attempt failed. Trying to parse again")
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            }
            catch {
                print("Could not parse the data as JSON: '\(parsedResult)'")
                callback(true, nil)
            }
        }
        
        // download images for the pin
        if let photosDict = parsedResult["photos"] as? [String:AnyObject], let photoArray = photosDict["photo"] as? [[String:AnyObject]] {
            
            var linklist: [String] = [String]()
            
            for photo_dict in photoArray {
                if let imageUrlString = photo_dict["url_m"] as? String {
                    linklist.append(imageUrlString)
                }
            }
            callback(false, linklist)
            
            
        }
    }
    task.resume()
    
}

//It downloads the images from the already saved image paths to be in turn saved too in the CoreData
public func downloadImage(img: Image, completionHandler: @escaping () -> Void){
    let Session = URLSession.shared
    let imgURL = NSURL(string: img.originlink!)
    let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
    let task = Session.dataTask(with: request as URLRequest) {data, response, downloadError in
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                img.databytes = data! as NSData
                session.stack.save()
                completionHandler()
            }
        }
    }
    task.resume()
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
