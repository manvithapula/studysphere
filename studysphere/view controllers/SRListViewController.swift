//
//  SRListViewController.swift
//  studysphere
//
//

import UIKit

class SRListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var SpacedRepetitionList: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
        enum FilterState {
            case ongoing, completed
        }
        
        
    var cards: [Topics] = []
        
       
    var filteredCards: [Topics] {
            return cards.filter { card in
               
                let matchesSegment = filterState == .ongoing ? !card.completed : card.completed
                let matchesSearch = searchBar.text?.isEmpty ?? true || card.title.lowercased().contains(searchBar.text!.lowercased())
                return matchesSegment && matchesSearch
            }
        }
        var filterState: FilterState = .ongoing
        
        // Search bar for filtering
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            SpacedRepetitionList.dataSource = self
            SpacedRepetitionList.delegate = self
            SpacedRepetitionList.setCollectionViewLayout(generateLayout(), animated: true)
           
            segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
          
            searchBar.delegate = self
            cards = topicsDb.findAll(where: ["type": TopicsType.flashcards])
        }
       
        @objc func segmentChanged() {
            filterState = segmentControl.selectedSegmentIndex == 0 ? .ongoing : .completed
            SpacedRepetitionList.reloadData()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            SpacedRepetitionList.reloadData()
        }
        
      
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredCards.count
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "spacedrepetition", for: indexPath)
            let card = filteredCards[indexPath.item]
            
            if let cell = cell as? spacedCollectionViewCell {
                cell.titleLabel.text = card.title
                cell.subtitleLabel.text = card.subtitle
                
                if card.completed {
                    cell.continueButtonTapped.setTitle("Review", for: .normal)
                } else {
                    cell.continueButtonTapped.setTitle("Continue Studying", for: .normal)
                }
                
                cell.continueButtonTapped.tag = indexPath.item // Use the tag to identify
                cell.continueButtonTapped.addTarget(self, action: #selector(detailButtonTapped(_:)), for: .touchUpInside)
            }
            
            return cell
        }
        
        func generateLayout() -> UICollectionViewLayout {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.30))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            return UICollectionViewCompositionalLayout(section: section)
        }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSRSchedule",
           let destinationVC = segue.destination as? SRScheduleViewController,
           let selectedIndex = sender as? Int { // Extract the tag passed as sender
            let selectedCard = filteredCards[selectedIndex] // Get the card using the tag
            destinationVC.topic = selectedCard // Pass the data to the destination VC
        }
    }

    @objc func detailButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toSRSchedule", sender: sender.tag) // Pass the tag as the sender
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cards = topicsDb.findAll(where: ["type": TopicsType.flashcards])
        SpacedRepetitionList.reloadData()
    }

}

   
