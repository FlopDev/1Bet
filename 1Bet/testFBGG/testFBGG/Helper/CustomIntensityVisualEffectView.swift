//  CustomIntensityVisualEffectView.swift
//  testFBGG
//
//  Created by Florian Peyrony on 17/04/2023.
//

import Foundation
import UIKit

class CustomIntensityVisualEffectView: UIVisualEffectView {
    /// The intensity level of the visual effect.
    var intensity: CGFloat

    /// Initializes the custom visual effect view with a specified effect and intensity.
    ///
    /// - Parameters:
    ///   - effect: The `UIVisualEffect` to apply, typically a `UIBlurEffect`.
    ///   - intensity: The intensity of the effect, with values between 0 (no effect) and 1 (full effect).
    init(effect: UIVisualEffect, intensity: CGFloat) {
        self.intensity = intensity
        super.init(effect: effect)
    }

    /// Required initializer for decoding, which isn't supported in this custom view.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomIntensityVisualEffectView {
    /// Updates the intensity of the visual effect by adjusting its animation fraction.
    /// This method clears and reassigns the effect to enable adjustable intensity.
    func updateIntensity() {
        // Ensure there is an existing effect before proceeding
        guard self.effect != nil else { return }

        // Temporarily remove the effect to allow re-application with adjusted intensity
        self.effect = nil
        
        // Reapply the effect with a slight delay to trigger the visual update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            // Define a standard blur effect (e.g., .regular) for re-application
            let blur = UIBlurEffect(style: .regular)
            
            // Use a UIViewPropertyAnimator to control the intensity of the blur effect
            let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
                self?.effect = blur
            }
            
            // Set the completion fraction based on the desired intensity level
            animator.fractionComplete = self.intensity
            
            // Stop the animation and finalize it at the current intensity level
            animator.stopAnimation(true)
            animator.finishAnimation(at: .current)
        }
    }
}
