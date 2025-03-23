//
//  DesignManager.swift
//  studysphere
//
//  Created by dark on 23/03/25.
//

import UIKit

struct DesignManager {
    static let shadowOffset = CGSize(width: 0, height: 3)

    static func cardView() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = shadowOffset
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }

    static func subjectTag() -> UILabel {
        let label = PaddedLabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = AppTheme.primary
        label.backgroundColor = AppTheme.secondary.withAlphaComponent(0.1)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " "
        return label
    }
    
    static func iconContainer() -> UIView{
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.backgroundColor = AppTheme.primary
        view.clipsToBounds = true
        return view
    }
    
    static func cellTitleLabel() -> UILabel{
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .darkText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }
    
    static func editButton(selector:Selector) -> UIButton{
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
    
    static func deleteButton(selector:Selector) -> UIButton{
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: selector, for: .touchUpInside)
        return button
    }
}

class PaddedLabel: UILabel {
    var padding = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom)
    }
    func setPadding(horizontal: CGFloat, vertical: CGFloat) {
        let padding = UIEdgeInsets(
            top: vertical, left: horizontal, bottom: vertical, right: horizontal
        )
        if let textString = text {
            let attributedString = NSAttributedString(
                string: textString,
                attributes: [
                    NSAttributedString.Key.font: font ?? .systemFont(ofSize: 14)
                ]
            )
            let rect = attributedString.boundingRect(
                with: CGSize(
                    width: frame.size.width, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                context: nil
            )
            frame.size.height = rect.height + padding.top + padding.bottom
            frame.size.width = rect.width + padding.left + padding.right
        }
    }
    override var text: String? {
        didSet {
            if let unwrappedText = text, unwrappedText.count > 15 {
                // Split by spaces, capitalize each word, then rejoin
                let words = unwrappedText.components(separatedBy: " ")
                let capitalizedWords = words.map { word in
                    if let firstChar = word.first {
                        return String(firstChar).uppercased()
                    }
                    return word
                }
                text = capitalizedWords.joined(separator: "")
            }
        }
    }
}
