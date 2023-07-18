//
//  LogInViewController.swift
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

class LogInViewController: UIViewController, LoginButtonDelegate {
    
    // MARK: - Properties
    
    var userInfo: User?
    var service = FirebaseService()
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var createAnAccountButton: UIButton!
    @IBOutlet weak var basketBallImage: UIImageView!
    
    @IBOutlet weak var signInWithGoogleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpButtonsSkin()
        service.viewController = self
        // Do any additional setup after loading the view.
    }

    
    // MARK: - Buttons
   
    @objc(loginButton:didCompleteWithResult:error:) func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        
        service.facebookButton()
        
        let success = Notification.Name(rawValue: "FBAnswerSuccess")
        let fail = Notification.Name(rawValue: "FBAnswerFail")
        NotificationCenter.default.addObserver(self, selector: #selector(successFBLogin), name: success, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(failFBLogin), name: fail, object: nil)
    }
    
    
    // MARK: - Functions
    
    
    @IBAction func didPressGoogleButton(_ sender: Any) {
        service.signInByGmail(viewController: self)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        print("We want now fb disconnect account")
    }
    
    
    @objc func successFBLogin() {
        print("Inscription de \(emailTextField.text ?? "no name")")
        self.performSegue(withIdentifier: "segueToMain", sender: userInfo)
    }
    
    @objc func failFBLogin() {
        print("Error : Missing Username, password or adress")
        
        self.presentAlert(title: "ERROR", message: "Connection from Facebook rejected")
    }
     
     @IBAction func logInButton(_ sender: Any) {
         if emailTextField.text != "" && passwordTextField.text != nil {
             print("Connexion de \(emailTextField.text ?? "no adress")")
            
             
             service.logInEmailButton(email: emailTextField.text!, password: passwordTextField.text!) { (success) in
                 DispatchQueue.main.async {
                     if success {
                         // Effectuer la redirection ici
                         self.performSegue(withIdentifier: "segueToMain", sender: self.userInfo)
                     } else {
                         self.presentAlert(title: "ERROR", message: "Invalid password or Email")
                     }
                 }
             }

         } else {
             presentAlert(title: "ERROR", message: "Missing Email or password")
             print("Error : Missing Email or password")
         }
     }
    
    func setUpButtonsSkin() {
        createAnAccountButton.layer.borderWidth = 1
        createAnAccountButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        createAnAccountButton.layer.cornerRadius = 20
        createAnAccountButton.backgroundColor?.withAlphaComponent(0.20)
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        logInButton.layer.cornerRadius = 20
        logInButton.backgroundColor?.withAlphaComponent(0.20)
        
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
        
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.center = view.center
        loginButton.bounds = createAnAccountButton.bounds
        loginButton.layer.cornerRadius = 20
        loginButton.titleLabel?.text = "Log in with Facebook"
        view.addSubview(loginButton)
        signInWithGoogleButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 18)!
    }
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
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
