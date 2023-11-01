import UIKit
import CoreData

protocol EditRecipeDelegate: AnyObject {
    func didSaveChangesToRecipe(_ editedRecipe: Recipe)
    func didUpdateRecipeName(_ recipe: Recipe, newName: String)
    func didAddNewRecipe(_ recipe: Recipe)
}

class EditRecipeViewController: UIViewController {
    weak var delegate: EditRecipeDelegate?
    
    var coreDataStack: CoreDataStack!
    
    var recipe: Recipe?
    var ingredientsData: [IngredientInfo] = []
    var categories: [String] = []
    typealias IngredientInfo = (name: String, quantity: Double, unit: String)
    
    var isNewRecipe: Bool {
        return recipe == nil
    }
    
    var editHeader = UILabel()
    
    private let userCategoryButton: UIButton = {
        let button = FloatingButton()
        button.backgroundColor = .systemCyan
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let recipennameHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "Recipe Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var recipeNameInput: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.boldSystemFont(ofSize: 10)
        textField.backgroundColor = .gray
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let descriptionHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "Description"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var descriptionInput: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.boldSystemFont(ofSize: 10)
        textField.backgroundColor = .gray
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let categoryHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "Category"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let ingredientsHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "Ingredients"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionsHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "Instructions"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var instructionInput: UITextView = {
        let textField = UITextView()
        textField.backgroundColor = .gray
        textField.layer.cornerRadius = 6
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var ingredientsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let addIngredientButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addIngredientButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populateData()
        loadExistingCategories()
    }
    
    private func populateData() {
        guard let recipe = recipe else {
            return
        }
        recipeNameInput.text = recipe.recipeName
        descriptionInput.text = recipe.recipeDescription
        instructionInput.text = recipe.recipeInstruction
        
        // Clear the previous data
        ingredientsData.removeAll()
        
        // Retrieve and store the ingredients
        if let recipeIngredients = recipe.uses as? Set<RecipeIngredient> {
            for recipeIngredient in recipeIngredients {
                guard let ingredientName = recipeIngredient.ingredientName else {
                    continue
                }
                let quantity = recipeIngredient.quantity
                let unit = fetchIngredientUnit(name: ingredientName) ?? ""
                
                // Create the ingredientData tuple and append it to the ingredientsData array
                let ingredientData: IngredientInfo = (name: ingredientName, quantity: quantity, unit: unit)
                ingredientsData.append(ingredientData)
            }
            
            // Add the ingredient views to the stack view
            for ingredientData in ingredientsData {
                addIngredientView(name: ingredientData.name, quantity: ingredientData.quantity, unit: ingredientData.unit)
            }
        }
    }
    
    private func addIngredientView(name: String, quantity: Double, unit: String) {
        // Function to add ingredient view in the stack view
        let ingredientStackView = UIStackView()
        ingredientStackView.axis = .horizontal
        ingredientStackView.spacing = 5
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = .darkGray
        nameLabel.font = UIFont.systemFont(ofSize: 10)
        
        let quantityLabel = UILabel()
        quantityLabel.text = "\(quantity)"
        quantityLabel.textColor = .darkGray
        quantityLabel.font = UIFont.systemFont(ofSize: 10)
        
        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.textColor = .darkGray
        unitLabel.font = UIFont.systemFont(ofSize: 10)
        
        // Add the ingredient labels to the horizontal stack view
        ingredientStackView.addArrangedSubview(nameLabel)
        ingredientStackView.addArrangedSubview(quantityLabel)
        ingredientStackView.addArrangedSubview(unitLabel)
        
        ingredientsStackView.addArrangedSubview(ingredientStackView)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        if recipe == nil {
            editHeader.font = UIFont.boldSystemFont(ofSize: 25)
            editHeader.text = "Add New Recipe"
            
        } else {
            editHeader.font = UIFont.boldSystemFont(ofSize: 25)
            editHeader.text = "Edit Recipe"
        }
        editHeader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editHeader)
        view.addSubview(recipennameHeaderLabel)
        view.addSubview(recipeNameInput)
        recipeNameInput.text = recipe?.recipeName
        view.addSubview(descriptionHeaderLabel)
        view.addSubview(descriptionInput)
        descriptionInput.text = recipe?.recipeDescription
        view.addSubview(categoryHeaderLabel)
        view.addSubview(categoryStackView)
        view.addSubview(ingredientsHeaderLabel)
        view.addSubview(ingredientsStackView)
        view.addSubview(instructionsHeaderLabel)
        view.addSubview(instructionInput)
        instructionInput.text = recipe?.recipeInstruction
        view.addSubview(addIngredientButton)
        userCategoryButton.tintColor = .black
        categoryStackView.addArrangedSubview(userCategoryButton)
        userCategoryButton.addTarget(self, action: #selector(userCategoryButtonTapped), for: .touchDown)
        
        NSLayoutConstraint.activate([
            editHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            editHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            recipennameHeaderLabel.topAnchor.constraint(equalTo: editHeader.bottomAnchor, constant: 20),
            recipennameHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            recipeNameInput.topAnchor.constraint(equalTo: recipennameHeaderLabel.bottomAnchor, constant: 8),
            recipeNameInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            recipeNameInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionHeaderLabel.topAnchor.constraint(equalTo: recipeNameInput.bottomAnchor, constant: 16),
            descriptionHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            descriptionInput.topAnchor.constraint(equalTo: descriptionHeaderLabel.bottomAnchor, constant: 8),
            descriptionInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            categoryHeaderLabel.topAnchor.constraint(equalTo: descriptionInput.bottomAnchor, constant: 16),
            categoryHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            categoryStackView.topAnchor.constraint(equalTo: categoryHeaderLabel.bottomAnchor, constant: 8),
            categoryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            ingredientsHeaderLabel.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 8),
            ingredientsHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            ingredientsStackView.topAnchor.constraint(equalTo: ingredientsHeaderLabel.bottomAnchor, constant: 8),
            ingredientsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ingredientsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            addIngredientButton.topAnchor.constraint(equalTo: ingredientsStackView.bottomAnchor, constant: 0),
            addIngredientButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addIngredientButton.heightAnchor.constraint(equalToConstant: 40),
            
            instructionsHeaderLabel.topAnchor.constraint(equalTo: ingredientsStackView.bottomAnchor, constant: 8),
            instructionsHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            instructionInput.topAnchor.constraint(equalTo: instructionsHeaderLabel.bottomAnchor, constant: 8),
            instructionInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            instructionInput.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.85),
        ])
    }
    
    @objc private func addIngredientButtonTapped() {
        let alertController = UIAlertController(title: "Add New Ingredient", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Ingredient Name"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Quantity"
            textField.keyboardType = .decimalPad
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Unit"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alertController] _ in
            guard let ingredientName = alertController?.textFields?[0].text,
                  let quantityText = alertController?.textFields?[1].text,
                  let quantity = Double(quantityText),
                  let unit = alertController?.textFields?[2].text else {
                return
            }
            
            self?.addIngredientToStackView(name: ingredientName, quantity: quantity, unit: unit)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func addIngredientToStackView(name: String, quantity: Double, unit: String) {
        let ingredientStackView = UIStackView()
        ingredientStackView.axis = .horizontal
        ingredientStackView.spacing = 5
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.textColor = .darkGray
        nameLabel.font = UIFont.systemFont(ofSize: 10)
        
        let quantityLabel = UILabel()
        quantityLabel.text = "\(quantity)"
        quantityLabel.textColor = .darkGray
        quantityLabel.font = UIFont.systemFont(ofSize: 10)
        
        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.textColor = .darkGray
        unitLabel.font = UIFont.systemFont(ofSize: 10)
        
        ingredientStackView.addArrangedSubview(nameLabel)
        ingredientStackView.addArrangedSubview(quantityLabel)
        ingredientStackView.addArrangedSubview(unitLabel)
        
        ingredientsStackView.addArrangedSubview(ingredientStackView)
    }
    
    func fetchIngredientUnit(name: String) -> String? {
        if let ingredientEntity = findIngredient(with: name) {
            return ingredientEntity.unit
        }
        return nil
    }
    
    private func findIngredient(with name: String) -> Ingredient? {
        let fetchRequest: NSFetchRequest<Ingredient> = Ingredient.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ingredientName == %@", name)
        
        do {
            let context = coreDataStack.managedContext
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching ingredient: \(error)")
        }
        return nil
    }
    
    private func setupCategoryStackView() {
        // Clear existing subviews to prevent duplicates on reload
        for subview in categoryStackView.arrangedSubviews {
            categoryStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        
        // Create buttons for existing categories
        for category in categories {
            let categoryButton = createCategoryButton(category)
            categoryStackView.addArrangedSubview(categoryButton)
        }
    }
    
    private func createCategoryButton(_ category: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(category, for: .normal)
        button.backgroundColor = .systemCyan
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }
    
    private func addNewCategory(_ categoryName: String) {
        if !categoryStackView.arrangedSubviews.contains(where: { ($0 as? UIButton)?.titleLabel?.text == categoryName }) {
            let categoryButton = createCategoryButton(categoryName)
            categoryStackView.insertArrangedSubview(categoryButton, at: categoryStackView.arrangedSubviews.count - 1)
        }
    }
    
    private func deleteRemovedCategoriesAndIngredients(from recipe: Recipe) {
        if let categories = recipe.belongTo as? Set<Category> {
            for category in categories {
                if !self.categories.contains(category.name!) {
                    // Remove existing categories that are not in the updated categories list
                    recipe.removeFromBelongTo(category)
                    coreDataStack.managedContext.delete(category)
                }
            }
        }
    }
    
    @objc private func saveButtonTapped() {
        guard let recipeName = recipeNameInput.text, !recipeName.isEmpty,
              let recipeDescription = descriptionInput.text, !recipeDescription.isEmpty else {
            displayErrorMessage("Recipe name and description are required.")
            return
        }

        var selectedCategories: [Category] = []
        
        for subview in categoryStackView.arrangedSubviews {
            if let button = subview as? UIButton, button.isSelected {
                if let categoryName = button.titleLabel?.text {
                    let category = saveCategoryToCoreData(categoryName: categoryName)
                    selectedCategories.append(category)
                }
            }
        }
        
        if let existingRecipe = recipe {
            updateExistingRecipe(existingRecipe, name: recipeName, description: recipeDescription, categories: selectedCategories)
        } else {
            createNewRecipe(name: recipeName, description: recipeDescription, categories: selectedCategories)
        }
        
        coreDataStack.saveContext()
        
        // Notify the delegate and dismiss the view controller
        if let editedRecipe = recipe {
            delegate?.didSaveChangesToRecipe(editedRecipe)
        } else {
            delegate?.didAddNewRecipe(recipe!)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func updateExistingRecipe(_ recipe: Recipe, name: String, description: String, categories: [Category]) {
        recipe.recipeName = name
        recipe.recipeDescription = description
        recipe.recipeInstruction = instructionInput.text
                
        // Add selected categories to the recipe
        for category in categories {
            recipe.addToBelongTo(category)
        }
        
        for ingredientData in ingredientsData {
            let recipeIngredient = findRecipeIngredient(with: ingredientData.name, in: recipe)
            if let recipeIngredient = recipeIngredient {
                recipeIngredient.quantity = ingredientData.quantity
                if let ingredient = findIngredient(with: ingredientData.name) {
                    ingredient.unit = ingredientData.unit
                }
            } else {
                // Add new ingredients
                let recipeIngredient = RecipeIngredient(context: coreDataStack.managedContext)
                recipeIngredient.ingredientName = ingredientData.name
                recipeIngredient.quantity = ingredientData.quantity
                recipe.addToUses(recipeIngredient)
                
                if let ingredient = findIngredient(with: ingredientData.name) {
                    ingredient.unit = ingredientData.unit
                }
            }
        }
    }
    
    private func createNewRecipe(name: String, description: String, categories: [Category]) {
        let newRecipe = Recipe(context: coreDataStack.managedContext)
        newRecipe.recipeName = name
        newRecipe.recipeDescription = description
        newRecipe.recipeInstruction = instructionInput.text // Save instruction
        
        for category in categories {
            newRecipe.addToBelongTo(category)
        }
        
        for ingredientData in ingredientsData {
            let recipeIngredient = RecipeIngredient(context: coreDataStack.managedContext)
            recipeIngredient.ingredientName = ingredientData.name
            recipeIngredient.quantity = ingredientData.quantity
            newRecipe.addToUses(recipeIngredient)
            
            if let ingredient = findIngredient(with: ingredientData.name) {
                ingredient.unit = ingredientData.unit
            }
        }
    }
    
    private func displayErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    private func findRecipeIngredient(with name: String, in recipe: Recipe) -> RecipeIngredient? {
        return recipe.uses?.first(where: { ($0 as? RecipeIngredient)?.ingredientName == name }) as? RecipeIngredient
    }
    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func loadExistingCategories() {
        if let recipeCategories = recipe?.belongTo as? Set<Category> {
            for category in recipeCategories {
                addCategoryButtonToStack(categoryName: category.name!)
            }
        } else {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            do {
                let context = coreDataStack.managedContext
                let results = try context.fetch(fetchRequest)
                for category in results {
                    addCategoryButtonToStack(categoryName: category.name!)
                }
            } catch {
                print("Error fetching categories: \(error)")
            }
        }
    }
    
    private func addCategoryButtonToStack(categoryName: String) {
        let button = UIButton(type: .system)
        button.setTitle(categoryName, for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        categoryStackView.addArrangedSubview(button)
    }
    
    @objc private func categoryButtonTapped(sender: UIButton) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? .systemCyan : .lightGray
        sender.layer.cornerRadius = 10
    }
    
    @objc private func userCategoryButtonTapped() {
        let alertController = UIAlertController(title: "Add Category", message: "Enter the category name:", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Category Name"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alertController] _ in
            guard let self = self, let textField = alertController?.textFields?.first else {
                return
            }
            
            if let categoryName = textField.text, !categoryName.isEmpty {
                self.addCategoryButtonToStack(categoryName: categoryName)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func saveCategoryToCoreData(categoryName: String) -> Category {
        let context = coreDataStack.managedContext
        let category = Category(context: context)
        category.name = categoryName
        coreDataStack.saveContext()
        return category
    }
}
