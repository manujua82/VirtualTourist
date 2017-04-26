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
    
    var blockOperations: [BlockOperation] = []
    
    var pin: Pin?
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?{
        didSet{
            // Whenever the frc changes, we execute the search and
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
        
        guard let album = pin?.photos else {
            print("no exite photos")
            return
        }
        
        print("photos: \(album.count)")
        if album.count == 0 {
            downloadAlbum()
        }
    }

    func configureMap(){
        
        mapView.isScrollEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.isZoomEnabled = false
        
        let location = CLLocationCoordinate2D(
            latitude: (self.pin?.latitude)!,
            longitude: (self.pin?.longitude)!
        )
        
        let region = MKCoordinateRegionMakeWithDistance(location, 9000, 9000)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        self.mapView.addAnnotation(annotation)
    }
    
    func downloadAlbum(){
        FlickrClient.sharedInstance().getPhotosByLocation(latitude: (self.pin?.latitude)!, longitude: (self.pin?.longitude)!, completionHandlerForGetPhotosByLocation: { (result, error) in
            
            if let error = error{
                print("Something is wrong with download: \(error.description)")
            }else{
                print("Downloaded photos:  \(result?.count)")
                
                let stack = self.delegate.stack
                
                stack.performBackgroundBatchOperation({ (workerContext) in
                    Photo.photosFromResults(result!, pin: self.pin!, context: stack.context)
                    
                })
            }
        })
    }

    

    
}

extension PhotoAlbumViewController {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
                print("fc cnt: \(fc.fetchedObjects?.count)")
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}



// MARK: - PhotoAlbumViewController (Collection Data Source)
extension PhotoAlbumViewController:  UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        // Configure the cell
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        cell.imageView?.image = UIImage(data: (photo.photoData as? Data)!)
        
        return cell
    }
    
}


// MARK: - PhotoAlbumViewController: (Fetches)

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        DispatchQueue.main.async {
            let set = IndexSet(integer: sectionIndex)
        
            switch (type) {
            case .insert:
                self.collectionView.insertSections(set)
            case .delete:
                self.collectionView.deleteSections(set)
                //tableView.deleteSections(set, with: .fade)
            default:
                // irrelevant in our case
                break
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        /*DispatchQueue.main.async {
            switch(type) {
                case .insert:
                    self.collectionView.insertItems(at: [newIndexPath!])
                default: break
            
            }
        }*/
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //tableView.endUpdates()
    }

}



