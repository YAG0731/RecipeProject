import UIKit

class SettingsViewController: UIViewController, BottomTabBarViewDelegate {
    
    var bottomTabBarView: BottomTabBarView!
    var titleLabel = UILabel()
    var measurementLabel = UILabel()
    var metricLabel = UILabel() // Label for "Metric" option
    var imperialLabel = UILabel() // Label for "Imperial" option
    
    let logoutButton = LogoutButton()
    
    private let measurementSystemSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = UserDefaults.standard.bool(forKey: "MetricSystemPreference")
        switchControl.addTarget(self, action: #selector(toggleMeasurementSystem), for: .valueChanged)
        return switchControl
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Call setSelectedTab method with the appropriate index
        bottomTabBarView.setSelectedTab(at: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        titleLabel.text = "Settings"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Add constraints
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
        ])
        
        measurementLabel.text = "Measurement System:"
        measurementLabel.textColor = .black
        measurementLabel.font = UIFont.systemFont(ofSize: 16)
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(measurementLabel)
        
        // Add constraints for the measurement label
        NSLayoutConstraint.activate([
            measurementLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            measurementLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
        ])
        
        measurementSystemSwitch.translatesAutoresizingMaskIntoConstraints = false
        // Add constraints for the measurement switch
        view.addSubview(measurementSystemSwitch)
        
        NSLayoutConstraint.activate([
            measurementSystemSwitch.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            measurementSystemSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        metricLabel.text = "Metric"
        metricLabel.textColor = .black
        metricLabel.font = UIFont.systemFont(ofSize: 16)
        metricLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(metricLabel)
        
        // Add constraints for the metric label
        NSLayoutConstraint.activate([
            metricLabel.trailingAnchor.constraint(equalTo: measurementSystemSwitch.leadingAnchor, constant: -10),
            metricLabel.centerYAnchor.constraint(equalTo: measurementSystemSwitch.centerYAnchor),
        ])
        
        imperialLabel.text = "Imperial"
        imperialLabel.textColor = .black
        imperialLabel.font = UIFont.systemFont(ofSize: 16)
        imperialLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imperialLabel)
        
        // Add constraints for the imperial label
        NSLayoutConstraint.activate([
            imperialLabel.leadingAnchor.constraint(equalTo: measurementSystemSwitch.trailingAnchor, constant: 10),
            imperialLabel.centerYAnchor.constraint(equalTo: measurementSystemSwitch.centerYAnchor),
        ])
        
       
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.layer.cornerRadius = 10
        logoutButton.backgroundColor = .darkGray
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        // Add constraints for the logout button
        NSLayoutConstraint.activate([
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            logoutButton.widthAnchor.constraint(equalToConstant: 100),
            logoutButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        bottomTabBarView = BottomTabBarView(buttonTitles: ["", ""], images: [UIImage(systemName: "house"), UIImage(systemName: "gear")])
        bottomTabBarView.delegate = self
        bottomTabBarView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bottomTabBarView)
        
        // Add constraints to position the bottom tab bar at the bottom of the view
        NSLayoutConstraint.activate([
            bottomTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomTabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.bounds.height * 0.86),
            bottomTabBarView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    @objc private func toggleMeasurementSystem(_ sender: UISwitch) {
        let isMetricSystem = sender.isOn
        UserDefaults.standard.set(isMetricSystem, forKey: "MetricSystemPreference")
    }
    
    func didSelectTab(at index: Int) {
        if index == 0 {
            let homevc  = HomeViewController()
            navigationController?.pushViewController(homevc, animated: true)
        } else if index == 1 {
            // Handle navigation to other view controllers for the second tab
        }
    }
}
