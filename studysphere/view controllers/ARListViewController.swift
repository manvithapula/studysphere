
import UIKit

class ARListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var ARList: UICollectionView!

        
        private let searchBar: UISearchBar = {
            let search = UISearchBar()
            search.placeholder = "Find a topic you created..."
            search.searchBarStyle = .minimal
            search.translatesAutoresizingMaskIntoConstraints = false
            return search
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
            view.backgroundColor = .systemGray6
            view.addSubview(searchBar)
            view.addSubview(segmentControl)
            
            ARList.dataSource = self
            ARList.delegate = self
            ARList.setCollectionViewLayout(generateLayout(), animated: true) // Re-added!

            segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
            searchBar.delegate = self
            
            setupConstraints()
        }
        
        private func setupConstraints() {
            NSLayoutConstraint.activate([
                // SearchBar Constraints
                searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
                searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                
                // Segment Control Constraints
                segmentControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
                segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                segmentControl.heightAnchor.constraint(equalToConstant: 32),
                
                // Adjust ARList position
                ARList.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16)
            ])
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

