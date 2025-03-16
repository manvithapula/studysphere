//
//  subjectViewController.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//

import UIKit

class SubjectDetailsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
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
    
    private let emptyStateLabel: UILabel = {
            let label = UILabel()
            label.text = "Click the add symbol to create a new subject."
            label.textAlignment = .center
            label.textColor = .systemGray
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.isHidden = true
            return label
        }()
 
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupCollectionView()
            updateCards()
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
            
            // Configure view background
            view.backgroundColor = .systemGray6
        }
        
        private func setupCollectionView() {
            SubjectCollectionView.dataSource = self
            SubjectCollectionView.delegate = self
            searchBar.delegate = self
            SubjectCollectionView.setCollectionViewLayout(generateLayout(), animated: true)
            
            // Register SubjectCellCollectionViewCell
            SubjectCollectionView.register(SubjectCellCollectionViewCell.self, forCellWithReuseIdentifier: "SubjectCell")
        }
        
        // MARK: - Actions
        @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
            updateCards()
        }
    private func setupEmptyStateView() {
          view.addSubview(emptyStateLabel)
          emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
          NSLayoutConstraint.activate([
              emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
          ])
      }
      
      private func updateEmptyState() {
          emptyStateLabel.isHidden = !filteredCards.isEmpty
          SubjectCollectionView.isHidden = filteredCards.isEmpty
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
                print("Cards loaded: \(cards.count)")
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
            updateEmptyState()
            return filteredCards.count
            
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubjectCell", for: indexPath) as? SubjectCellCollectionViewCell else {
            fatalError("Could not dequeue SubjectCellCollectionViewCell")
        }
        
        let card = filteredCards[indexPath.row]
        cell.configure(title: card.title, subtitle: card.subtitle, index: indexPath.row)
        
       
        
        // Set button action
        cell.buttonTapped = { [weak self] in
            self?.handleContinueButtonTap(indexPath: indexPath)
        }
        
        return cell
    }

            
           
        
        // MARK: - Collection View Delegate
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            handleContinueButtonTap(indexPath: indexPath)
        }
        
        private func handleContinueButtonTap(indexPath: IndexPath) {
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
                if let destinationVC = segue.destination as? SummaryViewController {
                    destinationVC.topic = selectedCard
                }
            default:
                break
            }
        }
    }

