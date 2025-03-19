//
//  CustomClass.swift
//  studysphere
//
//  Created by dark on 19/03/25.
//

import UIKit
class PasswordTextField: UITextField {
    
    // MARK: - Properties
    private let eyeButton = UIButton(type: .custom)
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    // MARK: - Setup
    private func setupTextField() {
        // Configure eye button
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        eyeButton.tintColor = .systemGray
        eyeButton.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        eyeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        rightView = eyeButton
        rightViewMode = .always
    }
    
    // MARK: - Actions
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        isSecureTextEntry = !isSecureTextEntry
        
        // Update eye icon based on visibility state
        if isSecureTextEntry {
            sender.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
}
