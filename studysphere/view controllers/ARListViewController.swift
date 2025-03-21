
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
        
        ARList.backgroundView = containerView
    }

    @objc private func handleCreateAction() {
        performSegue(withIdentifier: "aremptystatecreate", sender: self)
    }

    private func updateEmptyState() {
        let isEmpty = questions.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        actionLabel.isHidden = !isEmpty
        ARList.backgroundView = isEmpty ? emptyStateLabel.superview : nil
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
            setupTapGesture()
            setupUI()
            fetchTopics()
            setupEmptyStateView()
        }
   
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
            
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
            updateEmptyState()
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

extension ARListViewController: ARCollectionViewCellDelegate {
    func didTapEdit(for cell: ARCollectionViewCell, topic: Topics) {
        // Handle edit action
        print("Edit topic: \(topic.title)")
        // Navigate to edit screen or show edit modal
    }
    
    func didTapDelete(for cell: ARCollectionViewCell, topic: Topics) {
        // Handle delete action
        print("Delete topic: \(topic.title)")
        // Show confirmation alert and delete if confirmed
    }
}
