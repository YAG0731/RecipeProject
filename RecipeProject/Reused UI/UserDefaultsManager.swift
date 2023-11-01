import Foundation

class UserDefaultsManager {
    static let favoriteRecipesKey = "FavoriteRecipesKey"

    static func setRecipeFavorite(_ recipeName: String, isFavorite: Bool) {
        var favoriteRecipes = getFavoriteRecipes()
        if isFavorite {
            favoriteRecipes.insert(recipeName)
        } else {
            favoriteRecipes.remove(recipeName)
        }
        UserDefaults.standard.set(Array(favoriteRecipes), forKey: favoriteRecipesKey)
    }

    static func isRecipeFavorite(_ recipeName: String) -> Bool {
        let favoriteRecipes = getFavoriteRecipes()
        return favoriteRecipes.contains(recipeName)
    }

    private static func getFavoriteRecipes() -> Set<String> {
        return Set(UserDefaults.standard.stringArray(forKey: favoriteRecipesKey) ?? [])
    }
}
