//
//  UIAlert.swift
//  testFBGG
//
//  Created by Florian Peyrony on 13/05/2024.
//

import Foundation
import UIKit

class UIAlert {
    static func presentAlert(from viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        // Add a "OK" button to the alert
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // Present the alert to the specific controller
        viewController.present(alert, animated: true, completion: nil)
    }
}
