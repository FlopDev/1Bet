//
//  LabelMargin.swift
//  testFBGG
//
//  Created by Florian Peyrony on 24/04/2023.
//

import Foundation
import UIKit

extension UILabel {
    /// Sets custom margins for the text within the UILabel.
    /// This method adjusts the paragraph style to apply a specified left and right margin to the label's text.
    /// - Parameter margin: The amount of space (in points) to apply as a margin on the left and right of the text. Default value is 10.
    func setMargins(_ margin: CGFloat = 10) {
        // Check if the label's text is not nil
        if let textString = self.text {
            // Initialize a paragraph style object to set custom margins
            let paragraphStyle = NSMutableParagraphStyle()
            
            // Set the margin for the first line and the rest of the lines
            paragraphStyle.firstLineHeadIndent = margin
            paragraphStyle.headIndent = margin
            paragraphStyle.tailIndent = -margin
            
            // Create an attributed string with the current text
            let attributedString = NSMutableAttributedString(string: textString)
            
            // Apply the paragraph style to the entire text range
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            
            // Assign the formatted attributed text back to the UILabel
            attributedText = attributedString
        }
    }
}
