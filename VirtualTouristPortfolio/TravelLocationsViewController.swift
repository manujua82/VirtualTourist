//
//  TravelLocationsViewController.swift
//  VirtualTouristPortfolio
//
//  Created by Juan Salcedo on 4/25/17.
//  Copyright © 2017 Juan Salcedo. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
    }
    
    
    func configureMap(){
        
        mapView.delegate = self
        
        //Add Gesture Recognizer
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.9
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        mapView.addGestureRecognizer(lpgr)
        
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
    }

    
}

//MARK: TravelLocationsViewController: (MKMapViewDelegate)

extension TravelLocationsViewController: MKMapViewDelegate{
    
    
    //Get the center location coordinate
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let region = mapView.region
        let coordinate = ["latitude": region.center.latitude,
                          "longitude": region.center.longitude,
                          "latitudeDelta": region.span.latitudeDelta,
                          "longitudeDelta" : region.span.longitudeDelta ]
        
        UserDefaults.standard.set(coordinate, forKey: "coordinate")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
    }
}


// MARK: TravelLocationsViewController: (UIGestureRecognizerDelegate)

extension TravelLocationsViewController: UIGestureRecognizerDelegate {
    
    func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let location = gestureReconizer.location(in: self.mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        //let _ = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: self.fetchedResultsController!.managedObjectContext)
        
    }
}




