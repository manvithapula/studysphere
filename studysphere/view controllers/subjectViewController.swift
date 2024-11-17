//
//  subjectViewController.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit

class subjectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    var cards: [Card] = [
        Card(title: "English Literature", subtitle: "1 more to go", isCompleted: false),
        Card(title: "Maths Quiz", subtitle: "2 more to go", isCompleted: false),
        Card(title: "Chemistry Summaries", subtitle: "Review required", isCompleted: false),
        Card(title: "Biology Flashcard", subtitle: "Complete this", isCompleted: false),
        Card(title: "Physics Quiz", subtitle: "1 more to go", isCompleted: true)
    ]
    
    var filteredCards: [Card] = []
    var isSearching = false
    var selectedCategory: String = "Flashcards"
    
  
       @IBOutlet weak var subjectSegmentControl: UISegmentedControl!
       @IBOutlet weak var searchBar: UISearchBar!
       @IBOutlet weak var Subject: UICollectionView!

    
    override func viewDidLoad() {
           super.viewDidLoad()
           
           Subject.dataSource = self
           Subject.delegate = self
           searchBar.delegate = self
           Subject.setCollectionViewLayout(generateLayout(), animated: true)
           filterCardsByCategory()
       }

    
       @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
           switch sender.selectedSegmentIndex {
           case 0:
               selectedCategory = "Flashcards"
           case 1:
               selectedCategory = "Quizzes"
           case 2:
               selectedCategory = "Summaries"
           default:
               break
           }
           filterCardsByCategory()
       }
       
       func filterCardsByCategory() {
           filteredCards = cards.filter { $0.title.contains(selectedCategory) }
           isSearching = true
           Subject.reloadData()
       }
       
    
       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           if searchText.isEmpty {
               filterCardsByCategory()
           } else {
               filteredCards = cards.filter {
                   $0.title.lowercased().contains(searchText.lowercased()) &&
                   $0.title.contains(selectedCategory)
               }
               isSearching = true
           }
           Subject.reloadData()
       }
       
       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.text = ""
           filterCardsByCategory()
       }

       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return isSearching ? filteredCards.count : cards.count
       }
       
       func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subject", for: indexPath)
           let card = isSearching ? filteredCards[indexPath.item] : cards[indexPath.item]
           if let cell = cell as? SummaryCollectionViewCell {
               cell.titleLabel.text = card.title
               cell.subTitleLabel.text = card.subtitle
               
               if card.isCompleted {
                   cell.continueButton.setTitle("Review", for: .normal)
               } else {
                   cell.continueButton.setTitle("Continue Studying", for: .normal)
               }
               
               cell.buttonTapped = {
                   print("Button tapped for: \(card.title)")
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
