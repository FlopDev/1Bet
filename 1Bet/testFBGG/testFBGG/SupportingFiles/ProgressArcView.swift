//
//  ProgressArcView.swift
//  testFBGG
//
//  Created by Florian Peyrony on 04/06/2024.
//

import Foundation
import UIKit

class ProgressArcView: UIView {
    
    private let shapeLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let progressLabel = UILabel()
       
       var progress: CGFloat = 0 {
           didSet {
               setProgress(progress)
               progressLabel.text = "\(Int(progress * 100))%"
           }
       }
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           setupLayers()
           setupLabel()
       }
       
       required init?(coder: NSCoder) {
           super.init(coder: coder)
           setupLayers()
           setupLabel()
       }
       
       private func setupLayers() {
           shapeLayer.lineWidth = 10
           shapeLayer.fillColor = UIColor.clear.cgColor
           shapeLayer.strokeColor = UIColor.lightGray.cgColor
           layer.addSublayer(shapeLayer)
           
           progressLayer.lineWidth = 10
           progressLayer.fillColor = UIColor.clear.cgColor
           progressLayer.strokeColor = #colorLiteral(red: 0.3060854971, green: 0.3690159321, blue: 0.3294448256, alpha: 1)
           progressLayer.strokeEnd = 0
           layer.addSublayer(progressLayer)
       }
       
       private func setupLabel() {
           progressLabel.textAlignment = .center
           progressLabel.textColor = #colorLiteral(red: 0.3060854971, green: 0.3690159321, blue: 0.3294448256, alpha: 1)
           progressLabel.font = UIFont.systemFont(ofSize: 20)
           addSubview(progressLabel)
       }
       
       override func layoutSubviews() {
           super.layoutSubviews()
           shapeLayer.frame = bounds
           progressLayer.frame = bounds
           let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: min(bounds.width, bounds.height) / 2, startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true)
           shapeLayer.path = circularPath.cgPath
           progressLayer.path = circularPath.cgPath
           progressLabel.frame = bounds
       }
       
       private func setProgress(_ progress: CGFloat) {
           progressLayer.strokeEnd = progress
       }
       
       func animateProgress(to value: CGFloat, duration: TimeInterval) {
           let animation = CABasicAnimation(keyPath: "strokeEnd")
           animation.toValue = value
           animation.duration = duration
           animation.fillMode = .forwards
           animation.isRemovedOnCompletion = false
           progressLayer.add(animation, forKey: "progressAnim")
           
           // Mise à jour du label pendant l'animation
           let displayLink = CADisplayLink(target: self, selector: #selector(updateLabel))
           displayLink.add(to: .main, forMode: .default)
           DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
               displayLink.invalidate()
           }
       }
       
       @objc private func updateLabel() {
           let progress = progressLayer.presentation()?.strokeEnd ?? 0
           progressLabel.text = "\(Int(progress * 100))%"
       }
   }    
