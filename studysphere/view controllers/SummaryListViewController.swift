//
//  SummaryViewController.swift
//  studysphere
//
//  Created by admin64 on 07/11/24.
//

import UIKit

class SummaryListViewController: UIViewController{
    @IBOutlet weak var summaryList: UICollectionView!
    
    private var gradientLayer = CAGradientLayer()
    private let searchBar = UISearchBar()
          
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
            setupUI()
            configureCollectionView()
            loadData()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            tabBarController?.isTabBarHidden = true
            loadData()
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
                summaryList.reloadData()
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
            
            // Configure cell with placeholder values for item count and time
            cell.configure(
                title: topic.title,
                itemCount: 0,
                time: "--",           // Default value, replace if needed
                subject: "Loading...", // Temporary text until `updateSubject` fetches the real subject
                index: indexPath.item
            )
            
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
