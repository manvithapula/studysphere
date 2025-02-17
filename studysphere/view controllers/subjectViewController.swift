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
    
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            updateCards()
            SubjectCollectionView.dataSource = self
            SubjectCollectionView.delegate = self
            searchBar.delegate = self
            SubjectCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            subjectSegmentControl.selectedSegmentTintColor = AppTheme.primary
            subjectSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
            subjectSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            SubjectCollectionView.reloadData()
        }
        
        // MARK: - UI Setup
        private func setupUI() {
        
            // Configure search bar
            searchBar.placeholder = "Search topics"
            searchBar.searchBarStyle = .minimal
            searchBar.backgroundImage = UIImage()
            
            // Configure segmented control
            subjectSegmentControl.backgroundColor = .systemBackground
            subjectSegmentControl.selectedSegmentTintColor = .systemBlue.withAlphaComponent(0.1)
            subjectSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .selected)
            subjectSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel], for: .normal)
            
            // Configure collection view
            SubjectCollectionView.backgroundColor = .systemBackground
            SubjectCollectionView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
            
            // Configure view
            view.backgroundColor = .systemBackground
        }
        
        
        // MARK: - Actions
        @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
            updateCards()
            SubjectCollectionView.reloadData()
        }
        
        // MARK: - Data
        private func updateCards() {
            Task {
                switch subjectSegmentControl.selectedSegmentIndex {
                case 0:
                    self.cards = try await topicsDb.findAll(where: ["subject": subject!.id, "type": TopicsType.flashcards.rawValue])
                case 1:
                    self.cards = try await topicsDb.findAll(where: ["subject": subject!.id, "type": TopicsType.quizzes.rawValue])
                case 2:
                    self.cards = try await topicsDb.findAll(where: ["subject": subject!.id, "type": TopicsType.summary.rawValue])
                default:
                    break
                }
                SubjectCollectionView.reloadData()
            }
        }
        
        // MARK: - Search Bar Delegate
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            SubjectCollectionView.reloadData()
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            SubjectCollectionView.reloadData()
        }
        
        // MARK: - Collection View Data Source
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredCards.count
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subject", for: indexPath)
            let card = filteredCards[indexPath.row]
            
            if let cell = cell as? ARCollectionViewCell {
                cell.titleLabel.text = card.title
                cell.subtitleLabel.text = card.subtitle
                
                
                // Configure labels
                cell.titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
                cell.titleLabel.textColor = .label
                cell.subtitleLabel.font = .systemFont(ofSize: 14)
                cell.subtitleLabel.textColor = .secondaryLabel
            }
            
            return cell
        }
        
        // MARK: - Collection View Delegate
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            switch subjectSegmentControl.selectedSegmentIndex {
            case 0:
                performSegue(withIdentifier: "toSRSchedule", sender: indexPath.row)
            case 1:
                performSegue(withIdentifier: "toARSchedule", sender: indexPath.row)
            case 2:
                performSegue(withIdentifier: "toSummary", sender: indexPath.row)
            default:
                break
            }
        }
        
        // MARK: - Layout
        private func generateLayout() -> UICollectionViewLayout {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(88)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(88)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            
            return UICollectionViewCompositionalLayout(section: section)
        }
        
        // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard let selectedIndex = sender as? Int else { return }
            let selectedCard = filteredCards[selectedIndex]
            
            switch segue.identifier {
            case "toSRSchedule":
                if let destinationVC = segue.destination as? SRScheduleViewController {
                    destinationVC.topic = selectedCard
                }
            case "toARSchedule":
                if let destinationVC = segue.destination as? ARScheduleViewController {
                    destinationVC.topic = selectedCard
                }
            case "toSummary":
                if let destinationVC = segue.destination as? SummariserViewController {
                    destinationVC.topic = selectedCard
                }
            default:
                break
            }
        }
    }
