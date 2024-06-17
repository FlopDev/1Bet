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

class SignInOptionsViewController: UIViewController, LoginButtonDelegate {
    
    // MARK: - Properties
    var userInfo: User?
    var service = FirebaseService()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpButtonsSkin()
        // Appeler la fonction pour configurer la StackView
        setupStackView()
    }
    
    // MARK: - Functions
    
    @objc func successLogin() {
        print("Inscription de \(usernameTextField.text ?? "no name")")
        self.performSegue(withIdentifier: "segueToMain", sender: userInfo)
    }
    
    @objc func failLogin() {
        UIAlert.presentAlert(from: self, title: "ERROR", message: "Connection rejected")
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
                    print("Cette adresse email est déjà utilisée")
                    UIAlert.presentAlert(from: self, title: "ERROR", message: "This email address is already in use")
                } else {
                    service.signInEmailButton(email: self.emailTextField.text!, username: self.usernameTextField.text!, password: self.password.text!)
                    self.performSegue(withIdentifier: "segueToMain", sender: userInfo)
                }
            }
        } else {
            print("Error : Missing Username, password or adress")
            UIAlert.presentAlert(from: self, title: "ERROR", message: "Add a valid e-mail or password")
        }
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        password.resignFirstResponder()
        
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
    }
    
    private func setupFacebookLoginButton() {
        // Créer le bouton de connexion Facebook
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        
        // Appliquer les coins arrondis correctement
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        loginButton.layer.cornerRadius = 20
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
        stackView.addArrangedSubview(createAccountButton)
        stackView.addArrangedSubview(signInWithGoogleButton)
        setupFacebookLoginButton()
        stackView.addArrangedSubview(alreadyAnAccountButton)
        
        // Désactiver les contraintes automatiques des boutons
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        signInWithGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        alreadyAnAccountButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Définir une hauteur fixe pour les boutons
        NSLayoutConstraint.activate([
            createAccountButton.heightAnchor.constraint(equalToConstant: 50),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 50),
            alreadyAnAccountButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Ajouter la StackView à la vue principale
        view.addSubview(stackView)
        
        // Désactiver les contraintes automatiques de la StackView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Ajouter des contraintes pour la StackView
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 20),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToMain" {
            let successVC = segue.destination as? MainPageViewController
            let userInfo = sender as? User
            successVC?.userInfo = userInfo
        }
    }
}


extension SignInOptionsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
