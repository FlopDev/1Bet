//  CustomIntensityVisualEffectView.swift
//  testFBGG
//
//  Created by Florian Peyrony on 17/04/2023.
//

import Foundation
import UIKit

class CustomIntensityVisualEffectView: UIVisualEffectView {
    var intensity: CGFloat

    init(effect: UIVisualEffect, intensity: CGFloat) {
        self.intensity = intensity
        super.init(effect: effect)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension CustomIntensityVisualEffectView {
    func updateIntensity() {
        guard self.effect != nil else { return }

        self.effect = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            let blur = UIBlurEffect(style: .regular)
            let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [weak self] in
                self?.effect = blur
            }
            animator.fractionComplete = self.intensity
            animator.stopAnimation(true)
            animator.finishAnimation(at: .current)
        }
    }
}
