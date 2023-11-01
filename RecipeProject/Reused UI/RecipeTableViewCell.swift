import UIKit

class RecipeTableViewCell: UITableViewCell {
    static let reuseIdentifier = "RecipeCell"
    var favoriteButtonTapped: (() -> Void)?
    
    let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var favoriteButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(systemName: "heart"), for: .normal)
            button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
            button.tintColor = .red
            button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)

            return button
        }()

    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
//    let favoriteButton: UIButton = {
//        let button = UIButton()
//        // Customize the button appearance here
//        return button
//    }()
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    let categoryStackView: CategoryTagsView = {
            let stackView = CategoryTagsView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 4
        contentView.layer.borderWidth = 2
        contentView.layer.masksToBounds = false
        contentView.layer.cornerRadius = 6

        
        // Add subviews and setup constraints here
        contentView.addSubview(recipeImageView)
        contentView.addSubview(titleLabel)
        //contentView.addSubview(favoriteButton)
        contentView.addSubview(categoryStackView)
        
        // Add and configure constraints for subviews
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        recipeImageView.contentMode = .scaleAspectFill
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the favorite button to the cell's contentView
        contentView.addSubview(favoriteButton)

        // Image View Constraints
        NSLayoutConstraint.activate([
            recipeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            recipeImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            recipeImageView.widthAnchor.constraint(equalToConstant: 300),
            recipeImageView.heightAnchor.constraint(equalToConstant: 150),
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            recipeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
            
        ])

        // Title Label Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: recipeImageView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: recipeImageView.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            //favoriteButton.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 5),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            favoriteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 50),
            favoriteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        // Categories Label Constraints
        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            categoryStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 10),
            categoryStackView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -10),
            categoryStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    @objc private func favoriteButtonTapped(_ sender: UIButton) {
            favoriteButtonTapped?() // Call the closure when the favorite button is tapped
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(imageName: UIImage, labelText: String, categories: [String]) {
        recipeImageView.image = imageName
        titleLabel.text = labelText
        categoryStackView.setCategories(categories)
    }


}
