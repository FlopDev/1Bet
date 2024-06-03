//
//  WelcomeViewController.swift
//  testFBGG
//
//  Created by Florian Peyrony on 27/05/2024.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: - Outlet
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var logInButton: UIButton!
    
    // MARK: - Properties

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpButtonsSkin()
        // Do any additional setup after loading the view.
    }
    
    func setUpButtonsSkin() {
        logInButton.layer.borderWidth = 1
        logInButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        logInButton.layer.cornerRadius = 20
        logInButton.backgroundColor?.withAlphaComponent(0.20)
        signInButton.layer.borderWidth = 1
        signInButton.layer.cornerRadius = 20
        signInButton.layer.borderColor = #colorLiteral(red: 0.3060854971, green: 0.3690159321, blue: 0.3294448256, alpha: 1)
        signInButton.backgroundColor?.withAlphaComponent(0.20)
        welcomeLabel.setTextWithTypeAnimation(text: "Welcome to OneBet\n\nThe app that publishes a safe prediction for you every day", characterDelay: 0.06)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
