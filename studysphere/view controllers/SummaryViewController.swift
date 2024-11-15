//
//  SummaryViewController.swift
//  studysphere
//
//  Created by admin64 on 07/11/24.
//

import UIKit

class SummaryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    // Enum to manage filter state
    enum FilterState {
        case ongoing, completed
    }
    
    // The collection of cards
    var cards: [Card] = [
        Card(title: "English Literature", subtitle: "1 more to go", isCompleted: false),
        Card(title: "Maths Literature", subtitle: "1 more to go", isCompleted: false),
        Card(title: "Chemistry Literature", subtitle: "1 more to go", isCompleted: false),
        Card(title: "Biology Literature", subtitle: "1 more to go", isCompleted: false),
        Card(title: "Physics", subtitle: "Completed", isCompleted: true)
    ]
    
   
    var filteredCards: [Card] {
        return cards.filter { card in
           
            let matchesSegment = filterState == .ongoing ? !card.isCompleted : card.isCompleted
            let matchesSearch = searchBar.text?.isEmpty ?? true || card.title.lowercased().contains(searchBar.text!.lowercased())
            return matchesSegment && matchesSearch
        }
    }
    var filterState: FilterState = .ongoing
    
    // Search bar for filtering
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var summaryList: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        summaryList.dataSource = self
        summaryList.delegate = self
        summaryList.setCollectionViewLayout(generateLayout(), animated: true)
       
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
      
        searchBar.delegate = self
    }
   
    @objc func segmentChanged() {
        filterState = segmentControl.selectedSegmentIndex == 0 ? .ongoing : .completed
        summaryList.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        summaryList.reloadData()
    }
    
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCards.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath)
        let card = filteredCards[indexPath.item]
        
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
