//
//  CardView.swift
//  studysphere
//
//  Created by admin64 on 01/11/24.
//


import UIKit

@IBDesignable
class CardView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 3
    }
    
}
    
  
   
  
    
   
