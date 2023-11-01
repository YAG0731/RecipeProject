import UIKit


class HorizontalTableViewCell: UITableViewCell {
    static let reuseIdentifier = "RecipeCell"
    
    let ingredientImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
       
        return label
    }()
    
    let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        //label.textAlignment = .right
        return label
    }()
    
    let unitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        //label.textAlignment = .right
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10))
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.layer.borderColor = UIColor.lightGray.cgColor


        contentView.layer.borderWidth = 1
        //contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 6

        
        // Add subviews and setup constraints here
        contentView.addSubview(ingredientImageView)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(unitLabel)
        contentView.addSubview(titleLabel)
        //contentView.addSubview(favoriteButton)
        
        
        // Add and configure constraints for subviews
        ingredientImageView.translatesAutoresizingMaskIntoConstraints = false
        ingredientImageView.contentMode = .scaleAspectFill
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        unitLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Image View Constraints
        NSLayoutConstraint.activate([
            ingredientImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ingredientImageView.widthAnchor.constraint(equalToConstant: 50),
            ingredientImageView.heightAnchor.constraint(equalToConstant: 50),
            ingredientImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: ingredientImageView.trailingAnchor, constant: 5),
        ])

        
        NSLayoutConstraint.activate([
            quantityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            quantityLabel.trailingAnchor.constraint(equalTo: unitLabel.leadingAnchor, constant: -2),
        ])
        
        NSLayoutConstraint.activate([
            unitLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            unitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])

       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(imageName: String, quantities: Double, ingredientunit: String, labelText: String ) {
        ingredientImageView.image = UIImage(named: imageName)
        titleLabel.text = labelText
        unitLabel.text = ingredientunit
        quantityLabel.text = String(quantities)
        
    }


}
