//
//  MultiProgressRingView.swift
//  studysphere
//
//  Created by dark on 02/11/24.
//

import UIKit

class MultiProgressRingView: UIView {
    private var blueRing: CAShapeLayer!
    private var greenRing: CAShapeLayer!
    private var redRing: CAShapeLayer!
    
    // Track layers
    private var blueTrack: CAShapeLayer!
    private var greenTrack: CAShapeLayer!
    private var redTrack: CAShapeLayer!
    
    private var ringWidth: CGFloat {
        return min(bounds.width, bounds.height) * 0.09
    }
    
    private func radius(for index: Int) -> CGFloat {
        let maxRadius = min(bounds.width, bounds.height) / 2 - ringWidth/2
        return maxRadius - (CGFloat(index) * (ringWidth * 1.0))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        backgroundColor = .clear
        
        // Create track layers first
        blueTrack = createTrackLayer(color: .systemBlue)
        greenTrack = createTrackLayer(color: .systemGreen)
        redTrack = createTrackLayer(color: .systemRed)
        
        // Add track layers
        layer.addSublayer(blueTrack)
        layer.addSublayer(greenTrack)
        layer.addSublayer(redTrack)
        
        // Create and add ring layers
        blueRing = createRingLayer(color: .systemBlue)
        greenRing = createRingLayer(color: .systemGreen)
        redRing = createRingLayer(color: .systemRed)
        
        layer.addSublayer(blueRing)
        layer.addSublayer(greenRing)
        layer.addSublayer(redRing)
        
    }
    
    private func createTrackLayer(color: UIColor) -> CAShapeLayer {
        let trackLayer = CAShapeLayer()
        trackLayer.fillColor = nil
        trackLayer.strokeColor = color.withAlphaComponent(0.2).cgColor 
        trackLayer.lineCap = .round
        return trackLayer
    }
    
    private func createRingLayer(color: UIColor) -> CAShapeLayer {
        let ring = CAShapeLayer()
        ring.fillColor = nil
        ring.strokeColor = color.cgColor
        ring.lineCap = .round
        return ring
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        // Update all layers
        [(blueRing, blueTrack), (greenRing, greenTrack), (redRing, redTrack)].enumerated().forEach { index, layers in
            let (ring, track) = layers
            let ringRadius = radius(for: index)
            
            // Create path
            let path = UIBezierPath(arcCenter: center,
                                  radius: ringRadius,
                                  startAngle: -.pi / 2,
                                  endAngle: 3 * .pi / 2,
                                  clockwise: true)
            
            // Update ring
            ring?.lineWidth = ringWidth
            ring?.path = path.cgPath
            
            // Update track
            track?.lineWidth = ringWidth
            track?.path = path.cgPath
        }
    }
    
    func setProgress(blue: CGFloat, green: CGFloat, red: CGFloat, animated: Bool = true) {
        let duration = animated ? 0.3 : 0
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        
        blueRing.strokeEnd = blue
        greenRing.strokeEnd = green
        redRing.strokeEnd = red
        
        CATransaction.commit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayers()
        setProgress(blue: hours.progress, green: questions.progress, red: flashcardsProgress.progress, animated: false)
    }
}
