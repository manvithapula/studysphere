//
//  ARListViewController.swift
//  studysphere
//
//  Created by Dev on 18/11/24.
//

import UIKit

class ARListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var ARList: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!

        enum FilterState {
            case ongoing, completed
        }
        
        var questions: [Topics] = []
        
        var filteredQuestions: [Topics] {
            return questions.filter { card in
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
            ARList.dataSource = self
            ARList.delegate = self
            ARList.setCollectionViewLayout(generateLayout(), animated: true)
            
            segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
            segmentControl.selectedSegmentTintColor = AppTheme.primary
            segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
            segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            
            searchBar.delegate = self
        }
        
        private func fetchTopics() {
            Task {
                do {
                    let topics = try await topicsDb.findAll(where: ["type": TopicsType.quizzes.rawValue])
                    DispatchQueue.main.async {
                        self.questions = topics
                        self.ARList.reloadData()
                    }
                } catch {
                    print("Error fetching topics: \(error)")
                }
            }
        }
        
        @objc func segmentChanged() {
            filterState = segmentControl.selectedSegmentIndex == 0 ? .ongoing : .completed
            ARList.reloadData()
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            ARList.reloadData()
        }
        
        // MARK: - UICollectionView DataSource
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredQuestions.count
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AR", for: indexPath)
        let topic = filteredQuestions[indexPath.item]
        
        if let cell = cell as? ARCollectionViewCell {
            cell.configure(topic: topic, index: indexPath.item)
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
            performSegue(withIdentifier: "toARschedule", sender: indexPath.row)
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toARschedule",
               let destinationVC = segue.destination as? ARScheduleViewController,
               let selectedIndex = sender as? Int {
                let selectedCard = filteredQuestions[selectedIndex]
                destinationVC.topic = selectedCard
            }
        }
    }
