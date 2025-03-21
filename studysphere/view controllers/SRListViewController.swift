//
//  SRListViewController.swift
//  studysphere

import UIKit

class SRListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var SpacedRepetitionList: UICollectionView!
   
    
    private let searchBar: UISearchBar = {
           let search = UISearchBar()
           search.placeholder = "Find a topic you created..."
           search.searchBarStyle = .minimal
           search.translatesAutoresizingMaskIntoConstraints = false
           return search
       }()
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No modules yet.\n Click on upload to create module."
        label.textAlignment = .center
        label.numberOfLines = 2
     //   label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
       
       private let segmentControl: UISegmentedControl = {
           let control = UISegmentedControl(items: ["Ongoing", "Completed"])
           control.selectedSegmentIndex = 0
           control.selectedSegmentTintColor = AppTheme.primary
           control.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
           control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
           control.translatesAutoresizingMaskIntoConstraints = false
           return control
       }()
       
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
           setupTapGesture()
           setupUI()
           fetchTopics()
           setupEmptyStateView()
       }
    private func setupEmptyStateView() {
        SpacedRepetitionList.backgroundView = emptyStateLabel
        }

        private func updateEmptyState() {
            let isEmpty = cards.isEmpty
            emptyStateLabel.isHidden = !isEmpty
            SpacedRepetitionList.backgroundView = isEmpty ? emptyStateLabel : nil
        }
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           fetchTopics()
       }
       
       private func setupUI() {
           view.backgroundColor = .systemGray6
           view.addSubview(searchBar)
           view.addSubview(segmentControl)
           
           SpacedRepetitionList.dataSource = self
           SpacedRepetitionList.delegate = self
           SpacedRepetitionList.setCollectionViewLayout(generateLayout(), animated: true)

           segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
           searchBar.delegate = self
           
           setupConstraints()
       }
       
       private func setupConstraints() {
           NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            // Segment Control Constraints
            segmentControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentControl.heightAnchor.constraint(equalToConstant: 32),
               
               // Adjust SpacedRepetitionList position
            SpacedRepetitionList.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16)
           ])
       }
       
       private func setupTapGesture() {
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           tapGesture.cancelsTouchesInView = false
               
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
           updateEmptyState()
           return filteredCards.count
       }
       
       func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "spacedrepetition", for: indexPath)
           let card = filteredCards[indexPath.item]
           
           if let cell = cell as? SRCollectionViewCell {
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
extension SRListViewController: SRCollectionViewCellDelegate {
    func didTapEdit(for cell: SRCollectionViewCell, topic: Topics) {
        // Handle edit action
        print("Edit topic: \(topic.title)")
        // Navigate to edit screen or show edit modal
    }
    
    func didTapDelete(for cell: SRCollectionViewCell, topic: Topics) {
        // Handle delete action
        print("Delete topic: \(topic.title)")
        // Show confirmation alert and delete if confirmed
    }
}
