import UIKit
import CoreData

class HomeViewController: UIViewController, BottomTabBarViewDelegate, EditRecipeDelegate {
    func didUpdateRecipeName(_ recipe: Recipe, newName: String) {
        
    }
    
    var container: CoreDataStack!
    var coreDataStack = CoreDataStack(modelName: "RecipeProject")
    
    private let service = "com.yourapp.recipes"
    private let account = "Password"
    
    var bottomTabBarView: BottomTabBarView!
    
    var username: String?
    
    let tableView = UITableView()
    
    var collectionView: UICollectionView!
    var categories: [Category] = []
    var selectedCategories: Set<Category> = []
    
    let collectionReuseId = "CollectionCell"
    let tableReuseId = "RecipeTableViewCell"
    
    var recipes: [Recipe] = []
    var isSortingAscending = false
    
    var userLoggedin = "Welcome, "
    
    var backbutton = UIBarButtonItem()
    
    var sortImageView = UIImageView()
    
    var categoryHeader = UILabel()
    var recipeHeader = UILabel()
    
    let floatingButton: FloatingButton = {
        let button = FloatingButton()
        button.layer.cornerRadius = 20
        button.backgroundColor = .systemCyan
        button.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        retrieveAndDisplayUsername()
        setupCollectionView()
        fetchCategories()
        fetchRecipes()
        setupTableView()
        
        categoryHeader.text = "Category"
        categoryHeader.textColor = .darkGray
        categoryHeader.translatesAutoresizingMaskIntoConstraints = false
        categoryHeader.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(categoryHeader)
        
        recipeHeader.text = "Recipes"
        recipeHeader.textColor = .darkGray
        recipeHeader.translatesAutoresizingMaskIntoConstraints = false
        recipeHeader.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(recipeHeader)
        
        view.addSubview(floatingButton)
        
        bottomTabBarView = BottomTabBarView(buttonTitles: ["", ""], images: [UIImage(systemName: "house"), UIImage(systemName: "gear")])
        bottomTabBarView.delegate = self
        bottomTabBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomTabBarView)
        
        NSLayoutConstraint.activate([
            bottomTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            bottomTabBarView.heightAnchor.constraint(equalToConstant: 50),
            bottomTabBarView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: bottomTabBarView.topAnchor, constant: -5),
            floatingButton.widthAnchor.constraint(equalToConstant: 40),
            floatingButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Create custom back button
        backbutton = UIBarButtonItem(title: userLoggedin, style: .plain, target: nil, action: nil)
        backbutton.isEnabled = false
        navigationItem.leftBarButtonItem = backbutton
        
        
        sortImageView = UIImageView(image: UIImage(systemName: "arrowtriangle.up.fill"))
        sortImageView.tintColor = .systemCyan
        sortImageView.isUserInteractionEnabled = true
        sortImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sortImageViewTapped)))
        sortImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sortImageView)
        
        // Add constraints for the sort image view
        NSLayoutConstraint.activate([
            sortImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sortImageView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            sortImageView.widthAnchor.constraint(equalToConstant: 30),
            sortImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func sortImageViewTapped() {
        isSortingAscending.toggle()
        let imageName = isSortingAscending ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill"
        if let sortImageView = view.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            sortImageView.image = UIImage(systemName: imageName)
        }
        fetchRecipes()
    }
    
    @objc private func floatingButtonTapped() {
        let newRecipe = Recipe(context: coreDataStack.managedContext)
        newRecipe.recipeName = ""
        newRecipe.recipeInstruction = ""
        newRecipe.recipeImageName = ""
        newRecipe.recipeDescription = ""
        
        let editRecipeViewController = EditRecipeViewController()
        editRecipeViewController.recipe = newRecipe
        editRecipeViewController.coreDataStack = coreDataStack
        editRecipeViewController.delegate = self
        navigationController?.pushViewController(editRecipeViewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateData()
        
        fetchCategories()
        fetchRecipes()
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        categoryHeader.frame = CGRect(x: 10, y: 50, width: 150, height: 100) // Adjust the height as needed
        
        collectionView.frame = CGRect(x: 10, y: 25, width: 370, height: 150) // Adjust the height as needed
        sortImageView.frame = CGRect(x: 325, y: 175, width: 25, height: 25)
        recipeHeader.frame = CGRect(x: 10, y: 135, width: 150, height: 100)
        
        tableView.frame = CGRect(x: 10, y: 200, width: 370, height: 650)
            }
    
    func setupTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: tableReuseId)
        view.addSubview(tableView)
        // Add and configure constraints for the tableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
        ])
    }
    
    func fetchRecipes() {
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "recipeName", ascending: isSortingAscending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let context = coreDataStack.managedContext
            recipes = try context.fetch(fetchRequest)
            
            // Update the favorite status for each recipe using UserDefaults
            for (index, recipe) in recipes.enumerated() {
                let isFavorite = UserDefaultsManager.isRecipeFavorite(recipe.recipeName!)
                recipes[index].isFavorite = isFavorite
            }
            
            let sortedRecipes = isSortingAscending ? recipes.sorted(by: { $0.recipeName ?? "" < $1.recipeName ?? "" }) :
            recipes.sorted(by: { $0.recipeName ?? "" > $1.recipeName ?? "" })
            recipes = sortedRecipes
            
            tableView.reloadData()
        } catch {
            print("Error fetching recipes: \(error)")
        }
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // Register collection view cell
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: collectionReuseId)
        view.addSubview(collectionView)
        // Add constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
        ])

        fetchCategories()
    }
    
    func fetchCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            let context = coreDataStack.managedContext
            categories = try context.fetch(fetchRequest)
            print(categories)
            collectionView.reloadData()
            
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    func didSelectTab(at index: Int) {
        if index == 0 {
            //navigationController?.popToRootViewController(animated: true)
        }
        else if index == 1 {
            // Settings button tapped, handle navigation to SettingsViewController
            let settingsVC = SettingsViewController()
            navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
    
    func retrieveAndDisplayUsername() {
        let query = [
            kSecReturnData: true,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        if status == errSecSuccess, let data = result as? Data, let username = String(data: data, encoding: .utf8) {
            userLoggedin += username
        } else {
            userLoggedin += "user123"
        }
    }
    
    func filterRecipes() {
        if selectedCategories.isEmpty {
            // No categories selected, show all recipes
            fetchRecipes()
        } else {
            // Filter recipes based on selected categories
            let filteredRecipes = recipes.filter { recipe in
                guard let recipeCategories = recipe.belongTo as? Set<Category> else { return false }
                return selectedCategories.isSubset(of: recipeCategories)
            }
            recipes = filteredRecipes
            tableView.reloadData()
        }
    }
    
    
    func populateData(){
        deleteData()
        let recipe1 = Recipe(context: coreDataStack.managedContext)
        recipe1.recipeName = "Popcorn Chicken"
        recipe1.recipeInstruction =
        """
        1. Mix flour, garlic powder, salt, and black pepper together in a bowl.
        2. Beat eggs and lemon juice together in a separate bowl.
        3. Heat 2 inches of oil in a large pot over medium heat.
        4. Dredge chicken pieces in flour mixture; shake off excess. Dip into beaten egg. Lift up so excess egg drips back into the bowl. Press into flour mixture again to coat.
        5. Lower pieces of chicken carefully into hot oil in batches; fry until golden brown, 7 to 8 minutes. Transfer to a paper towel-lined plate to drain. Repeat with remaining chicken pieces.
        """
        recipe1.recipeImageName = "popcornchicken"
        recipe1.recipeDescription="Popcorn chicken is a dish of bite-sized chunks of deep-fried chicken that are sure to be a family favorite. I love to serve the chicken with mashed potatoes and green beans."
        
        let ingredient1 = Ingredient(context: coreDataStack.managedContext)
        ingredient1.ingredientName = "flour"
        ingredient1.imageName = "flour"
        ingredient1.unit = "cup(s)"
        
        let ingredient2 = Ingredient(context: coreDataStack.managedContext)
        ingredient2.ingredientName = "garlic powder"
        ingredient2.imageName = "garlicpowder"
        ingredient2.unit = "teaspoon(s)"
        
        let ingredient3 = Ingredient(context: coreDataStack.managedContext)
        ingredient3.ingredientName = "salt"
        ingredient3.imageName = "salt"
        ingredient3.unit = "teaspoon(s)"
        
        let ingredient4 = Ingredient(context: coreDataStack.managedContext)
        ingredient4.ingredientName = "black pepper"
        ingredient4.imageName = "blackpepper"
        ingredient4.unit="teaspoon(s)"
        
        let ingredient5 = Ingredient(context: coreDataStack.managedContext)
        ingredient5.ingredientName = "egg"
        ingredient5.imageName = "egg"
        ingredient5.unit=" "
        
        let ingredient6 = Ingredient(context: coreDataStack.managedContext)
        ingredient6.ingredientName = "lemon juice"
        ingredient6.imageName = "lemonjuice"
        ingredient6.unit="tablespoon(s)"
        
        let ingredient7 = Ingredient(context: coreDataStack.managedContext)
        ingredient7.ingredientName = "oil"
        ingredient7.imageName = "oil"
        ingredient7.unit="cup(s)"
        
        let ingredient8 = Ingredient(context: coreDataStack.managedContext)
        ingredient8.ingredientName = "chicken breast"
        ingredient8.imageName = "chickbreast"
        ingredient8.unit=" "
        
        let ingredient9 = Ingredient(context: coreDataStack.managedContext)
        ingredient9.ingredientName = "almonds"
        ingredient9.imageName = "almond"
        ingredient9.unit = "cup(s)"
        
        let ingredient10 = Ingredient(context: coreDataStack.managedContext)
        ingredient10.ingredientName = "mayonnaise"
        ingredient10.imageName = "mayo"
        ingredient10.unit = "cup(s)"
        
        let ingredient11 = Ingredient(context: coreDataStack.managedContext)
        ingredient11.ingredientName = "celery"
        ingredient11.imageName = "celery"
        ingredient11.unit="stalk"
        
        
        let ingredientQuantity1 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity1.recipeName = "Popcorn Chicken"
        ingredientQuantity1.ingredientName = "flour"
        ingredientQuantity1.quantity = 3
        
        let ingredientQuantity2 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity2.recipeName = "Popcorn Chicken"
        ingredientQuantity2.ingredientName = "garlic powder"
        ingredientQuantity2.quantity = 2
        
        let ingredientQuantity3 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity3.recipeName = "Popcorn Chicken"
        ingredientQuantity3.ingredientName = "salt"
        ingredientQuantity3.quantity = 0.5
        
        let ingredientQuantity4 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity4.recipeName = "Popcorn Chicken"
        ingredientQuantity4.ingredientName = "black pepper"
        ingredientQuantity4.quantity = 0.25
        
        let ingredientQuantity5 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity5.recipeName = "Popcorn Chicken"
        ingredientQuantity5.ingredientName = "egg"
        ingredientQuantity5.quantity = 2
        
        let ingredientQuantity6 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity6.recipeName = "Popcorn Chicken"
        ingredientQuantity6.ingredientName = "lemon juice"
        ingredientQuantity6.quantity = 2
        
        let ingredientQuantity7 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity7.recipeName = "Popcorn Chicken"
        ingredientQuantity7.ingredientName = "oil"
        ingredientQuantity7.quantity = 2
        
        let ingredientQuantity8 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity8.recipeName = "Popcorn Chicken"
        ingredientQuantity8.ingredientName = "chicken breast"
        ingredientQuantity8.quantity = 3
        
        ingredientQuantity1.addToNeed(ingredient1)
        ingredientQuantity2.addToNeed(ingredient2)
        ingredientQuantity3.addToNeed(ingredient3)
        ingredientQuantity4.addToNeed(ingredient4)
        ingredientQuantity5.addToNeed(ingredient5)
        ingredientQuantity6.addToNeed(ingredient6)
        ingredientQuantity7.addToNeed(ingredient7)
        ingredientQuantity8.addToNeed(ingredient8)
        
        
        
        let recipe2 = Recipe(context: coreDataStack.managedContext)
        recipe2.recipeName = "Chicken Salad"
        recipe2.recipeImageName = "chickensalad"
        recipe2.recipeDescription = "This chicken salad recipe is the best and a family favorite! I like to use leftover roast chicken or baked chicken breasts that have been sprinkled with basil or rosemary."
        recipe2.recipeInstruction =
            """
    1. Gather all ingredients.
    2. Place almonds in a frying pan. Toast over medium-high heat, shaking frequently. Watch carefully, as they burn easily.
    3. Mix together mayonnaise, lemon juice, and pepper in a medium bowl.
    4. Toss with chicken, toasted almonds, and celery.
    5. Enjoy
    """
        let ingredientQuantity9 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity9.recipeName = "Chicken Salad"
        ingredientQuantity9.ingredientName = "almonds"
        ingredientQuantity9.quantity = 0.5
        
        let ingredientQuantity10 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity10.recipeName = "Chicken Salad"
        ingredientQuantity10.ingredientName = "moyonnaise"
        ingredientQuantity10.quantity = 0.5
        
        let ingredientQuantity11 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity11.recipeName = "Chicken Salad"
        ingredientQuantity11.ingredientName = "lemon juice"
        ingredientQuantity11.quantity = 1
        
        let ingredientQuantity12 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity12.recipeName = "Chicken Salad"
        ingredientQuantity12.ingredientName = "black pepper"
        ingredientQuantity12.quantity = 0.25
        
        let ingredientQuantity13 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity13.recipeName = "Chicken Salad"
        ingredientQuantity13.ingredientName = "chick breast"
        ingredientQuantity13.quantity = 2
        
        let ingredientQuantity14 = RecipeIngredient(context: coreDataStack.managedContext)
        ingredientQuantity14.recipeName = "Chicken Salad"
        ingredientQuantity14.ingredientName = "celery"
        ingredientQuantity14.quantity = 1
        
        ingredientQuantity9.addToNeed(ingredient9)
        ingredientQuantity10.addToNeed(ingredient10)
        ingredientQuantity11.addToNeed(ingredient6)
        ingredientQuantity12.addToNeed(ingredient4)
        ingredientQuantity13.addToNeed(ingredient8)
        ingredientQuantity14.addToNeed(ingredient11)
        
        
        let category1 = Category(context: coreDataStack.managedContext)
        category1.name = "Fast Food"
        let category2 = Category(context: coreDataStack.managedContext)
        category2.name = "Chicken Dishes"
        let category3 = Category(context: coreDataStack.managedContext)
        category3.name = "Vegetable"
        let category4 = Category(context: coreDataStack.managedContext)
        category4.name = "Healthy"
        let category5 = Category(context: coreDataStack.managedContext)
        category5.name = "Lunch"
        let category6 = Category(context: coreDataStack.managedContext)
        category6.name = "Breakfast"
        let category7 = Category(context: coreDataStack.managedContext)
        category7.name = "Dinner"
        let category8 = Category(context: coreDataStack.managedContext)
        category8.name = "Chinese"
        let category9 = Category(context: coreDataStack.managedContext)
        category9.name = "Japanese"
        let category10 = Category(context: coreDataStack.managedContext)
        category10.name = "Salad"
        
        
        // Associate categories with the recipe
        recipe1.addToBelongTo(category1)
        recipe1.addToBelongTo(category2)
        recipe1.addToBelongTo(category5)
        
        recipe2.addToBelongTo(category4)
        recipe2.addToBelongTo(category2)
        recipe2.addToBelongTo(category5)
        recipe2.addToBelongTo(category10)
        
        recipe1.addToUses(ingredientQuantity1)
        recipe1.addToUses(ingredientQuantity2)
        recipe1.addToUses(ingredientQuantity3)
        recipe1.addToUses(ingredientQuantity4)
        recipe1.addToUses(ingredientQuantity5)
        recipe1.addToUses(ingredientQuantity6)
        recipe1.addToUses(ingredientQuantity7)
        recipe1.addToUses(ingredientQuantity8)
        
        recipe2.addToUses(ingredientQuantity9)
        recipe2.addToUses(ingredientQuantity10)
        recipe2.addToUses(ingredientQuantity11)
        recipe2.addToUses(ingredientQuantity12)
        recipe2.addToUses(ingredientQuantity13)
        recipe2.addToUses(ingredientQuantity14)
        
        do {
            try coreDataStack.saveContext()
        } catch {
            print("Error saving context: \(error)")
        }
        
    }
    func saveData(){
        deleteData()
        populateData()
    }
    
    func deleteData() {
        let entities = ["Recipe", "Ingredient", "Category", "RecipeIngredient"]
        
        for entity in entities {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
            
            do {
                let fetchedObjects = try coreDataStack.managedContext.fetch(fetchRequest)
                
                for object in fetchedObjects {
                    if let managedObject = object as? NSManagedObject {
                        coreDataStack.managedContext.delete(managedObject)
                    }
                }
                try coreDataStack.managedContext.save()
            } catch {
                print(error)
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuseId, for: indexPath) as? CategoryCell else {
            fatalError("Unable to dequeue CategoryCollectionViewCell")
        }
        let categoryName = categories[indexPath.item].name ?? "Default Category Name" //
        cell.configure(with: categoryName, isSelected: selectedCategories.contains(categories[indexPath.item]))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        
        filterRecipes()
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let categoryName = categories[indexPath.item].name ?? ""
        let itemWidth = categoryName.size(withAttributes: [.font: UIFont.systemFont(ofSize: 17)]).width + 20
        
        return CGSize(width: itemWidth, height: 40)
    }
    
    func recipeDetailViewController(_ viewController: RecipeDetailViewController, didSaveChangesTo recipe: Recipe) {
            if let index = recipes.firstIndex(where: { $0 == recipe }) {
                recipes[index] = recipe
            } else {
                recipes.append(recipe)
            }
            
            tableView.reloadData()
        }
    
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableReuseId, for: indexPath) as! RecipeTableViewCell
        let recipe = recipes[indexPath.row]
        
        if let recipeImageName = recipe.recipeImageName, let recipeImage = UIImage(named: recipeImageName) {
            let categories = categoriesText(for: recipe)
            cell.configureCell(imageName: recipeImage, labelText: recipe.recipeName ?? "Popcorn Chicken", categories: categories)
            cell.categoryStackView.setCategories(categories)
        } else {
            cell.configureCell(imageName: UIImage(named: "defaultrecipe")!, labelText: recipe.recipeName ?? "popcorn chicken", categories: [])
        }
        
        cell.favoriteButton.isSelected = recipe.isFavorite
        
        cell.favoriteButtonTapped = { [weak self] in
            self?.toggleFavoriteStatus(for: recipe, at: indexPath)
        }
        
        return cell
    }
    
    private func toggleFavoriteStatus(for recipe: Recipe, at indexPath: IndexPath) {
        recipe.isFavorite = !recipe.isFavorite // Toggle the favorite status
        
        // Save the changes to CoreData
        do {
            try coreDataStack.managedContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @objc private func favoriteButtonTapped(_ sender: UIButton) {
        let recipe = recipes[sender.tag]
        let newFavoriteStatus = !UserDefaultsManager.isRecipeFavorite(recipe.recipeName!)
        
        UserDefaultsManager.setRecipeFavorite(recipe.recipeName!, isFavorite: newFavoriteStatus)
        
        var updatedRecipe = recipe
        updatedRecipe.isFavorite = newFavoriteStatus
        recipes[sender.tag] = updatedRecipe
        
        // Reload the table view to reflect the changes
        tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    private func categoriesText(for recipe: Recipe) -> [String] {
        let categories = recipe.belongTo?.allObjects.compactMap { ($0 as? Category)?.name } ?? []
        return categories
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRecipe = recipes[indexPath.row]
        let recipeDetailVC = RecipeDetailViewController()
        recipeDetailVC.recipe = selectedRecipe
        recipeDetailVC.coreDataStack = coreDataStack
        navigationController?.pushViewController(recipeDetailVC, animated: true)
    }
    
    func didSaveChangesToRecipe(_ editedRecipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0 == editedRecipe }) {
            recipes[index] = editedRecipe

            tableView.reloadData()
        }
    }
    
    
    func didAddNewRecipe(_ recipe: Recipe) {
            recipes.append(recipe)
            tableView.reloadData()
        }
    func reloadTableView() {
        tableView.reloadData()
    }
}
