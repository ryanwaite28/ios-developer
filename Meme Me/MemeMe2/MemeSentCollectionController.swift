//
//  MemeSentCollectionController.swift
//  MemeMe2
//
//  Created by Ryan Waite on 9/18/17.
//  Copyright © 2017 Ryan Waite. All rights reserved.
//

import Foundation
import UIKit

class MemeSentCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        collectionView!.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return appDelegate.memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionCell", for: indexPath) as! MemeCollectionViewCell
   
        let meme = appDelegate.memes[indexPath.row]
        cell.cellImage.image = meme.memeIMG
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let meme = appDelegate.memes[indexPath.row]
        let memeViewController = self.storyboard!.instantiateViewController(withIdentifier: "MemeView") as! MemeViewController
        memeViewController.meme = meme
        
        self.navigationController!.pushViewController(memeViewController, animated: true)
    }

    
}
