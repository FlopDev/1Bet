import UIKit

class ProgressArcView: UIView {

    private let shapeLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let progressLabel = UILabel()
    
    var maxProgress: CGFloat = 1.0 // Progrès maximal absolu

    var progress: CGFloat = 0 {
        didSet {
            setProgress(progress)
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
        progressLabel.font = UIFont.systemFont(ofSize: 15)
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

    func animateProgress(to value: CGFloat, duration: TimeInterval, completion: @escaping () -> Void) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = value
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "progressAnim")

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.setProgress(value)
            completion()
        }
    }

    func setLabelText(_ text: String) {
        progressLabel.text = text
    }
}
