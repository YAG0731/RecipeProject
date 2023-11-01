import UIKit

class ViewController: UIViewController {
    
    var usernameInput = UITextField()
    var passwordInput = UITextField()
    
    var loginButton = UIButton()
    var titleLabel = UILabel()

    var loginViewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Check if the user is signed in or signed out each time the view appears
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")

        if isLoggedIn {
            let homevc = HomeViewController()
            navigationController?.pushViewController(homevc, animated: true)
        }
    }
    
    func setupView(){
        
        titleLabel.text = "Recipe Easy"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Configure username text field
        usernameInput.placeholder = "Username"
        usernameInput.borderStyle = .roundedRect
        usernameInput.autocapitalizationType = .none
        usernameInput.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(usernameInput)
        
        // Configure password text field
        passwordInput.placeholder = "Password"
        passwordInput.isSecureTextEntry = true
        passwordInput.borderStyle = .roundedRect
        passwordInput.autocapitalizationType = .none
        passwordInput.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passwordInput)
        
        // Configure login button
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .blue
        loginButton.layer.cornerRadius = 5.0
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        
        // Add constraints
        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 250),
            
            usernameInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameInput.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            usernameInput.widthAnchor.constraint(equalToConstant: 200),
            usernameInput.heightAnchor.constraint(equalToConstant: 30),
            
            passwordInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordInput.topAnchor.constraint(equalTo: usernameInput.bottomAnchor, constant: 20),
            passwordInput.widthAnchor.constraint(equalToConstant: 200),
            passwordInput.heightAnchor.constraint(equalToConstant: 30),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordInput.bottomAnchor, constant: 30),
            loginButton.widthAnchor.constraint(equalToConstant: 100),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    @objc func loginButtonTapped() {
        guard let username = usernameInput.text, !username.isEmpty,
              let password = passwordInput.text, !password.isEmpty else {
            showAlert(message: "Please enter both username and password.")
            return
        }
        
        loginViewModel.credentials = Credentials(username: username, password: password)
        
        if loginViewModel.authenticateUser() {
            // Successful login
            loginViewModel.saveData() // Store the password in the Keychain
            
            UserDefaults.standard.set(true, forKey: "isLoggedIn") // Save login status
            
            let homevc = HomeViewController()
            navigationController?.pushViewController(homevc, animated: true)
        } else {
            // Failed login
            showAlert(message: "Invalid username or password.")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
