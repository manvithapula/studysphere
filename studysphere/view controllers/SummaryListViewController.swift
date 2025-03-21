//
//  SummaryViewController.swift
//  studysphere
//
//  Created by admin64 on 07/11/24.
//

import UIKit

class SummaryListViewController: UIViewController {
    @IBOutlet weak var summaryList: UICollectionView!
    
    private var gradientLayer = CAGradientLayer()
    private let searchBar = UISearchBar()
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
        
        summaryList.backgroundView = containerView
    }

    @objc private func handleCreateAction() {
        performSegue(withIdentifier: "summaryempty", sender: self)
    }

    private func updateEmptyState() {
        let isEmpty = cards.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        actionLabel.isHidden = !isEmpty
        summaryList.backgroundView = isEmpty ? emptyStateLabel.superview : nil
    }
          
    // MARK: - Properties
    var cards: [Topics] = []
    var filteredCards: [Topics] {
        return cards.filter { card in
            let matchesSearch = searchBar.text?.isEmpty ?? true || card.title.lowercased().contains(searchBar.text!.lowercased())
            return matchesSearch
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGesture()
        setupUI()
        configureCollectionView()
        loadData()
        setupEmptyStateView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.isTabBarHidden = true
        loadData()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
            
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.isTabBarHidden = false
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemGray6
        title = "Summaries"
        
        // Setup Search Bar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Find a topic you created..."
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        // Setup Collection View
        summaryList.translatesAutoresizingMaskIntoConstraints = false
        summaryList.backgroundColor = .clear
        summaryList.delegate = self
        summaryList.dataSource = self
        summaryList.setCollectionViewLayout(generateLayout(), animated: false)
        summaryList.register(SummaryCollectionViewCell.self, forCellWithReuseIdentifier: "summary")
        view.addSubview(summaryList)
        
        // Setup Constraints
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            summaryList.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            summaryList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            summaryList.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureCollectionView() {
        summaryList.setCollectionViewLayout(generateLayout(), animated: false)
    }
    
    private func loadData() {
        Task {
            cards = try await topicsDb.findAll(where: ["type": TopicsType.summary.rawValue])
            await MainActor.run {
                summaryList.reloadData()
                updateEmptyState()
            }
        }
    }
    
    // MARK: - Actions
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
            
       //     self.updateTopic(topic, with: newTitle)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true)
    }
    
    private func showDeleteConfirmation(for topic: Topics) {
        let alertController = UIAlertController(title: "Delete Summary", message: "Are you sure you want to delete this summary? This action cannot be undone.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
         //   self.deleteTopic(topic)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true)
    }
    
   
    
    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
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
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSummary",
           let destinationVC = segue.destination as? SummaryViewController,
           let selectedIndex = sender as? Int {
            let selectedCard = filteredCards[selectedIndex]
            destinationVC.topic = selectedCard
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension SummaryListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        updateEmptyState()
        return filteredCards.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "summary", for: indexPath) as? SummaryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let topic = filteredCards[indexPath.item]
        
        // Configure cell with topic data
        cell.configure(
            title: topic.title,
            subject: " ",
            index: indexPath.item,
            topic: topic
        )
        
        // Set the delegate
        cell.delegate = self
        
        // Update the subject asynchronously
        cell.updateSubject(topic: topic)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toSummary", sender: indexPath.row)
    }
}

// MARK: - UISearchBarDelegate
extension SummaryListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        summaryList.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - SummaryCollectionViewCellDelegate
extension SummaryListViewController: SummaryCollectionViewCellDelegate {
    func didTapEdit(for cell: SummaryCollectionViewCell, topic: Topics) {
        showEditAlert(for: topic)
    }
    
    func didTapDelete(for cell: SummaryCollectionViewCell, topic: Topics) {
        showDeleteConfirmation(for: topic)
    }
}
