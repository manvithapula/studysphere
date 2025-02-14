//
//  spacedCollectionViewCell.swift
//  studysphere
//
//  Created by dark on 29/10/24.
//

import UIKit

class spacedCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var continueButtonTapped: UIButton!
    
    @IBOutlet weak var subjectButtonSR: UIButton!
    
    
    var buttonTapped: (() -> Void)?
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        buttonTapped?()
    }
    
    @IBOutlet weak var viewSr: RoundNShadow!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewSr.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate([
                            viewSr.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
                            viewSr.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3),
                            viewSr.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
                            viewSr.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
                        ])
                }
    
    func updateSubject(topic:Topics){
        Task{
            let allSubjects = try await subjectDb.findAll(where: ["id": topic.subject])
            if let subject = allSubjects.first{
                subjectButtonSR.setTitle(subject.name, for: .normal)
            }
        }
    }
        
    }
    

