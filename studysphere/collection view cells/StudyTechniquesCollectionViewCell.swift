//
//  StudyTechniquesCollectionViewCell.swift
//  homescreen
//
//  Created by admin64 on 14/12/24.
//

import UIKit

class StudyTechniquesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var completionStatus: UILabel!
    @IBOutlet weak var completed: UILabel!
    @IBOutlet weak var techniqueName: UITextView!
    @IBOutlet weak var button: UIButton!
    
    func updateCompletionStatus(topic:TopicsType) {
        Task {
            do {
                let cards = try await topicsDb.findAll(where: ["type": topic.rawValue])
                let filteredCards = cards.filter { card in
                    card.completed != nil
                }

                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.completionStatus.text = "\(filteredCards.count)/\(cards.count)"
                }
            } catch {
                print("Error fetching or processing topics: \(error)")
                // Handle the error appropriately, e.g., display an error message
            }
        }
    }
}
