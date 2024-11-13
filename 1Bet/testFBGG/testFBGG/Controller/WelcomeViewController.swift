//
//  WelcomeViewController.swift
//  testFBGG
//
//  Created by Florian Peyrony on 27/05/2024.
//

import UIKit
import Firebase
import UserNotifications

//
//  WelcomeViewController.swift
//  testFBGG
//
//  Created by Florian Peyrony on 27/05/2024.
//

import UIKit
import Firebase

/// Controller for the welcome screen of the application, managing user login and navigation.
class WelcomeViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    // MARK: - Outlets
    @IBOutlet var welcomeLabel: UILabel!   // Label displaying a welcome message with animated text.
    @IBOutlet var signInButton: UIButton!  // Button to navigate to sign-in page.
    @IBOutlet var logInButton: UIButton!   // Button to navigate to login page.
    
    // MARK: - Properties
    var activityIndicator: UIActivityIndicatorView!  // Loading indicator to show during the login check process.
    var connectionLabel: UILabel!                    // Label displaying "Connecting" message during login check.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtonsAndLabelSkin()
        setupActivityIndicator()
        
        // Check if a user is already signed in; if yes, navigate to main page after delay.
        if Auth.auth().currentUser != nil {
            showLoadingIndicator()
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                self.navigateToMainPage()
            }
        } else {
            print("No user is connected")
            connectionLabel.isHidden = true
            activityIndicator.isHidden = true
        }
    }
    
    // MARK: - UI
    
    /// Configures the appearance of the buttons and label on the welcome screen.
    func setUpButtonsAndLabelSkin() {
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = UIColor.white.cgColor
        logInButton.layer.cornerRadius = 20
        logInButton.backgroundColor = #colorLiteral(red: 0.3060854971, green: 0.3690159321, blue: 0.3294448256, alpha: 1)
        
        signInButton.layer.borderWidth = 1
        signInButton.layer.cornerRadius = 20
        signInButton.layer.borderColor = UIColor(red: 0.306, green: 0.369, blue: 0.329, alpha: 1).cgColor
        signInButton.backgroundColor = UIColor(white: 1, alpha: 1)
        
        connectionLabel = UILabel()
        connectionLabel.textColor = .white
        connectionLabel.font = UIFont(name: "ArialRoundedMTBold", size: 22)
        connectionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Adds an outline effect to the "Connecting" text.
        let attributedString = NSAttributedString(string: "Connexion en cours", attributes: [
            .strokeColor: UIColor.black,
            .strokeWidth: -2.5
        ])
        connectionLabel.attributedText = attributedString
        
        view.addSubview(connectionLabel)
        
        // Sets animated text for the welcome label.
        welcomeLabel.setTextWithTypeAnimation(text: "Welcome to OneBet\n\nThe app that publishes a safe prediction for you every day", characterDelay: 0.06)
    }
    
    /// Initializes and sets up the loading indicator for connecting state.
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = #colorLiteral(red: 0.3060854971, green: 0.3690159321, blue: 0.3294448256, alpha: 1)
        activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5) // Scales up the activity indicator size.
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        // Constraints for positioning the activity indicator and connection label.
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 25), // Moves down by 25 points.
            
            connectionLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
            connectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    /// Shows the loading indicator and hides buttons when checking user login status.
    func showLoadingIndicator() {
        signInButton.isHidden = true
        logInButton.isHidden = true
        activityIndicator.startAnimating()
        connectionLabel.isHidden = false
    }
    
    /// Hides the loading indicator and connection label after the login check is complete.
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        connectionLabel.isHidden = true
    }
    
    // MARK: - Navigation
    
    /// Prepares for the segue to the main page if the user is connected.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToMainIfConnected" {
            print("Preparing segue to MainViewController")
        }
    }

    /// Navigates to the main page of the app, presented as a full screen.
    func navigateToMainPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "MainPageViewController") as? MainPageViewController {
            mainVC.modalPresentationStyle = .fullScreen
            print("Navigating to MainPageViewController")
            present(mainVC, animated: true, completion: nil)
        } else {
            print("Error: Could not instantiate MainPageViewController")
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
            print("Notification permission granted: \(granted)")
        }
        UNUserNotificationCenter.current().delegate = self
    }
}
