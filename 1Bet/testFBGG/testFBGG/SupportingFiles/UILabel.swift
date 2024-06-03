//
//  UILabel.swift
//  testFBGG
//
//  Created by Florian Peyrony on 28/05/2024.
//

import Foundation
import UIKit

extension UILabel {
    func setTextWithTypeAnimation(text: String, characterDelay: TimeInterval) {
        self.text = ""
        let writingTask = DispatchWorkItem { [weak self] in
            for (index, character) in text.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay * Double(index)) {
                    self?.text?.append(character)
                }
            }
        }
        DispatchQueue.global().async(execute: writingTask)
    }
}
