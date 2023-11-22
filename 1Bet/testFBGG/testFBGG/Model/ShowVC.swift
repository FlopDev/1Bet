//
//  ShowVC.swift
//  testFBGG
//
//  Created by Florian Peyrony on 03/04/2023.
//

import Foundation
import UIKit

class ShowVC {
    weak var delegate: ModelDelegate?

    func someAction(viewController: UIViewController) {
        // Effectue une action et appelle pushViewController si nécessaire

        delegate?.pushViewController(viewController: viewController)
    }
}
