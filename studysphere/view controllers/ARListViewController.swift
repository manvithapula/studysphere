
import UIKit

class ARListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var ARList: UICollectionView!
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
            
            let backButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleEdit))
            self.navigationItem.rightBarButtonItem = backButton
            
            ARList.dataSource = self
            ARList.delegate = self
            ARList.setCollectionViewLayout(generateLayout(), animated: true) // Re-added!

            segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
            searchBar.delegate = self
            
            setupConstraints()
        }
    @objc private func handleEdit(){
        self.isValueEditing = !isValueEditing
        ARList.reloadData()
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
                cell.configure(topic: topic, index: indexPath.item,isEditing: isValueEditing )
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
        showEditAlert(for: topic)
    }
    
    func didTapDelete(for cell: ARCollectionViewCell, topic: Topics) {
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
            }
            
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
