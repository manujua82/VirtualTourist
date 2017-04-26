//
//  Photo+CoreDataProperties.swift
//  VirtualTouristPortfolio
//
//  Created by Kevin Bilberry on 4/26/17.
//  Copyright © 2017 Juan Salcedo. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var photoData: NSData?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
