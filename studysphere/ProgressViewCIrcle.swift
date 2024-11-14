//
//  ProgressViewCIrcle.swift
//  Studysphere2
//
//  Created by Dev on 06/11/24.
//

import UIKit

class ProgressViewCIrcle: UIView {


    

        private var ringLayer: CAShapeLayer!
        private var trackLayer: CAShapeLayer!
        
        private var ringWidth: CGFloat {
            return min(bounds.width, bounds.height) * 0.09
        }
        private var radius: CGFloat{
            let maxRadius = min(bounds.width, bounds.height) / 2 - ringWidth/2
            return maxRadius
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }
        
        private func createRingLayer(color: UIColor) -> CAShapeLayer {
            let ring = CAShapeLayer()
            ring.fillColor = nil
            ring.strokeColor = color.cgColor
            ring.lineCap = .round
            return ring
        }
        private func createTrackLayer(color: UIColor) -> CAShapeLayer {
            let trackLayer = CAShapeLayer()
            trackLayer.fillColor = nil
            trackLayer.strokeColor = color.withAlphaComponent(0.2).cgColor
            trackLayer.lineCap = .round
            return trackLayer
        }
        
        func setProgress(value: CGFloat, animated: Bool = true) {
            let duration = animated ? 0.3 : 0
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(duration)
            
            ringLayer.strokeEnd = value
            
            CATransaction.commit()
        }
        
        private func setup() {
            trackLayer = createRingLayer(color: .green)
            layer.addSublayer(trackLayer)
            ringLayer = createRingLayer(color: .red)
            layer.addSublayer(ringLayer)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let ringRadius = radius
            
            // Create path
            let path = UIBezierPath(arcCenter: center,
                                  radius: ringRadius,
                                  startAngle: -.pi / 2,
                                  endAngle: 3 * .pi / 2,
                                  clockwise: true)
            
            // Update ring
            ringLayer?.lineWidth = ringWidth
            ringLayer?.path = path.cgPath
            
            // Update track
            trackLayer?.lineWidth = ringWidth
            trackLayer?.path = path.cgPath
        }
        

}
