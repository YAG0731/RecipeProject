import UIKit

class CategoryCell: UICollectionViewCell {
    // Your other cell properties and UI elements
    let categoryLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Customize your cell's UI elements here
        categoryLabel.textAlignment = .center
        categoryLabel.font = UIFont.systemFont(ofSize: 16)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryLabel)

        // Add constraints to position the label in the cell
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        // Additional styling if needed
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 10
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 1
    }

    func configure(with categoryName: String, isSelected: Bool) {
        // Configure the cell based on the category name
        categoryLabel.text = categoryName
        contentView.backgroundColor = isSelected ? .cyan : .clear
    }
}
