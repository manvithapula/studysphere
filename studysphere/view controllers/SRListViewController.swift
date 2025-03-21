//
//  SRListViewController.swift
//  studysphere

import UIKit

class SRListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var SpacedRepetitionList: UICollectionView!
   private var isValueEditing = false
    
    private let searchBar: UISearchBar = {
           let search = UISearchBar()
           search.placeholder = "Find a topic you created..."
           search.searchBarStyle = .minimal
           search.translatesAutoresizingMaskIntoConstraints = false
           return search
       }()
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

    private func setupEmptyStateView() {
        let containerView = UIView()
        containerView.addSubview(emptyStateLabel)
        containerView.addSubview(actionLabel)
        
        // Disable autoresizing masks
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints for emptyStateLabel and actionLabel
        NSLayoutConstraint.activate([
            // emptyStateLabel constraints
            
            emptyStateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 95),
            emptyStateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // actionLabel constraints
            actionLabel.leadingAnchor.constraint(equalTo: emptyStateLabel.trailingAnchor, constant: 8), // Add spacing between labels
            actionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            actionLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor), // Ensure it doesn't overflow
        ])
        
        // Add tap gesture recognizer to actionLabel
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCreateAction))
        actionLabel.addGestureRecognizer(tapGesture)
        
        SpacedRepetitionList.backgroundView = containerView
    }

    @objc private func handleCreateAction() {
        performSegue(withIdentifier: "sremptystatecreate", sender: self)
    }

    private func updateEmptyState() {
        let isEmpty = cards.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        actionLabel.isHidden = !isEmpty
        SpacedRepetitionList.backgroundView = isEmpty ? emptyStateLabel.superview : nil
    }
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
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the tab bar when this view appears
        self.tabBarController?.tabBar.isHidden = true
        
        fetchTopics()
    }

    // Add this method if it doesn't already exist
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the tab bar again when this view disappears
        self.tabBarController?.tabBar.isHidden = false
    }
       private func setupUI() {
           view.backgroundColor = .systemGray6
           view.addSubview(searchBar)
           view.addSubview(segmentControl)
           
           let backButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleEdit))
           self.navigationItem.rightBarButtonItem = backButton
           
           SpacedRepetitionList.dataSource = self
           SpacedRepetitionList.delegate = self
           SpacedRepetitionList.setCollectionViewLayout(generateLayout(), animated: true)

           segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
           searchBar.delegate = self
           
           setupConstraints()
       }
    @objc private func handleEdit(){
        self.isValueEditing = !isValueEditing
        SpacedRepetitionList.reloadData()
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
               cell.configure(topic: card, index: indexPath.item,isEditing: isValueEditing)
               cell.delegate = self
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
        showEditAlert(for: topic)
    }
    
    func didTapDelete(for cell: SRCollectionViewCell, topic: Topics) {
        showDeleteConfirmation(for: topic)
    }
    private func showEditAlert(for topic: Topics) {
        let alertController = UIAlertController(title: "Edit Summary", message: "Update the summary title", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = topic.title
            textField.placeholder = "Enter summary title"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alertController.textFields?.first,
                  let newTitle = textField.text, !newTitle.isEmpty else { return }
            var newTopic = topic
            newTopic.title = newTitle
            Task{
                await topicsDb.update(&newTopic)
                self.isValueEditing = false
                self.fetchTopics()
                self.updateSchedule(newTopic)
            }
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true)
    }
    private func updateSchedule(_ topic:Topics){
        Task{
            let schedules = try await schedulesDb.findAll(where: ["topic":topic.id])
            for schedule in schedules {
                var updatedSchedule = schedule
                updatedSchedule.title = topic.title
                await schedulesDb.update(&updatedSchedule)
            }
        }
    }
    
    private func showDeleteConfirmation(for topic: Topics) {
        let alertController = UIAlertController(title: "Delete Summary", message: "Are you sure you want to delete this summary? This action cannot be undone.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
         //   self.deleteTopic(topic)
            Task{
                await topicsDb.delete(id: topic.id)
                let schedules = try await schedulesDb.findAll(where: ["topic":topic.id])
                for schedule in schedules {
                    await schedulesDb.delete(id: schedule.id)
                }
                self.isValueEditing = false
                self.fetchTopics()
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true)
    }
}
