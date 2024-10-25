//
//  UIAlert.swift
//  testFBGG
//
//  Created by Florian Peyrony on 13/05/2024.
//

import Foundation
import UIKit

class UIAlert {
    /// Presents a simple alert with a title, message, and "OK" button.
    ///
    /// - Parameters:
    ///   - viewController: The `UIViewController` from which the alert is presented.
    ///   - title: The title text displayed at the top of the alert.
    ///   - message: The message text displayed in the alert body.
    static func presentAlert(from viewController: UIViewController, title: String, message: String) {
        // Create an alert controller with the provided title and message, and set its style to alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add an "OK" action button to the alert, with a default style and no handler for custom actions
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert on the specified view controller, with an animated transition and no completion handler
        viewController.present(alert, animated: true, completion: nil)
    }
}
