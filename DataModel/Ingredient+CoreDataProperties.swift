//
//  Ingredient+CoreDataProperties.swift
//  RecipeProject
//
//  Created by Yunao Guo on 7/30/23.
//
//

import Foundation
import CoreData


extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var imageName: String?
    @NSManaged public var ingredientName: String?
    @NSManaged public var unit: String?
    @NSManaged public var generate: RecipeIngredient?

}

extension Ingredient : Identifiable {

}
