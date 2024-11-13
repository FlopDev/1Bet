//
//  LogInViewController.swift
//  testFBGG
//
//  Created by Florian Peyrony on 05/12/2022.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FacebookLogin
import FacebookCore
import FirebaseDatabase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase

/// Controller for handling login options, including email/password, Google, and Facebook.
class LogInViewController: UIViewController, LoginButtonDelegate {
    
    // MARK: - Properties
    
    /// Holds user information after successful login.
    var userInfo: User?
    
    /// Instance of FirebaseService to handle Firebase-related login functionalities.
    var service = FirebaseService()
    
    /// Stack view to arrange login buttons in the UI.
    private var stackView: UIStackView!
    
    // MARK: - Outlets
    
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var createAnAccountButton: UIButton!
    @IBOutlet weak var basketBallImage: UIImageView!
    @IBOutlet weak var signInWithGoogleButton: UIButton!
    
    // MARK: - Lifecycle
    
    /// Called after the view is loaded, setting up button styles and layout for the stack view.
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtonsSkin()
        service.viewController = self
        setupStackView()
    }
    
    // MARK: - Buttons
    
    /// Handles Facebook login completion, observing for login success or failure notifications.
    @objc(loginButton:didCompleteWithResult:error:) func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        service.facebookButton()
        let success = Notification.Name(rawValue: "FBAnswerSuccess")
        let fail = Notification.Name(rawValue: "FBAnswerFail")
        NotificationCenter.default.addObserver(self, selector: #selector(successFBLogin), name: success, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failFBLogin), name: fail, object: nil)
    }
    
    /// Logs out the user from Facebook.
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        print("User logged out from Facebook")
    }
    
    // MARK: - Functions
    
    /// Initiates Google sign-in when the Google button is pressed.
    @IBAction func didPressGoogleButton(_ sender: Any) {
        service.signInByGmail(viewController: self)
    }
    
    /// Called upon successful Facebook login, segueing to the main view controller.
    @objc func successFBLogin() {
        print("Sign in successful for \(emailTextField.text ?? "unknown email")")
        self.performSegue(withIdentifier: "segueToMain", sender: userInfo)
    }
    
    /// Called upon Facebook login failure, presenting an alert to the user.
    @objc func failFBLogin() {
        print("Facebook login error")
        UIAlert.presentAlert(from: self, title: "ERROR", message: "Connection from Facebook rejected")
    }
    
    /// Attempts to log in with email and password, presenting an alert on failure.
    @IBAction func logInButton(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != nil {
            print("Logging in with email \(emailTextField.text ?? "unknown")")
            service.logInEmailButton(email: emailTextField.text!, password: passwordTextField.text!) { (success) in
                DispatchQueue.main.async {
                    if success {
                        self.performSegue(withIdentifier: "segueToMain", sender: self.userInfo)
                    } else {
                        UIAlert.presentAlert(from: self, title: "ERROR", message: "Invalid password or Email")
                    }
                }
            }
        } else {
            UIAlert.presentAlert(from: self, title: "ERROR", message: "Missing Email or password")
        }
    }
    
    /// Placeholder function for handling forgotten passwords.
    @IBAction func forgetPasswordButton(_ sender: Any) {
        print("Trigger forgot password functionality here")
    }
    
    /// Styles buttons with borders, rounded corners, and background colors.
    func setUpButtonsSkin() {
        createAnAccountButton.layer.borderWidth = 1
        createAnAccountButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        createAnAccountButton.layer.cornerRadius = 20
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        logInButton.layer.cornerRadius = 20
        signInButton.layer.borderWidth = 1
        signInButton.layer.cornerRadius = 20
        signInButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
        
        signInWithGoogleButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 18)!
        
        forgotPasswordButton.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        forgotPasswordButton.titleLabel?.layer.shadowRadius = 3.0
        forgotPasswordButton.titleLabel?.layer.shadowOpacity = 1.0
        forgotPasswordButton.titleLabel?.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    /// Configures and styles the Facebook login button, adding it to the stack view.
    private func setupFacebookLoginButton() {
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        loginButton.layer.cornerRadius = 20
        loginButton.titleLabel?.text = "Log in with Facebook"
        loginButton.layer.masksToBounds = true
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertArrangedSubview(loginButton, at: stackView.arrangedSubviews.count - 1)
        
        for constraint in loginButton.constraints where constraint.firstAttribute == .height {
            constraint.constant = 50
        }
    }
    
    /// Configures the stack view layout, adding login buttons and defining constraints.
    private func setupStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        stackView.addArrangedSubview(logInButton)
        stackView.addArrangedSubview(signInWithGoogleButton)
        setupFacebookLoginButton()
        stackView.addArrangedSubview(signInButton)
        
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        signInWithGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logInButton.heightAnchor.constraint(equalToConstant: 50),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 50),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 90),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    /// Hides the keyboard when the user taps outside the text fields.
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // MARK: - Navigation
    
    /// Prepares for navigation to another view controller, if required by a segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Implement navigation preparation here if needed.
    }
}

extension LogInViewController: UITextFieldDelegate {
    
    /// Dismisses the keyboard when the return key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
