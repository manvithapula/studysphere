import UIKit

class GradientCard: UIView {
    
    // Gradient layer
    private let gradientLayer = CAGradientLayer()
    
    // Mixed gradient colors using AppTheme
    private var gradientColors: [CGColor] {
        return [
            AppTheme.primary.withAlphaComponent(0.7).cgColor,
            blendColors(AppTheme.primary, AppTheme.secondary, percentage: 0.5).withAlphaComponent(0.7).cgColor,
            AppTheme.secondary.withAlphaComponent(0.7).cgColor
        ]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupGradient() {
        // Setup gradient with subtle mixed effect
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        layer.insertSublayer(gradientLayer, at: 0)
        
        // Add rounded corners for better visual effect
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
    
    // Helper function to blend colors
    private func blendColors(_ color1: UIColor, _ color2: UIColor, percentage: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(
            red: r1 * (1 - percentage) + r2 * percentage,
            green: g1 * (1 - percentage) + g2 * percentage,
            blue: b1 * (1 - percentage) + b2 * percentage,
            alpha: a1 * (1 - percentage) + a2 * percentage
        )
    }
}
