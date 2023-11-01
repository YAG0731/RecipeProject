import UIKit
import CoreData


protocol RecipeDetailViewControllerDelegate: AnyObject {
    func recipeDetailViewController(_ viewController: RecipeDetailViewController, didUpdateFavoriteStatusFor recipe: Recipe)
    func recipeDetailViewController(_ viewController: RecipeDetailViewController, didSaveChangesTo recipe: Recipe)
    
}

class RecipeDetailViewController: UIViewController, EditRecipeDelegate {
    func didUpdateRecipeName(_ recipe: Recipe, newName: String) {
        recipeNameLabel.text = newName
    }
    
    func didAddNewRecipe(_ recipe: Recipe) {
    }
    
    weak var delegate: RecipeDetailViewControllerDelegate?
    
    // MARK: - Properties
    var coreDataStack: CoreDataStack!
    private var originalQuantities: [Double] = []
    var recipe: Recipe?
    let contentView = UIView()
    let tableReuseId = "HonrizontalTableViewCell"
    
    private var originalIngredientQuantities: [Double] = []
    private var servingSizeAlertController: UIAlertController?
    private var servingSizePickerView: UIPickerView?
    
    var adjustServingButton = UIButton()
    
    private let servingSizePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let servingSizes: [Int] = [1, 2, 3, 4, 5, 6]
    
    var ingredientsData: [(name: String, quantity: Double, unit: String, imageName: String)] = []
    // Define the tuple to hold ingredient data
    typealias IngredientData = (name: String, quantity: Double, unit: String, imageName: String)
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let recipeNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center // Align the text to the left
        label.numberOfLines = 0 // Allow multiple lines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let ingredientsHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Recipe Ingredients"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let ingredientLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left // Align the text to the left
        label.numberOfLines = 0 // Allow multiple lines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionsHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Instructions"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left // Align the text to the left
        label.numberOfLines = 0 // Allow multiple lines
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //populateData()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupScrollView()
        setupViews()
        populateData()
        
        favoriteButton.isSelected = recipe?.isFavorite ?? false
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
        
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        updateFavoriteButton()
        
        setupServingSizePicker()
        
    }
    
    private func setupServingSizePicker() {
        // Add the picker to the content view
        scrollView.addSubview(servingSizePicker)
        
        // Set constraints for the picker
        NSLayoutConstraint.activate([
            servingSizePicker.topAnchor.constraint(equalTo: recipeNameLabel.bottomAnchor, constant: 90),
            servingSizePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 210),
            servingSizePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            servingSizePicker.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Set the picker's data source and delegate
        servingSizePicker.dataSource = self
        servingSizePicker.delegate = self
        servingSizePicker.subviews.forEach {
            $0.subviews.forEach {
                if let label = $0 as? UILabel {
                    label.font = UIFont.systemFont(ofSize: 5)
                }
            }
        }
    }
    
    @objc private func servingSizeSliderValueChanged(_ sender: UISlider) {
        let selectedServingSize = Int(sender.value)
        adjustIngredientQuantities(for: selectedServingSize)
        tableView.reloadData()
    }
    
    private func adjustIngredientQuantities(for servingSize: Int) {
        // Update the ingredientsData array with adjusted quantities based on the original quantities
        for index in 0..<ingredientsData.count {
            let originalQuantity = originalQuantities[index]
            let adjustedQuantity = originalQuantity * Double(servingSize)
            ingredientsData[index].quantity = adjustedQuantity
        }
        // Refresh the table view to display the updated ingredient quantities
        tableView.reloadData()
    }
    
    @objc private func editButtonTapped() {
        let editViewController = EditRecipeViewController()
        editViewController.recipe = recipe
        editViewController.coreDataStack = coreDataStack
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    private func convertIngredientQuantity(quantity: Double, unit: String) -> (quantity: Double, unitLabel: String) {
        // Get the measurement system preference from UserDefaults
        let isMetricSystem = UserDefaults.standard.bool(forKey: "MetricSystemPreference")
        
        if isMetricSystem {
            // Convert to metric system (if needed)
            switch unit {
            case "cup(s)":
                return (quantity * 240, "ml")
            case "teaspoon(s)":
                return (quantity * 5, "ml")
            case "tablespoon(s)":
                return (quantity * 15, "ml")
            case "ounces(oz)":
                return (quantity * 28.35, "g")
                
            default:
                return (quantity, unit)
            }
        } else {
            return (quantity, unit)
        }
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add a content view to the scroll view
        scrollView.addSubview(contentView)
        
        // Set constraints for the content view to make it scrollable
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
    }
    
    private func setupViews() {
        view.addSubview(recipeImageView)

        NSLayoutConstraint.activate([
            recipeImageView.topAnchor.constraint(equalTo: view.topAnchor),
            recipeImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recipeImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recipeImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.1)
        ])
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        
        // Add the recipe name label
        scrollView.addSubview(recipeNameLabel)
        // Set constraints for the recipe name label
        NSLayoutConstraint.activate([
            recipeNameLabel.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 5),
            recipeNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recipeNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            recipeNameLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        scrollView.addSubview(editButton)
        NSLayoutConstraint.activate([
            editButton.centerYAnchor.constraint(equalTo: recipeNameLabel.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            editButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        

        scrollView.addSubview(categoryStackView)

        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: recipeNameLabel.bottomAnchor, constant: 5),
            categoryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryStackView.heightAnchor.constraint(equalToConstant: 40) // Adjust the height as needed
            
        ])
        
        scrollView.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: categoryStackView.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
        
        scrollView.addSubview(ingredientsHeaderLabel)
        NSLayoutConstraint.activate([
            ingredientsHeaderLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            ingredientsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ingredientsHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ingredientsHeaderLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        scrollView.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .lightGray
        tableView.register(HorizontalTableViewCell.self, forCellReuseIdentifier: tableReuseId)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: ingredientsHeaderLabel.bottomAnchor, constant: 5),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.65)
        ])
        
        scrollView.addSubview(instructionsHeaderLabel)
        NSLayoutConstraint.activate([
            instructionsHeaderLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 5),
            instructionsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionsHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            instructionsHeaderLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        scrollView.addSubview(instructionLabel)
        instructionLabel.textAlignment = .justified
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo:instructionsHeaderLabel.bottomAnchor, constant: 5),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            instructionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
        ])
    }
    
    private var isRecipeFavorite: Bool {
        get {
            guard let recipeID = recipe?.id else { return false }
            return UserDefaults.standard.bool(forKey: "FavoriteRecipe_\(recipeID)")
        }
        set {
            guard let recipeID = recipe?.id else { return }
            UserDefaults.standard.set(newValue, forKey: "FavoriteRecipe_\(recipeID)")
        }
    }
    
    @objc private func favoriteButtonTapped(_ sender: UIButton) {
        guard let selectedRecipe = recipe else {
            return
        }
        
        UserDefaultsManager.setRecipeFavorite(selectedRecipe.recipeName!, isFavorite: isRecipeFavorite)
        
        favoriteButton.isSelected = selectedRecipe.isFavorite
    }
    
    func updateFavoriteButton() {
        guard let recipe = recipe else { return }
        favoriteButton.isSelected = recipe.isFavorite
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
    
    func fetchIngredientUnit(name: String) -> String? {
        if let ingredientEntity = findIngredient(with: name) {
            return ingredientEntity.unit
        }
        return nil
    }
    
    
    private func populateData() {
        guard let recipe = recipe else {
            return
        }
        
        recipeImageView.image = UIImage(named: recipe.recipeImageName ?? "")
        recipeNameLabel.text = recipe.recipeName
        descriptionLabel.text = recipe.recipeDescription
        instructionLabel.text = recipe.recipeInstruction

        if let categories = recipe.belongTo as? Set<Category> {
            for category in categories {
                let categoryLabel = UILabel()
                categoryLabel.text = category.name
                categoryLabel.backgroundColor = .white
                categoryLabel.textAlignment = .center
                categoryLabel.layer.cornerRadius = 10
                categoryLabel.layer.borderWidth = 1
                categoryLabel.layer.borderColor = UIColor.lightGray.cgColor
                categoryLabel.clipsToBounds = true
                categoryLabel.font = UIFont.systemFont(ofSize: 12)
                
                let padding: CGFloat = 10
                let widthConstraint = categoryLabel.widthAnchor.constraint(equalToConstant: categoryLabel.intrinsicContentSize.width + padding)
                widthConstraint.priority = .defaultHigh
                widthConstraint.isActive = true
                categoryStackView.addArrangedSubview(categoryLabel)
            }
        }
        
        ingredientsData.removeAll()
        
        // Retrieve and store the ingredients
        if let recipeIngredients = recipe.uses as? Set<RecipeIngredient> {
            for recipeIngredient in recipeIngredients {
                guard let ingredientName = recipeIngredient.ingredientName else {
                    continue
                }
                let quantity = recipeIngredient.quantity
                let imageName = "PlaceholderImageName"
                
     
                if let ingredientSet = recipeIngredient.need as? Set<Ingredient>, let ingredient = ingredientSet.first {
                    if let unit = fetchIngredientUnit(name: ingredientName) {
      
                        let ingredientData: IngredientData = (name: ingredientName, quantity: quantity, unit: unit, imageName: imageName)
                        ingredientsData.append(ingredientData)
                    } else {
                        let ingredientData: IngredientData = (name: ingredientName, quantity: quantity, unit: "", imageName: imageName)
                        ingredientsData.append(ingredientData)
                    }
                } else {

                    let ingredientData: IngredientData = (name: ingredientName, quantity: quantity, unit: "", imageName: imageName)
                    ingredientsData.append(ingredientData)
                }
            }
        }
        
        originalQuantities = ingredientsData.map { $0.quantity }
        
        let isMetricSystem = UserDefaults.standard.bool(forKey: "MetricSystemPreference")
        
        tableView.reloadData()
    }
}


extension RecipeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredientsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableReuseId, for: indexPath) as! HorizontalTableViewCell
        
        let ingredient = ingredientsData[indexPath.row]
        
        // Set the ingredient image
        if let ingredientEntity = findIngredient(with: ingredient.name) {
            if let imageName = ingredientEntity.imageName, let image = UIImage(named: imageName) {
                cell.ingredientImageView.image = image
            } else {
                cell.ingredientImageView.image = UIImage(named: "defaultrecipe")
            }
            // Set the ingredient information next to the image
            cell.unitLabel.text = fetchIngredientUnit(name: ingredient.name)
            let convertedQuantity = convertIngredientQuantity(quantity: ingredient.quantity, unit: ingredient.unit)
            cell.quantityLabel.text = String(convertedQuantity.quantity)
            cell.unitLabel.text = convertedQuantity.unitLabel
            cell.titleLabel.text = ingredient.name
            
        } else {
            cell.ingredientImageView.image = UIImage(named: "defaultrecipe")
            cell.unitLabel.text = fetchIngredientUnit(name: ingredient.name)
            let convertedQuantity = convertIngredientQuantity(quantity: ingredient.quantity, unit: ingredient.unit)
            cell.quantityLabel.text = String(convertedQuantity.quantity)
            cell.unitLabel.text = convertedQuantity.unitLabel
            cell.titleLabel.text = ingredient.name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}


extension RecipeDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return servingSizes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(servingSizes[row]) serving(s)"
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = "\(servingSizes[row]) serving(s)"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14) // Set your desired font size here
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tableView.reloadData()
        let selectedServingSize = servingSizes[row]
        adjustIngredientQuantities(for: selectedServingSize)
    
        tableView.reloadData()
    }
    
    
    func didSaveChangesToRecipe(_ editedRecipe: Recipe) {
        delegate?.recipeDetailViewController(self, didSaveChangesTo: editedRecipe)
    }
}
