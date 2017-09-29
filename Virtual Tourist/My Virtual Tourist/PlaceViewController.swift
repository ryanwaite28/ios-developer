//
//  PinViewController.swift
//  My Virtual Tourist
//
//  Created by Ryan Waite on 9/26/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreData

class PlaceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, MKMapViewDelegate, UICollectionViewDelegateFlowLayout {

    var place: Place?
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>! = {
    
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: entityNames.image)
        fr.predicate = NSPredicate(format: "place == %@", self.place!)
        fr.sortDescriptors = [NSSortDescriptor(key: "creationdate", ascending: false)]
        
        let fetchCtrl = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: session.stack.context!, sectionNameKeyPath: nil, cacheName: nil)
        fetchCtrl.delegate = self
        
        return fetchCtrl
    }()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newAlbumBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func returnBtnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout: UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let screenWidth = UIScreen.main.bounds.width
        
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        flowLayout.itemSize = CGSize(width: screenWidth/4, height: screenWidth/4)
        
        self.navigationItem.title = "Place"
        self.collectionView.delegate = self
        self.mapView.delegate = self
        
        var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
        
        let lat = CLLocationDegrees(place!.lat)
        let long = CLLocationDegrees(place!.lng)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotations.append(annotation)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7))
        
        self.mapView.addAnnotations(annotations)
        self.mapView.setCenter(coordinate, animated: true)
        self.mapView.setRegion(region, animated: true)
        
        try! fetchedResultsController.performFetch()
        self.collectionView.reloadData()
    }
    
    //
    
    @IBAction func newAlbumBtnClick(_ sender: Any) {
        self.navigationItem.title = "Updating..."
        self.newAlbumBtn.isEnabled = false
        let images = fetchedResultsController.fetchedObjects as! [Image]
        for image in images {
            session.stack.context.delete(image)
        }
        self.place!.hasPhotos = false
        session.stack.save()
        
        let paths = self.collectionView.indexPathsForVisibleItems
        for path in paths {
            let cell = collectionView.cellForItem(at: path) as! PhotoCellView
            cell.activityIndicator.startAnimating()
            cell.imageView.image = UIImage(named: "empty")
        }
        
        getPhotosFromLatLng(place: self.place!, lat: self.place!.lat, lng: self.place!.lng){(error, linklist) in
            print("error in adding place - \(error)")
            
            if error == false {
                // if all went well, save the changes
                DispatchQueue.global(qos: .background).async {
                    DispatchQueue.main.async {
                        for link in linklist! {
                            Image(creationdate: Date(), databytes: nil, originlink: link, ownerLat: self.place!.lat, ownerLng: self.place!.lng, place: self.place!, context: session.stack.context)
                        }
                        
                        self.navigationItem.title = "Place"
                        self.place!.hasPhotos = true
                        session.stack.save()
                        
                        self.newAlbumBtn.isEnabled = true
                        try! self.fetchedResultsController.performFetch()
                        self.collectionView.reloadData()
                    }
                }
            }
        }
        
        
        
    }
    
    //
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let count = fetchedResultsController.fetchedObjects!.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = fetchedResultsController!.object(at: indexPath) as? Image
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCellView
        
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.startAnimating()
        
        if let image = image{
            if image.databytes != nil {
                cell.activityIndicator.stopAnimating()
                cell.imageView.image = UIImage(data: image.databytes! as Data)
            }
            else {
                print("getting img for... \(image.objectID)")
                downloadImage(img: image){
                    cell.activityIndicator.stopAnimating()
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }
        else {
            cell.imageView.image = UIImage(named: "empty")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = fetchedResultsController!.object(at: indexPath) as! Image
        session.stack.context.delete(image)
        session.stack.save()
        try! self.fetchedResultsController.performFetch()
        self.collectionView.reloadData()
    }
    
}
