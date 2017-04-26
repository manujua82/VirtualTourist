//
//  Photo+CoreDataClass.swift
//  VirtualTouristPortfolio
//
//  Created by Juan Salcedo on 4/25/17.
//  Copyright © 2017 Juan Salcedo. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    convenience init(photoData: NSData, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.photoData = photoData
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    static func dataImageFrom(dictionary: [String:AnyObject])->NSData?{
        
        /* GUARD: Does our photo have a key for 'url_m'? */
        guard let imageUrlString = dictionary[FlickrClient.FlickrResponseKeys.MediumURL] as? String else {
            return nil
        }
        
        // if an image exists at the url, set the image and title
        let imageURL = URL(string: imageUrlString)
        guard let imageData = try? Data(contentsOf: imageURL!) else{
            return nil
        }
        return imageData as NSData
        
    }
    

    

    
    static func photosFromResults(_ results: [[String:AnyObject]], pin: Pin,context: NSManagedObjectContext) {
        
        let placeHolder  = UIImage(named: "placeholder")
        let data = UIImagePNGRepresentation(placeHolder!)! as NSData
        var photos = [Photo]()
        
        for _ in results {
            let imageWithPlaceHolder = Photo(photoData: data, context: context)
            imageWithPlaceHolder.pin = pin
            photos.append(imageWithPlaceHolder)
        }
        
        print ("caantidad de imagenes: \(photos.count)")
        
        let enumaratedDict = results.enumerated()
        for imageDic in enumaratedDict {
            guard let imageData = dataImageFrom(dictionary: imageDic.element) else {
                continue
            }
            
            let imageFromIndexInImages = photos[imageDic.offset]
            imageFromIndexInImages.photoData = imageData
        }
    }
}
