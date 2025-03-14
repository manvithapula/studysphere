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
                let matchesSegment = filterState == .ongoing ? (card.completed == nil) : card.completed != nil
                let matchesSearch = searchBar.text?.isEmpty ?? true || card.title.lowercased().contains(searchBar.text!.lowercased())
                return matchesSegment && matchesSearch
            }
        }
        
        var filterState: FilterState = .ongoing
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            fetchTopics()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            fetchTopics()
        }
        
        private func setupUI() {
            SpacedRepetitionList.dataSource = self
            SpacedRepetitionList.delegate = self
            SpacedRepetitionList.setCollectionViewLayout(generateLayout(), animated: true)
            
            segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
            segmentControl.selectedSegmentTintColor = AppTheme.primary
            segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
            segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            
            searchBar.delegate = self
        }
        
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
        private func fetchTopics() {
            Task {
                do {
                    let topics = try await topicsDb.findAll(where: ["type": TopicsType.flashcards.rawValue])
                    DispatchQueue.main.async {
                        self.cards = topics
                        self.SpacedRepetitionList.reloadData()
                    }
                } catch {
                    print("Error fetching topics: \(error)")
                }
            }
        }
        
        @objc func segmentChanged() {
            filterState = segmentControl.selectedSegmentIndex == 0 ? .ongoing : .completed
            SpacedRepetitionList.reloadData()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            SpacedRepetitionList.reloadData()
        }
        
        // MARK: - UICollectionView DataSource
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
                cell.configure(topic: card, index: indexPath.item)
            }

            
            return cell
        }
        
        // MARK: - UICollectionView Layout
        private func generateLayout() -> UICollectionViewLayout {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(120)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(120)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            
            return UICollectionViewCompositionalLayout(section: section)
        }
        
        // MARK: - Segue Handling
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            performSegue(withIdentifier: "toSRSchedule", sender: indexPath.row)
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toSRSchedule",
               let destinationVC = segue.destination as? SRScheduleViewController,
               let selectedIndex = sender as? Int {
                let selectedCard = filteredCards[selectedIndex]
                destinationVC.topic = selectedCard
            }
        }
    }

