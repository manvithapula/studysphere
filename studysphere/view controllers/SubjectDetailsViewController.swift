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
        var type = TopicsType.flashcards
        switch subjectSegmentControl.selectedSegmentIndex {
        case 0:
            type = TopicsType.flashcards
        case 1:
            type = TopicsType.quizzes
        case 2:
            type = TopicsType.summary
        default:
            break
        }
        return cards.filter { card in
            let matchesSearch = (searchBar.text?.isEmpty ?? true || card.title.lowercased().contains(searchBar.text!.lowercased())) && card.type == type
            return  matchesSearch
        }
    }
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No modules yet."
        label.textAlignment = .center
        label.numberOfLines = 2
      //  label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    
    private let actionLabel: UILabel = {
        let label = UILabel()
        label.text = "Create new"
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.isUserInteractionEnabled = true
        return label
    }()

    private var emptyStateContainerView: UIView!

    private func setupEmptyStateView() {
        emptyStateContainerView = UIView()
        emptyStateContainerView.addSubview(emptyStateLabel)
        emptyStateContainerView.addSubview(actionLabel)
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Center the emptyStateLabel horizontally with some offset to the left
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateContainerView.centerXAnchor, constant: -30),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyStateContainerView.centerYAnchor),
            
            // Position actionLabel to the right of emptyStateLabel
            actionLabel.leadingAnchor.constraint(equalTo: emptyStateLabel.trailingAnchor, constant: 8),
            actionLabel.centerYAnchor.constraint(equalTo: emptyStateContainerView.centerYAnchor),
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCreateAction))
        actionLabel.addGestureRecognizer(tapGesture)
    }

    private func updateEmptyState() {
        let isEmpty = filteredCards.isEmpty
        SubjectCollectionView.backgroundView = isEmpty ? emptyStateContainerView : nil
    }
    
    @objc private func handleCreateAction() {
        performSegue(withIdentifier: "subjectdetailsempty", sender: self)
    }
    
    
    @IBOutlet weak var subjectSegmentControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var SubjectCollectionView: UICollectionView!
    
  
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupCollectionView()
            loadCards()
            setupEmptyStateView()
        }
   

    
        
    // In SubjectDetailsViewController
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the tab bar when this view appears
        self.tabBarController?.tabBar.isHidden = true
        
        // Your existing code
        subjectSegmentControl.selectedSegmentTintColor = AppTheme.primary
        subjectSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
        subjectSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        SubjectCollectionView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the tab bar again when this view disappears
        self.tabBarController?.tabBar.isHidden = false
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
            subjectSegmentControl.setTitleTextAttributes([.foregroundColor: AppTheme.primary], for: .selected)
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
//
            SubjectCollectionView.reloadData()
        }
   
        // MARK: - Data
    private func loadCards(){
        Task{
            cards = try await topicsDb.findAll(where: ["subject": subject!.id])
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
                performSegue(withIdentifier: "toSRSchedule", sender: indexPath.row)
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
                if let destinationVC = segue.destination as? ModuleScheduleViewController {
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

