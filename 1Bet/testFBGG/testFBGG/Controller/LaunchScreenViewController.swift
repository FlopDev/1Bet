//
//  LaunchScreenViewController.swift
//  testFBGG
//
//  Created by Florian Peyrony on 28/05/2024.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    @IBOutlet var viewOfIndicator: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        // Do any additional setup after loading the view.
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showWelcomeViewController()
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func showWelcomeViewController() {
        // Instancier le MainViewController depuis le storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController {
            // Remplacer le rootViewController par MainViewController
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = mainViewController
                window.makeKeyAndVisible()
            }
        }
    }
}
