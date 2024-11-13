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

    // MARK: - Outlets
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var sendAnEmailButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI() // Set up UI appearance for button and text field
    }
    
    // MARK: - UI Setup
    /// Configures the appearance of the send email button and email text field.
    private func setUpUI() {
        // Configure button
        configureButton(sendAnEmailButton, borderColor: UIColor.white, cornerRadius: 20)
        
        // Configure text field
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor(red: 0.33, green: 0.35, blue: 0.36, alpha: 1).cgColor
    }
    
    /// Helper function to apply styling to a UIButton.
    private func configureButton(_ button: UIButton, borderColor: UIColor, cornerRadius: CGFloat) {
        button.layer.borderWidth = 1
        button.layer.cornerRadius = cornerRadius
        button.layer.borderColor = borderColor.cgColor
        button.backgroundColor = button.backgroundColor?.withAlphaComponent(0.2)
    }

    // MARK: - Actions
    /// Validates the email and attempts to send a password reset email if the email exists in Firestore.
    @IBAction func didTapValidateButton(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email address.")
            return
        }
        
        // Check if the email exists in Firestore
        let db = Firestore.firestore()
        db.collection("users").whereField("mail", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                // User exists, send a password reset email
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        self.showAlert(title: "Success", message: "A password reset email has been sent to \(email).")
                    }
                }
            } else {
                // No account found with this email address
                self.showAlert(title: "Error", message: "No account found with this email address.")
            }
        }
    }
    
    /// Dismisses the keyboard when tapping outside the text field.
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
    }
    
    // MARK: - Helper Methods
    /// Shows an alert with a title and message.
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
