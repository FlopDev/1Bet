//
//  SignInOptionsViewController.swift
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

/// Controller for handling sign-in options such as Google, Facebook, and email registration.
class SignInOptionsViewController: UIViewController, LoginButtonDelegate {
    
    // MARK: - Properties
    
    /// Holds user information after successful login.
    var userInfo: User?
    
    /// Instance of FirebaseService for handling Firebase-related functionalities.
    var service = FirebaseService()
    
    /// UIStackView for organizing the login buttons in the view.
    private var stackView: UIStackView!
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var basketBallImage: UIImageView!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var signInWithGoogleButton: UIButton!
    @IBOutlet weak var signInWithFacebookButton: UIButton!
    @IBOutlet weak var alreadyAnAccountButton: UIButton!
    
    // MARK: - Lifecycle
    
    /// Called after the view has been loaded. Configures the appearance and layout of the buttons and stack view.
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtonsSkin()
        setupStackView()
    }
    
    // MARK: - Functions
    
    /// Called when the login is successful; navigates to the main screen.
    @objc func successLogin() {
        print("Sign in successful for \(usernameTextField.text ?? "unknown user")")
        self.performSegue(withIdentifier: "segueToMain", sender: userInfo)
    }
    
    /// Called when login fails, presenting an alert message to the user.
    @objc func failLogin() {
        UIAlert.presentAlert(from: self, title: "ERROR", message: "Connection rejected")
    }
    
    /// Handles login through Facebook. Sets up notifications for successful or failed login.
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        service.facebookButton()
        
        let success = Notification.Name(rawValue: "FBAnswerSuccess")
        let fail = Notification.Name(rawValue: "FBAnswerFail")
        NotificationCenter.default.addObserver(self, selector: #selector(successLogin), name: success, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failLogin), name: fail, object: nil)
    }
    
    /// Called when the user logs out from Facebook.
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        print("Facebook account logged out")
    }
    
    /// Action triggered by the Create Account button. Attempts to register a new account if all fields are filled.
    @IBAction func didPressCreateAnAccount(_ sender: Any) {
        if usernameTextField.text != "" && password.text != "" && emailTextField.text != "" {
            print("Registering \(usernameTextField.text ?? "unknown user")")
            service.doesEmailExist(email: emailTextField.text!) { [self] (exists) in
                if exists {
                    // Email already in use
                    print("Email already in use")
                    UIAlert.presentAlert(from: self, title: "ERROR", message: "This email address is already in use")
                } else {
                    service.signInEmailButton(email: self.emailTextField.text!, username: self.usernameTextField.text!, password: self.password.text!)
                    self.performSegue(withIdentifier: "segueToMain", sender: userInfo)
                }
            }
        } else {
            print("Error: Missing username, password, or email")
            UIAlert.presentAlert(from: self, title: "ERROR", message: "Add a valid email or password")
        }
    }
    
    /// Hides the keyboard when the user taps outside the text fields.
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    /// Initiates Google sign-in when the Google button is pressed.
    @IBAction func didPressGoogle(_ sender: Any) {
        service.signInByGmail(viewController: self)
        let success = Notification.Name(rawValue: "FBAnswerSuccess")
        let fail = Notification.Name(rawValue: "FBAnswerFail")
        NotificationCenter.default.addObserver(self, selector: #selector(successLogin), name: success, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failLogin), name: fail, object: nil)
    }
    
    /// Configures the appearance of the buttons, including borders and corner radius.
    func setUpButtonsSkin() {
        signInWithGoogleButton.layer.borderWidth = 1
        signInWithGoogleButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        signInWithGoogleButton.layer.cornerRadius = 20
        createAccountButton.layer.borderWidth = 1
        createAccountButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        createAccountButton.layer.cornerRadius = 20
        alreadyAnAccountButton.layer.borderWidth = 1
        alreadyAnAccountButton.layer.cornerRadius = 20
        alreadyAnAccountButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        usernameTextField.layer.borderWidth = 1
        usernameTextField.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
        password.layer.borderWidth = 1
        password.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
    }
    
    /// Sets up the Facebook login button with appearance customizations and adds it to the stack view.
    private func setupFacebookLoginButton() {
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        loginButton.layer.cornerRadius = 20
        loginButton.layer.masksToBounds = true
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.insertArrangedSubview(loginButton, at: stackView.arrangedSubviews.count - 1)
        
        for constraint in loginButton.constraints where constraint.firstAttribute == .height {
            constraint.constant = 50
        }
    }
    
    /// Configures the stack view layout and adds login buttons to it.
    private func setupStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        stackView.addArrangedSubview(createAccountButton)
        stackView.addArrangedSubview(signInWithGoogleButton)
        setupFacebookLoginButton()
        stackView.addArrangedSubview(alreadyAnAccountButton)
        
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        signInWithGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        alreadyAnAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createAccountButton.heightAnchor.constraint(equalToConstant: 50),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 50),
            alreadyAnAccountButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 20),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    // MARK: - Navigation
    
    /// Prepares for segue to the main screen after a successful login.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToMain" {
            let successVC = segue.destination as? MainPageViewController
            let userInfo = sender as? User
            successVC?.userInfo = userInfo
        }
    }
}

// MARK: - UITextFieldDelegate

extension SignInOptionsViewController: UITextFieldDelegate {
    
    /// Dismisses the keyboard when the return key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
