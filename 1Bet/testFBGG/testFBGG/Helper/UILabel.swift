//
//  UILabel.swift
//  testFBGG
//
//  Created by Florian Peyrony on 27/05/2024.
//

import Foundation
import UIKit

extension UILabel {
    
    /// Sets the label's text with a typing animation, revealing each character with a delay.
    ///
    /// - Parameters:
    ///   - text: The full text to display in the label.
    ///   - characterDelay: The time interval (in seconds) between each character appearing.
    func setTextWithTypeAnimation(text: String, characterDelay: TimeInterval) {
        // Define an attributed string with stroke and font attributes for the typing effect
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .strokeColor: UIColor.black,                           // Outline color
            .strokeWidth: -2.5,                                    // Outline width (negative for filled effect)
            .foregroundColor: UIColor.white,                       // Text color
            .font: UIFont(name: "ArialRoundedMTBold", size: 28)!   // Font and size
        ])
        
        // Start with an empty string in the label before the animation begins
        self.attributedText = NSAttributedString(string: "")
        
        // Task that will animate the text appearance with a delay per character
        let writingTask = DispatchWorkItem { [weak self] in
            // Loop through each character's index in the text
            for (index, _) in text.enumerated() {
                // Dispatch each character update to the main queue with a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay * Double(index)) {
                    // Create a substring that includes characters up to the current index
                    let substring = NSMutableAttributedString(
                        attributedString: attributedString.attributedSubstring(from: NSRange(location: 0, length: index + 1))
                    )
                    // Update the label's attributed text to show the current substring
                    self?.attributedText = substring
                }
            }
        }
        
        // Execute the typing animation task on a global queue to avoid blocking the main thread
        DispatchQueue.global().async(execute: writingTask)
    }
}
