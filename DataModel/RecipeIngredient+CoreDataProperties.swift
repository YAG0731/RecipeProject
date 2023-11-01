//
//  RecipeIngredient+CoreDataProperties.swift
//  RecipeProject
//
//  Created by Yunao Guo on 7/30/23.
//
//

import Foundation
import CoreData


extension RecipeIngredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeIngredient> {
        return NSFetchRequest<RecipeIngredient>(entityName: "RecipeIngredient")
    }

    @NSManaged public var ingredientName: String?
    @NSManaged public var quantity: Double
    @NSManaged public var recipeName: String?
    @NSManaged public var make: NSSet?
    @NSManaged public var need: NSSet?

}

// MARK: Generated accessors for make
extension RecipeIngredient {

    @objc(addMakeObject:)
    @NSManaged public func addToMake(_ value: Recipe)

    @objc(removeMakeObject:)
    @NSManaged public func removeFromMake(_ value: Recipe)

    @objc(addMake:)
    @NSManaged public func addToMake(_ values: NSSet)

    @objc(removeMake:)
    @NSManaged public func removeFromMake(_ values: NSSet)

}

// MARK: Generated accessors for need
extension RecipeIngredient {

    @objc(addNeedObject:)
    @NSManaged public func addToNeed(_ value: Ingredient)

    @objc(removeNeedObject:)
    @NSManaged public func removeFromNeed(_ value: Ingredient)

    @objc(addNeed:)
    @NSManaged public func addToNeed(_ values: NSSet)

    @objc(removeNeed:)
    @NSManaged public func removeFromNeed(_ values: NSSet)

}

extension RecipeIngredient : Identifiable {

}
