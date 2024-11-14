//
//  SummaryViewController.swift
//  studysphere
//
//  Created by admin64 on 07/11/24.
//

import UIKit


    class SummaryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

        // The collection of cards
        var cards: [Card] = [
            Card(title: "English Literature", subtitle: "1 more to go", isCompleted: false),
            Card(title: "Maths Literature", subtitle: "1 more to go", isCompleted: false),
            Card(title: "Chemistry Literature", subtitle: "1 more to go", isCompleted: false),
            Card(title: "Biology Literature", subtitle: "1 more to go", isCompleted: false),
            Card(title: "Biology Literature", subtitle: "1 more to go", isCompleted: true)
        ]
        
        // Boolean to manage search filter (for demonstration purposes)
        var isSearching = false
        
        // Outlets for the collection view
        @IBOutlet weak var summaryList: UICollectionView!

        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            // Set up the collection view delegate and data source
            
            summaryList.dataSource = self
            summaryList.setCollectionViewLayout(generateLayout(), animated: true)
        }

      
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return cards.count
        }
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath)
            let card = cards[indexPath.item]
            if let cell = cell as? SummaryCollectionViewCell {
                cell.titleLabel.text = card.title
                cell.subTitleLabel.text = card.subtitle
                
                if card.isCompleted {
                    cell.continueButton.setTitle("Review", for: .normal)
                } else {
                    cell.continueButton.setTitle("Continue Studying", for: .normal)
                }
                
                // Handle the button tap with a closure
                cell.buttonTapped = {
                    print("Button tapped for: \(card.title)")
                    // Add logic to update the state or navigate to another screen here
                }
            }
            
            
            return cell
        }
        func generateLayout() -> UICollectionViewLayout {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.22))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)

                return UICollectionViewCompositionalLayout(section: section)
            }
    }


