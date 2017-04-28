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
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pin: Pin?
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noImageLabel.isHidden = true
        
        configureMap()
        configureCollectionView()
        
        guard let album = pin?.photos else {
            print("no exite photos")
            return
        }
        
        if album.count == 0 {
            newCollectionButton.isEnabled = false
            downloadImages()
        }
    }
    
   
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
        
        // delete existing photos
        noImageLabel.isHidden = true
        newCollectionButton.isEnabled = false
        for photo in fetchedResultsController?.fetchedObjects as! [Photo] {
            fetchedResultsController!.managedObjectContext.delete(photo)
        }
        delegate.stack.save()
        downloadImages()
    }
    
    func configureCollectionView(){
        
        self.collectionView?.allowsMultipleSelection = true
        self.collectionView?.selectItem(at: nil, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        self.flowLayout.minimumInteritemSpacing = 0
        self.flowLayout.minimumLineSpacing = space
        self.flowLayout.itemSize = CGSize(width: dimension, height: dimension)
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
    
    
    
    func downloadImages(){
        
        FlickrClient.sharedInstance().getPhotosByLocation(latitude: (self.pin?.latitude)!, longitude: (self.pin?.longitude)!, completionHandlerForGetPhotosByLocation: { (result, error) in
            
            if let error = error{
                print("Something is wrong with download: \(error.description)")
            }else{
                let stack = self.delegate.stack
                if (result?.count)! > 0 {
                    stack.performBackgroundBatchOperation({ (workerContext) in
                        for photoFlickr in result! {
                             /*
                             guard let imageURLString = photoFlickr[FlickrClient.FlickrResponseKeys.MediumURL] as? String else {
                                return
                            }
                            
                           
                            FlickrClient.downloadImage(imagePath: imageURLString) { (data, error) in
                                if let error = error{
                                    print("Something is wrong with download: \(error.description)")
                                }else{
                                    print("descago Imagen")
                                    let imageWithPlaceHolder = Photo(photoData: data as NSData?, photoUrl: imageURLString, context: stack.context)
                                    imageWithPlaceHolder.pin = self.pin!
                                    
                                    //photo.photoData = data as NSData?
                                }
                            }*/

                            guard let imageURLString = photoFlickr[FlickrClient.FlickrResponseKeys.MediumURL] as? String else {
                                return
                            }
                            
                            let imageWithPlaceHolder = Photo(photoData: nil, photoUrl: imageURLString, context: stack.context)
                            imageWithPlaceHolder.pin = self.pin!
                            self.delegate.stack.save()
                        }
                    })
                    
                    DispatchQueue.main.async {
                        self.newCollectionButton.isEnabled = true
                    }
                }else{
                    self.noImageLabel.isHidden = false
                }
                
            }
            
        })
    } 
}

// MARK: - PhotoAlbumViewController (Collection Data Source, UICollectionViewDelegate)
extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelect")
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselect")
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        
        
        // Configure the cell
        cell.imageView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth]
        cell.imageView.contentMode = .scaleAspectFill
     
        
        
        if let photoData = photo.photoData as? Data {
            cell.imageView?.image = UIImage(data: photoData)
            cell.indicator.stopAnimating()
        }else{
            cell.indicator.startAnimating()
            
        }
        
        
        return cell
    }
}




