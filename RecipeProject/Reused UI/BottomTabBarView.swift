import UIKit

protocol BottomTabBarViewDelegate: AnyObject {
    func didSelectTab(at index: Int)
}

class BottomTabBarView: UIView {
    weak var delegate: BottomTabBarViewDelegate?
    
    private let tabButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    private var tabButtons: [UIButton] = []
    private let tabButtonTitles: [String]
    private let tabButtonImages: [UIImage?]
    private var selectedIndex: Int = 0 // Store the selected index
    
    init(buttonTitles: [String], images: [UIImage?]) {
        assert(buttonTitles.count == images.count, "Button titles count should be equal to images count.")
        self.tabButtonTitles = buttonTitles
        self.tabButtonImages = images
        super.init(frame: .zero)
        setupTabButtons()
        setupTabButtonStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTabButtons() {
        for (index, title) in tabButtonTitles.enumerated() {
            let button = UIButton()
            button.tag = index
            button.setTitle(title, for: .normal)
            button.setTitleColor(.systemGray, for: .normal)
            button.setTitleColor(.systemBlue, for: .selected)
            button.setImage(tabButtonImages[index]?.withRenderingMode(.alwaysOriginal), for: .normal)
            button.setImage(tabButtonImages[index]?.withTintColor(.systemBlue), for: .selected)
            button.imageView?.contentMode = .scaleAspectFill
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

            button.addTarget(self, action: #selector(tabButtonTapped(sender:)), for: .touchUpInside)
            tabButtons.append(button)
        }
    }
    
    private func setupTabButtonStackView() {
        addSubview(tabButtonStackView)
        tabButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabButtonStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabButtonStackView.topAnchor.constraint(equalTo: topAnchor),
            tabButtonStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        for button in tabButtons {
            tabButtonStackView.addArrangedSubview(button)
        }
        
        // Initially select the first button
        selectTab(at: 0)
    }
    
    @objc private func tabButtonTapped(sender: UIButton) {
        // Call the delegate method to notify the selection
        delegate?.didSelectTab(at: sender.tag)
        
        // Select the tapped button and deselect other buttons
        selectTab(at: sender.tag)
    }
    
    private func selectTab(at index: Int) {
        guard index >= 0 && index < tabButtons.count else {
            return
        }
        
        for (buttonIndex, button) in tabButtons.enumerated() {
            button.isSelected = index == buttonIndex
        }
        
        // Store the selected index
        selectedIndex = index
    }
    
    // Add a method to programmatically select a tab by its index
    func setSelectedTab(at index: Int) {
        selectTab(at: index)
    }
}
