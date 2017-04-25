//
//  TravelLocationsViewController.swift
//  VirtualTouristPortfolio
//
//  Created by Juan Salcedo on 4/25/17.
//  Copyright © 2017 Juan Salcedo. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var editLabel: UILabel!
    
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var isDeletePin = false
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?{
        didSet{
            //Whenever the frc changes, we execute the search and
            fetchedResultsController?.delegate = self
            executeSearch()
            loadMap()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        configureMap()
        
        configureFetchResultsController()
        
    }
    
    
    @IBAction func editPressed(_ sender: Any) {
        
        if (UIDevice.current.orientation != UIDeviceOrientation.landscapeLeft) &&
            (UIDevice.current.orientation != UIDeviceOrientation.landscapeRight) {
            
            if !isDeletePin{
                UIView.animate(withDuration: 0.2, animations: {
                    self.mapView.frame.origin.y -= self.editLabel.frame.height
                    self.editLabel.frame.origin.y -= self.editLabel.frame.height
                    self.isDeletePin = true
                    self.editButton.title = "Done"
                })
            }else{
                UIView.animate(withDuration: 0.2, animations: {
                    self.mapView.frame.origin.y += self.editLabel.frame.height
                    self.editLabel.frame.origin.y += self.editLabel.frame.height
                    self.isDeletePin = false
                    self.editButton.title = "Edit"
                })
            }
        }

    }
}

//MARK: TravelLocationsViewController: (MKMapViewDelegate)

extension TravelLocationsViewController: MKMapViewDelegate{
    
    func loadMap(){
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        if (self.fetchedResultsController?.fetchedObjects?.count)! > 0{
            
            var annotations = [MKPointAnnotation]()
            for pin in (self.fetchedResultsController?.fetchedObjects)! {
                // Notice that the float values are being used to create CLLocationDegree values.
                // This is a version of the Double type.
                
                let newPin = pin as! Pin
                let lat = CLLocationDegrees(newPin.latitude)
                let long = CLLocationDegrees(newPin.longitude)
                
                // The lat and long are used to create a CLLocationCoordinates2D instance.
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                // Here we create the annotation and set its coordiate, title, and subtitle properties
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
                
                self.mapView.addAnnotations(annotations)
            }
        }
    }

    
    
    //Get the center location coordinate
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let region = mapView.region
        let coordinate = ["latitude": region.center.latitude,
                          "longitude": region.center.longitude,
                          "latitudeDelta": region.span.latitudeDelta,
                          "longitudeDelta" : region.span.longitudeDelta ]
        
        UserDefaults.standard.set(coordinate, forKey: "coordinate")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("view for annotation")
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if(pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
    }
}


// MARK: TravelLocationsViewController: (UIGestureRecognizerDelegate)

extension TravelLocationsViewController: UIGestureRecognizerDelegate {
    
    func configureMap(){
        
        mapView.delegate = self
        
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
        mapView.isZoomEnabled = true
        
        // Set Region
        if let coordinate = UserDefaults.standard.dictionary(forKey: "coordinate") {
            
            let location = CLLocationCoordinate2D(
                latitude: (coordinate["latitude"] as? Double)!,
                longitude: (coordinate["longitude"] as? Double)!
            )
            
            let span = MKCoordinateSpanMake(
                (coordinate["latitudeDelta"] as? Double)!,
                (coordinate["longitudeDelta"] as? Double)!
            )
            
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }

        
        //Add Gesture Recognizer
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.9
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        mapView.addGestureRecognizer(lpgr)
        
    }

    
    func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let location = gestureReconizer.location(in: self.mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let _ = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: self.fetchedResultsController!.managedObjectContext)
        
    }
}

// MARK: TravelLocationsViewController: (NSFetchedResultsControllerDelegate)
extension TravelLocationsViewController: NSFetchedResultsControllerDelegate {
    
    func configureFetchResultsController(){
        // Get the stack
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false)]
        
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            let pinCoordinate = controller.object(at: newIndexPath!) as! Pin
            let annotation = MKPointAnnotation()
            //let annotation = MKPinAnnotationView()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: pinCoordinate.latitude, longitude: pinCoordinate.longitude)
            mapView.addAnnotation(annotation)
        default:
            break
        }
    }
}

extension TravelLocationsViewController {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}





