import UIKit

class LogoutButton: UIButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Perform the logout action here
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        let loginViewController = ViewController()
        let navigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.modalPresentationStyle = .fullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
    }
}

class MeasurementSwitch: UISwitch {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Save the measurement preference to UserDefaults
        UserDefaults.standard.set(isOn, forKey: "useImperialSystem")
    }
}
