//
//  SignInOptionsViewController.swift
//  testFBGG
//
//  Created by Florian Peyrony on 05/12/2022.
//

import UIKit
import FirebaseCore// there
import FirebaseAuth
import GoogleSignIn// to there

import FacebookLogin

import FacebookCore //there
import FirebaseDatabase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase //to there
 

class SignInOptionsViewController: UIViewController, LoginButtonDelegate {
    
    // MARK: - Properties
    var userInfo: User?
    var service = FirebaseService()
   
    // MARK: - Textfields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var basketBallImage: UIImageView!
    
    // MARK: - Buttons
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var signInWithGoogleButton: UIButton!
    @IBOutlet weak var signInWithFacebookButton: UIButton!
    @IBOutlet weak var alreadyAnAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpButtonsSkin()
    }
    
    // MARK: - Functions
    
    @objc func successLogin() {
        print("Inscription de \(usernameTextField.text ?? "no name")")
        self.performSegue(withIdentifier: "segueToMain", sender: userInfo)
    }
    
    @objc func failLogin() {
        print("Error : Missing Username, password or adress")
        
        self.presentAlert(title: "ERROR", message: "Connection rejected")
    }
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        service.facebookButton()
        
        let success = Notification.Name(rawValue: "FBAnswerSuccess")
        let fail = Notification.Name(rawValue: "FBAnswerFail")
        NotificationCenter.default.addObserver(self, selector: #selector(successLogin), name: success, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failLogin), name: fail, object: nil)
    }
        
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        print("We want now fb disconnect account")
    }
    
    
    @IBAction func didPressCreateAnAccount(_ sender: Any) {
        
        if usernameTextField.text != "" && password.text != "" && emailTextField.text != "" {
            print("Inscription de \(usernameTextField.text ?? "no name")")
            service.doesEmailExist(email: emailTextField.text!) { [self] (exists) in
                    if exists {
                        // Si l'e-mail existe déjà, affichez un message d'erreur à l'utilisateur.
                        print("Cette adresse email est déjà utilisée.")
                        self.presentAlert(title: "ERROR", message: "This email address is already in use.")
                    } else {
                        service.signInEmailButton(email: self.emailTextField.text!, username: self.usernameTextField.text!, password: self.password.text!)
                        self.performSegue(withIdentifier: "segueToMain", sender: userInfo)
                    }
                }
        } else {
            print("Error : Missing Username, password or adress")
            self.presentAlert(title: "ERROR", message: "Add a valid e-mail or password")
        }
    }
        
    @IBAction func didPressGoogle(_ sender: Any) {
        service.signInByGmail(viewController: self)
        let success = Notification.Name(rawValue: "FBAnswerSuccess")
        let fail = Notification.Name(rawValue: "FBAnswerFail")
        NotificationCenter.default.addObserver(self, selector: #selector(successLogin), name: success, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failLogin), name: fail, object: nil)
    }
    
    func setUpButtonsSkin() {
        signInWithGoogleButton.layer.borderWidth = 1
        signInWithGoogleButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        signInWithGoogleButton.layer.cornerRadius = 20
        createAccountButton.layer.borderWidth = 1
        createAccountButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        createAccountButton.layer.cornerRadius = 20
        createAccountButton.backgroundColor?.withAlphaComponent(0.20)
        alreadyAnAccountButton.layer.borderWidth = 1
        alreadyAnAccountButton.layer.cornerRadius = 20
        alreadyAnAccountButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        alreadyAnAccountButton.backgroundColor?.withAlphaComponent(0.20)
        
        usernameTextField.layer.borderWidth = 1
        usernameTextField.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
        password.layer.borderWidth = 1
        password.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
        
        var loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.center = signInWithFacebookButton.center
        loginButton.bounds = signInWithGoogleButton.bounds
        loginButton.layer.cornerRadius = 20
        loginButton.titleLabel?.text = "Sign in with Facebook"
        view.addSubview(loginButton)
        
        signInWithGoogleButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 18)!
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToMain" {
            let successVC = segue.destination as? MainPageViewController
            let userInfo = sender as? User
            successVC?.userInfo = userInfo
        }
    }
    
    // MARK: - Alerts
    
    func presentAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
}
