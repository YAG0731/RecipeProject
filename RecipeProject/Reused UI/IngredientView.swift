import UIKit

class IngredientView: UIView {
    // Add the necessary subviews for displaying ingredient information
    typealias IngredientData = (name: String, quantity: Double, unit: String, imageName: String)

    
    var ingredientImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        //label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        //label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var unitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        //label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Initialize and set up the constraints for the subviews
    init() {
        super.init(frame: .zero)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(ingredientImageView)
        addSubview(nameLabel)
        addSubview(quantityLabel)
        addSubview(unitLabel)
        
        // Set constraints for the subviews
        NSLayoutConstraint.activate([
            ingredientImageView.widthAnchor.constraint(equalToConstant: 50),
            ingredientImageView.heightAnchor.constraint(equalToConstant: 50),
            ingredientImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            ingredientImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: ingredientImageView.trailingAnchor, constant: 5),
            nameLabel.topAnchor.constraint(equalTo: topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            quantityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            quantityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            quantityLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            unitLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            unitLabel.topAnchor.constraint(equalTo: quantityLabel.bottomAnchor, constant: 4),
            unitLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            unitLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // Configure the view with ingredient data
    func configure(imageName: String, quantities: Double, ingredientunit: String, labelText: String ) {
        ingredientImageView.image = UIImage(named: imageName)
        nameLabel.text = labelText
        quantityLabel.text = String(quantities)
        unitLabel.text = ingredientunit
    }
}
