//
//  subjectViewController.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit

class subjectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    var isSearching = false
    var selectedCategory: String = "Flashcards"
    var subject:Subject?
    var cards: [Topics] = []
    var filteredCards: [Topics] {
        return cards.filter { card in
            let matchesSearch = searchBar.text?.isEmpty ?? true || card.title.lowercased().contains(searchBar.text!.lowercased())
            return  matchesSearch
        }
    }
    
    
    @IBOutlet weak var subjectSegmentControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var SubjectCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(subject)
        updateCards()
        SubjectCollectionView.dataSource = self
        SubjectCollectionView.delegate = self
        searchBar.delegate = self
        SubjectCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
    }
    
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        updateCards()
        SubjectCollectionView.reloadData()
    }
    private func updateCards(){
        Task{
            switch subjectSegmentControl.selectedSegmentIndex{
            case 0:
                self.cards = try await topicsDb.findAll(where: ["subject":subject!.id,"type":TopicsType.flashcards.rawValue])
            case 1:
                self.cards = try await topicsDb.findAll(where: ["subject":subject!.id,"type":TopicsType.quizzes.rawValue])
            case 2:
                self.cards = try await topicsDb.findAll(where: ["subject":subject!.id,"type":TopicsType.summary.rawValue])
            default:
                break
            }
            SubjectCollectionView.reloadData()
        }
    }
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        SubjectCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCards.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subject", for: indexPath)
        let card = filteredCards[indexPath.row]
        if let cell = cell as? subjectCellCollectionViewCell {
            cell.titleLabel.text = card.title
            cell.subTitleLabel.text = card.subtitle
            cell.continueButtonTapped.tag = indexPath.item
            cell.continueButtonTapped.addTarget(self, action: #selector(detailButtonTapped(_:)), for: .touchUpInside)
            
        }
        return cell
    }
    @objc func detailButtonTapped(_ sender: UIButton) {
        switch subjectSegmentControl.selectedSegmentIndex{
        case 0:
            performSegue(withIdentifier: "toSRSchedule", sender: sender.tag)
        case 1:
            performSegue(withIdentifier: "toARSchedule", sender: sender.tag)
        case 2:
            performSegue(withIdentifier: "toSummary", sender: sender.tag)
        default:
            break
        }
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
           let selectedIndex = sender as? Int {
            let selectedCard = filteredCards[selectedIndex]
            destinationVC.topic = selectedCard
        }
        if segue.identifier == "toARSchedule",
           let destinationVC = segue.destination as? ARScheduleViewController,
           let selectedIndex = sender as? Int {
            let selectedCard = filteredCards[selectedIndex]
            destinationVC.topic = selectedCard
        }
        if segue.identifier == "toSummary",
           let destinationVC = segue.destination as? SummariserViewController,
           let selectedIndex = sender as? Int {
            let selectedCard = filteredCards[selectedIndex]
            destinationVC.topic = selectedCard
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SubjectCollectionView.reloadData()
    }
}
