//
//  Category+CoreDataProperties.swift
//  RecipeProject
//
//  Created by Yunao Guo on 7/30/23.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var include: NSSet?

}

// MARK: Generated accessors for include
extension Category {

    @objc(addIncludeObject:)
    @NSManaged public func addToInclude(_ value: Recipe)

    @objc(removeIncludeObject:)
    @NSManaged public func removeFromInclude(_ value: Recipe)

    @objc(addInclude:)
    @NSManaged public func addToInclude(_ values: NSSet)

    @objc(removeInclude:)
    @NSManaged public func removeFromInclude(_ values: NSSet)

}

extension Category : Identifiable {

}
