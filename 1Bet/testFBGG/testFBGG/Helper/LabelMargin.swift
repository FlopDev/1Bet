//
//  LabelMargin.swift
//  testFBGG
//
//  Created by Florian Peyrony on 24/04/2023.
//

import Foundation
import UIKit

extension UILabel {
    /// <#Description#>
    /// - Parameter margin: <#margin description#>
    func setMargins(_ margin: CGFloat = 10) {
        if let textString = self.text {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = margin
            paragraphStyle.headIndent = margin
            paragraphStyle.tailIndent = -margin
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
}
