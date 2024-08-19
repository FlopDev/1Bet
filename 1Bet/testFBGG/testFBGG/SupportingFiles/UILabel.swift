import Foundation
import UIKit

extension UILabel {
    func setTextWithTypeAnimation(text: String, characterDelay: TimeInterval) {
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .strokeColor: UIColor.black,
            .strokeWidth: -2.5,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "ArialRoundedMTBold", size: 28)!
        ])
        
        self.attributedText = NSAttributedString(string: "") // Start with an empty string
        
        let writingTask = DispatchWorkItem { [weak self] in
            for (index, _) in text.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay * Double(index)) {
                    let substring = NSMutableAttributedString(attributedString: attributedString.attributedSubstring(from: NSRange(location: 0, length: index + 1)))
                    self?.attributedText = substring
                }
            }
        }
        
        DispatchQueue.global().async(execute: writingTask)
    }
}
