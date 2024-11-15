//
//  ProgressArcView.swift
//  testFBGG
//
//  Created by Florian Peyrony on 27/05/2024.
//

import UIKit

class ProgressArcView: UIView {
    
    // MARK: - Properties
    
    /// Background circular shape layer.
    private let shapeLayer = CAShapeLayer()
    
    /// Progress shape layer that will be animated.
    private let progressLayer = CAShapeLayer()
    
    /// Label displaying the progress percentage or custom text.
    private let progressLabel = UILabel()
    
    /// Maximum progress value, set to 1.0 by default for full progress.
    var maxProgress: CGFloat = 1.0
    
    /// Current progress value; updates the progress arc when changed.
    var progress: CGFloat = 0 {
        didSet {
            setProgress(progress)
        }
    }
    
    // MARK: - Initializers
    
    /// Initializes the view programmatically and sets up layers and label.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupLabel()
    }
    
    /// Initializes the view from storyboard or nib, and sets up layers and label.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupLabel()
    }
    
    // MARK: - Setup Functions
    
    /// Configures the background and progress layers.
    private func setupLayers() {
        // Configure the static background arc (shapeLayer)
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        layer.addSublayer(shapeLayer)
        
        // Configure the dynamic progress arc (progressLayer)
        progressLayer.lineWidth = 10
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = #colorLiteral(red: 0.3060854971, green: 0.3690159321, blue: 0.3294448256, alpha: 1)
        progressLayer.strokeEnd = 0 // Start with no progress
        layer.addSublayer(progressLayer)
    }
    
    /// Sets up the label to display progress information in the center of the arc.
    private func setupLabel() {
        progressLabel.textAlignment = .center
        progressLabel.textColor = #colorLiteral(red: 0.3060854971, green: 0.3690159321, blue: 0.3294448256, alpha: 1)
        progressLabel.font = UIFont.systemFont(ofSize: 15)
        addSubview(progressLabel)
    }
    
    // MARK: - Layout
    
    /// Adjusts layers and label to fit within the bounds of the view.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Center and size the shape and progress layers
        shapeLayer.frame = bounds
        progressLayer.frame = bounds
        
        // Create a circular path for the arc, starting from the top and moving clockwise
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: min(bounds.width, bounds.height) / 2,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )
        
        // Set the same path for both the background and progress layers
        shapeLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
        
        // Center the label within the bounds
        progressLabel.frame = bounds
    }
    
    // MARK: - Progress Handling
    
    /// Updates the progress arc's stroke based on the current progress value.
    ///
    /// - Parameter progress: The current progress as a value between 0 and 1.
    func setProgress(_ progress: CGFloat) {
        progressLayer.strokeEnd = progress
    }
    
    /// Animates the progress arc to a specified value over a set duration.
    ///
    /// - Parameters:
    ///   - value: The target progress value, where 1 represents full progress.
    ///   - duration: The duration of the animation in seconds.
    ///   - completion: A closure to be executed once the animation completes.
    func animateProgress(to value: CGFloat, duration: TimeInterval, completion: @escaping () -> Void) {
        // Set up a basic animation for the `strokeEnd` property
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = value
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        // Add the animation to the progress layer
        progressLayer.add(animation, forKey: "progressAnim")
        
        // Update the progress layer's strokeEnd and call completion after animation ends
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.setProgress(value)
            completion()
        }
    }
    
    /// Updates the progress label with specified text.
    ///
    /// - Parameter text: The text to display on the label.
    func setLabelText(_ text: String) {
        progressLabel.text = text
    }
}
