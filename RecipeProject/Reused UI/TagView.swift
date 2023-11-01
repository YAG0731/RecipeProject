import UIKit

class CategoryTagsView: UIStackView {
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        backgroundColor = .black
    }
    
    private func setupView() {
        axis = .horizontal
        spacing = 5 // Adjust the spacing between tags as needed
        distribution = .equalSpacing
    }
    
    func setCategories(_ categories: [String]) {
        // Remove any existing labels from the stack view
        for arrangedSubview in arrangedSubviews {
            arrangedSubview.removeFromSuperview()
        }
        
        // Add new category labels to the stack view
        for category in categories {
            let categoryLabel = UILabel()
            categoryLabel.text = category
            categoryLabel.backgroundColor = .white
            categoryLabel.textAlignment = .center
            categoryLabel.layer.cornerRadius = 6
            categoryLabel.layer.borderWidth = 1
            categoryLabel.layer.borderColor = UIColor.darkGray.cgColor
            categoryLabel.clipsToBounds = true
            categoryLabel.font = UIFont.systemFont(ofSize: 12) 
            
            // Set the width constraint based on intrinsic content size with additional padding
            let padding: CGFloat = 20 // Add any desired padding value
            let widthConstraint = categoryLabel.widthAnchor.constraint(equalToConstant: categoryLabel.intrinsicContentSize.width + padding)
            widthConstraint.priority = .defaultHigh // Use priority to ensure flexibility in layout
            widthConstraint.isActive = true
            
            addArrangedSubview(categoryLabel)
        }
        
        // Center the stack view horizontally within its superview
        alignment = .center
    }
}
