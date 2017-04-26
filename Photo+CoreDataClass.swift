//
//  Photo+CoreDataClass.swift
//  VirtualTouristPortfolio
//
//  Created by Juan Salcedo on 4/25/17.
//  Copyright © 2017 Juan Salcedo. All rights reserved.
//

import Foundation
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
    
    static func dataImageFrom(result: [String:AnyObject])->NSData?{
        
        /* GUARD: Does our photo have a key for 'url_m'? */
        guard let imageURLString = result[FlickrClient.FlickrResponseKeys.MediumURL] as? String else {
            return nil
        }
        
        // if an image exists at the url, set the image and title
        let imageUrl = URL(string: imageURLString)
        guard let imageData = try? Data(contentsOf: imageUrl!) else{
            return nil
        }
        return imageData as NSData
        
    }
    

    
    static func photosFromResults(_ results: [[String:AnyObject]], pin: Pin,context: NSManagedObjectContext) {
        
        for result in results {
            guard let imageData = dataImageFrom(result: result) else {
                continue
            }
            
            let photo = Photo(photoData: imageData, context: context)
            photo.pin = pin
        }
        
    }

}
