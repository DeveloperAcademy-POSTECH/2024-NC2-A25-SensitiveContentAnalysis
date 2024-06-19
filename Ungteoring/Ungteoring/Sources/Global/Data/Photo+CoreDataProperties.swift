//
//  Photo+CoreDataProperties.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/19/24.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var uuid: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var createdAt: Date?

}

extension Photo : Identifiable {

}
