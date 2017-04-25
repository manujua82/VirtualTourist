//
//  PhotoAlbumViewController.swift
//  VirtualTouristPortfolio
//
//  Created by Juan Salcedo on 4/25/17.
//  Copyright © 2017 Juan Salcedo. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.isScrollEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.isZoomEnabled = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - PhotoAlbumViewController (Collection Data Source)
extension PhotoAlbumViewController:  UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //if let fc = fetchedResultsController {
        //    return (fc.sections?.count)!
        //} else {
            return 0
        //}
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if let fc = fetchedResultsController {
        //    return fc.sections![section].numberOfObjects
       // } else {
            return 0
       // }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        // Configure the cell
        //let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        //cell.imageView?.image = UIImage(data: (photo.photoData as? Data)!)
        
        
        
        return cell
    }
    
}

