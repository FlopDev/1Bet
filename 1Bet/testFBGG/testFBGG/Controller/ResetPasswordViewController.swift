//
//  ResetPasswordViewController.swift
//  testFBGG
//
//  Created by Florian Peyrony on 13/10/2024.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ResetPasswordViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var sendAnEmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtonsSkin()
    }
    
    func setUpButtonsSkin() {
        sendAnEmailButton.layer.borderWidth = 1
        sendAnEmailButton.layer.cornerRadius = 20
        sendAnEmailButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        sendAnEmailButton.backgroundColor?.withAlphaComponent(0.20)
        
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = #colorLiteral(red: 0.3289624751, green: 0.3536478281, blue: 0.357570827, alpha: 1)
    }

    @IBAction func didTapValidateButton(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            UIAlert.presentAlert(from: self, title: "Error", message: "Please enter your email address.")
            return
        }
        
        // Vérifier si l'email existe dans la base de données Firestore
        let db = Firestore.firestore()
        db.collection("users").whereField("mail", isEqualTo: email).getDocuments { (snapshot, error) in
            if let error = error {
                UIAlert.presentAlert(from: self, title: "Error", message: error.localizedDescription)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                // L'utilisateur existe, envoyer l'e-mail de réinitialisation de mot de passe
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        UIAlert.presentAlert(from: self, title: "Error", message: error.localizedDescription)
                    } else {
                        UIAlert.presentAlert(from: self, title: "Success", message: "A password reset email has been sent to \(email).")
                    }
                }
            } else {
                // L'utilisateur n'existe pas avec cet e-mail
                UIAlert.presentAlert(from: self, title: "Error", message: "No account found with this email address.")
            }
        }
    }
    
    @IBAction func dismissKeyboad(_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
    }
}
