import UIKit

class FloatingButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Customize the appearance of the floating button
        backgroundColor = .magenta
        setTitle("+", for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
}
