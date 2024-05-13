//
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

