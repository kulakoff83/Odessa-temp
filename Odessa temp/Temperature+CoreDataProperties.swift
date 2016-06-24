//
//  Temperature+CoreDataProperties.swift
//  Odessa temp
//
//  Created by Dmitry Kulakov on 23.06.16.
//  Copyright © 2016 kulakoff. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Temperature {

    @NSManaged var date: NSDate?
    @NSManaged var value: NSNumber?

}
