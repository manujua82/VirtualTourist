//
//  Photo+CoreDataClass.swift
//  VirtualTouristPortfolio
//
//  Created by Kevin Bilberry on 4/26/17.
//  Copyright © 2017 Juan Salcedo. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    convenience init(photoData: NSData, photoUrl:String, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.photoData = photoData
            self.url = photoUrl
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}
