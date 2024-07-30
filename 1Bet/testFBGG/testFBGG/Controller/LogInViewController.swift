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

class LogInViewController: UIViewController, LoginButtonDelegate {
    
    // MARK: - Properties
    
    var userInfo: User?
    var service = FirebaseService()
    private var stackView: UIStackView!
    
    // MARK: - Outlets
    
    @IBOutlet var signInButton: UIButton!
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
        // Appeler la fonction pour configurer la StackView
        setupStackView()
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
        UIAlert.presentAlert(from: self, title: "ERROR", message: "Connection from Facebook rejected")
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
                        UIAlert.presentAlert(from: self, title: "ERROR", message: "Invalid password or Email")
                    }
                }
            }
            
        } else {
            UIAlert.presentAlert(from: self, title: "ERROR", message: "Missing Email or password")
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
        
        signInButton.layer.borderWidth = 1
        signInButton.layer.cornerRadius = 20
        signInButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        signInButton.backgroundColor?.withAlphaComponent(0.20)
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
    
        signInWithGoogleButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 18)!
    }
    
    private func setupFacebookLoginButton() {
        // Créer le bouton de connexion Facebook
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        
        // Appliquer les coins arrondis correctement
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        loginButton.layer.cornerRadius = 20
        loginButton.titleLabel?.text = "Log in with Facebook"
        loginButton.layer.masksToBounds = true
        
        // Désactiver les contraintes automatiques du bouton
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Ajouter le bouton de connexion Facebook à la StackView avant le bouton "Already an account?"
        stackView.insertArrangedSubview(loginButton, at: stackView.arrangedSubviews.count - 1)
        
        
        for constraint in loginButton.constraints where constraint.firstAttribute == .height {
            constraint.constant = 50
        }
        
    }
    
    
    private func setupStackView() {
        // Créer une UIStackView
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        
        // Ajouter les boutons à la StackView
        stackView.addArrangedSubview(logInButton)
        stackView.addArrangedSubview(signInWithGoogleButton)
        setupFacebookLoginButton()
        stackView.addArrangedSubview(signInButton)
        
        // Désactiver les contraintes automatiques des boutons
        logInButton.translatesAutoresizingMaskIntoConstraints = false
        signInWithGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Définir une hauteur fixe pour les boutons
        NSLayoutConstraint.activate([
            logInButton.heightAnchor.constraint(equalToConstant: 50),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 50),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Ajouter la StackView à la vue principale
        view.addSubview(stackView)
        
        // Désactiver les contraintes automatiques de la StackView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Ajouter des contraintes pour la StackView
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        /* Resign the first responder status of the text(s) field(s)
         Je dois maintenant add un Tap Gesture et le relier à dismissKeyboard*/
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
