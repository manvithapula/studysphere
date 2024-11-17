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
    var subject:Subject?
    var flashcards: [Topics] = []
    
  
       @IBOutlet weak var subjectSegmentControl: UISegmentedControl!
       @IBOutlet weak var searchBar: UISearchBar!
       @IBOutlet weak var SubjectCollectionView: UICollectionView!

    
    override func viewDidLoad() {
           super.viewDidLoad()
        self.flashcards = topicsDb.findAll(where: ["subject":subject!.id])
           SubjectCollectionView.dataSource = self
           SubjectCollectionView.delegate = self
           searchBar.delegate = self
           SubjectCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
           filterCardsByCategory()
       }

    
       @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
           SubjectCollectionView.reloadData()
       }
       
       func filterCardsByCategory() {
           filteredCards = cards.filter { $0.title.contains(selectedCategory) }
           isSearching = true
           SubjectCollectionView.reloadData()
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
           SubjectCollectionView.reloadData()
       }
       
       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.text = ""
           filterCardsByCategory()
       }

       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           if(subjectSegmentControl.selectedSegmentIndex == 0){
               return self.flashcards.count
               
           }
           return 0
       }
       
       func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subject", for: indexPath)
           let card = flashcards[indexPath.row]
           if let cell = cell as? subjectCellCollectionViewCell {
               cell.titleLabel.text = card.title
               cell.subTitleLabel.text = card.subtitle
               cell.continueButtonTapped.tag = indexPath.item
               cell.continueButtonTapped.addTarget(self, action: #selector(detailButtonTapped(_:)), for: .touchUpInside)
              
           }
           return cell
       }
    @objc func detailButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toSRSchedule", sender: sender.tag) // Pass the tag as the sender
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSRSchedule",
           let destinationVC = segue.destination as? SRScheduleViewController,
           let selectedIndex = sender as? Int { // Extract the tag passed as sender
            let selectedCard = flashcards[selectedIndex] // Get the card using the tag
            destinationVC.topic = selectedCard // Pass the data to the destination VC
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        flashcards = topicsDb.findAll(where: ["subject":subject!.id])
        SubjectCollectionView.reloadData()
    }
   }
