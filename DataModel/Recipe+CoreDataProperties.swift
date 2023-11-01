//
//  Recipe+CoreDataProperties.swift
//  RecipeProject
//
//  Created by Yunao Guo on 7/30/23.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var recipeDescription: String?
    @NSManaged public var recipeImageName: String?
    @NSManaged public var recipeIngredient: String?
    @NSManaged public var recipeInstruction: String?
    @NSManaged public var recipeName: String?
    @NSManaged public var belongTo: NSSet?
    @NSManaged public var uses: NSSet?
}

// MARK: Generated accessors for belongTo
extension Recipe {

    @objc(addBelongToObject:)
    @NSManaged public func addToBelongTo(_ value: Category)

    @objc(removeBelongToObject:)
    @NSManaged public func removeFromBelongTo(_ value: Category)

    @objc(addBelongTo:)
    @NSManaged public func addToBelongTo(_ values: NSSet)

    @objc(removeBelongTo:)
    @NSManaged public func removeFromBelongTo(_ values: NSSet)

}

// MARK: Generated accessors for uses
extension Recipe {

    @objc(addUsesObject:)
    @NSManaged public func addToUses(_ value: RecipeIngredient)

    @objc(removeUsesObject:)
    @NSManaged public func removeFromUses(_ value: RecipeIngredient)

    @objc(addUses:)
    @NSManaged public func addToUses(_ values: NSSet)

    @objc(removeUses:)
    @NSManaged public func removeFromUses(_ values: NSSet)

}

extension Recipe : Identifiable {

}

extension Recipe {
    var isFavorite: Bool {
        get {
            return UserDefaultsManager.isRecipeFavorite(recipeName ?? "")
        }
        set {
            UserDefaultsManager.setRecipeFavorite(recipeName ?? "", isFavorite: newValue)
        }
    }
}
