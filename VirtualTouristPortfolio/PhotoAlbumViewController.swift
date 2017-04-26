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

class PhotoAlbumViewController: CoreDataCollectionViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var pin: Pin?
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
            downloadImages()
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
    
    
    /*func downloadAlbum(){
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
    }*/
    
    
    func downloadImages(){
        
        FlickrClient.sharedInstance().getPhotosByLocation(latitude: (self.pin?.latitude)!, longitude: (self.pin?.longitude)!, completionHandlerForGetPhotosByLocation: { (result, error) in
            
            if let error = error{
                print("Something is wrong with download: \(error.description)")
            }else{
                let stack = self.delegate.stack
                
                
                if (result?.count)! > 0 {
                    
                    stack.performBackgroundBatchOperation({ (workerContext) in
                        
                        
                        /*var pin_select: Pin?
                        let pins = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                        pins.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                                                NSSortDescriptor(key: "longitude", ascending: false)]
                        
                        let pred = NSPredicate(format: "latitude = %@ AND longitude = %@", argumentArray: [self.pin?.latitude, self.pin?.longitude])
                        pins.predicate = pred
                        
                        
                        // Create FetchedResultsController
                        let fc = NSFetchedResultsController(fetchRequest: pins, managedObjectContext:workerContext, sectionNameKeyPath: nil, cacheName: nil)
                        
                        do {
                            try fc.performFetch()
                            if((fc.fetchedObjects?.count)! > 0 ){
                                pin_select = fc.fetchedObjects?[0] as? Pin
                            }
                            
                        } catch let e as NSError {
                            print("Error while trying to perform a search: ")
                        }*/
                        

                        Photo.photosFromResults(result!, pin: self.pin!, context: stack.context)
                        
                    })
                }
                    /*var numberOfImages = result?.count
                    let placeHolder  = UIImage(named: "placeholder")
                    let data = UIImagePNGRepresentation(placeHolder!)! as NSData
                    
                    var photos = [Photo]()
                    //var arrayOfImagesToDownload =  [Photo]()
                    stack.performBackgroundBatchOperation({ (workerContext) in
                    
                        repeat
                        {
                            let imageWithPlaceHolder = Photo(photoData: data, context: stack.context)
                            imageWithPlaceHolder.pin = self.pin!
                            
                        
                            photos.append(imageWithPlaceHolder)
                            //arrayOfImagesToDownload.append(imageWithPlaceHolder)
                            numberOfImages = numberOfImages! - 1
                        }while numberOfImages! > 0
                    })
                    
                    
                    print("Qty of photos: \(photos.count)")
                    //Photo.downloadImages(from: result!, withPin: self.pin!, to: arrayOfImagesToDownload)
                }*/

            }
            
        })
    } 
}

// MARK: - PhotoAlbumViewController (Collection Data Source)
extension PhotoAlbumViewController {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        // Configure the cell
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        cell.imageView?.image = UIImage(data: (photo.photoData as? Data)!)
        
        return cell
    }
    
}




