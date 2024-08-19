//
//  WelcomeViewController.swift
//  testFBGG
//
//  Created by Florian Peyrony on 27/05/2024.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var logInButton: UIButton!
    
    // MARK: - Properties
    var activityIndicator: UIActivityIndicatorView!
    var connectionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtonsSkin()
        
        connectionLabel = UILabel()
        connectionLabel.textColor = .white
        connectionLabel.font = UIFont(name: "ArialRoundedMTBold", size: 22)
        connectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Ajouter un contour au texte
        let attributedString = NSAttributedString(string: "Connexion en cours", attributes: [
            .strokeColor: UIColor.black,
            .strokeWidth: -2.5
        ])
        connectionLabel.attributedText = attributedString
        
        
        view.addSubview(connectionLabel)
        setupActivityIndicator()
        // Vérifier si l'utilisateur est déjà connecté
        if Auth.auth().currentUser != nil {
            showLoadingIndicator()
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                self.navigateToMainPage()
            }
        } else {
            print("Aucun utilisateur connecté")
            connectionLabel.isHidden = true
            activityIndicator.isHidden = true
        }
    }
    
    func setUpButtonsSkin() {
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = UIColor.white.cgColor
        logInButton.layer.cornerRadius = 20
        logInButton.backgroundColor = #colorLiteral(red: 0.3060854971, green: 0.3690159321, blue: 0.3294448256, alpha: 1)
        
        signInButton.layer.borderWidth = 1
        signInButton.layer.cornerRadius = 20
        signInButton.layer.borderColor = UIColor(red: 0.306, green: 0.369, blue: 0.329, alpha: 1).cgColor
        signInButton.backgroundColor = UIColor(white: 1, alpha: 1)
        
        welcomeLabel.setTextWithTypeAnimation(text: "Welcome to OneBet\n\nThe app that publishes a safe prediction for you every day", characterDelay: 0.06)
    }
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = #colorLiteral(red: 0.3060854971, green: 0.3690159321, blue: 0.3294448256, alpha: 1)
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) // Augmenter la taille de l'activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 25), // Descendre de 25 points
            
            connectionLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
            connectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func showLoadingIndicator() {
        signInButton.isHidden = true
        logInButton.isHidden = true
        activityIndicator.startAnimating()
        connectionLabel.isHidden = false
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        connectionLabel.isHidden = true
    }
    
    func navigateToMainPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "MainPageViewController") as? MainPageViewController {
            mainVC.modalPresentationStyle = .fullScreen
            print("Navigation vers MainPageViewController")
            present(mainVC, animated: true, completion: nil)
        } else {
            print("Erreur : Impossible d'instancier MainPageViewController")
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToMainIfConnected" {
            print("Préparation du segue vers MainViewController")
        }
    }
}
