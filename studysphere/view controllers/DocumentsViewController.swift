import UIKit
import FirebaseFirestore

class DocumentsViewController: UIViewController {
    // MARK: - Properties
    private var documents: [FileMetadata] = [] // Original list
    private var filteredDocuments: [FileMetadata] = [] // For search
    private var subjects: [Subject] = [] // Subject list
    private var selectedSubject: Subject? // Track selected subject
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search documents..."
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private lazy var subjectsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.showsHorizontalScrollIndicator = false
        cv.register(DocumentsSubjectCell.self, forCellWithReuseIdentifier: DocumentsSubjectCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private lazy var documentsCollectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.register(DocumentCell.self, forCellWithReuseIdentifier: DocumentCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No documents yet.\nUpload study materials from the home screen!"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadTestDocuments()
        loadSubjects()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemGray6
        searchBar.delegate = self
        
        view.addSubview(searchBar)
        view.addSubview(subjectsCollectionView)
        view.addSubview(documentsCollectionView)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            subjectsCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            subjectsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subjectsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subjectsCollectionView.heightAnchor.constraint(equalToConstant: 50),
            
            documentsCollectionView.topAnchor.constraint(equalTo: subjectsCollectionView.bottomAnchor),
            documentsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            documentsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            documentsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Documents"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(150)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Actions
    private func showStudyTechniquesModal(for document: FileMetadata) {
        let studyTechniquesVC = StudyTechniquesViewController(document: document)
        studyTechniquesVC.modalPresentationStyle = .pageSheet
        
        if let sheet = studyTechniquesVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(studyTechniquesVC, animated: true)
    }
}

// MARK: - Search Functionality
extension DocumentsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterDocuments(searchText: searchText)
    }
    
    private func filterDocuments(searchText: String) {
        if searchText.isEmpty {
            if let selectedSubject = selectedSubject {
                filterDocumentsBySubject(selectedSubject.id)
            } else {
                filteredDocuments = documents
            }
        } else {
            filteredDocuments = documents.filter { document in
                let matchesSearch = document.title.lowercased().contains(searchText.lowercased())
                if let selectedSubject = selectedSubject {
                    return matchesSearch && document.title.contains(selectedSubject.name)
                }
                return matchesSearch
            }
        }
        documentsCollectionView.reloadData()
    }
    
    private func filterDocumentsBySubject(_ subject: String) {
        print(documents,subject)
        filteredDocuments = documents.filter { $0.subjectId == subject }
        documentsCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension DocumentsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == subjectsCollectionView {
            return subjects.count
        } else {
            emptyStateLabel.isHidden = !filteredDocuments.isEmpty
            return filteredDocuments.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == subjectsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DocumentsSubjectCell.reuseIdentifier,
                for: indexPath
            ) as? DocumentsSubjectCell else {
                return UICollectionViewCell()
            }
            
            let subject = subjects[indexPath.item]
            let isSelected = subject.id == selectedSubject?.id
            cell.configure(with: subject.name, isSelected: isSelected)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DocumentCell.reuseIdentifier,
                for: indexPath
            ) as? DocumentCell else {
                return UICollectionViewCell()
            }
            
            let document = filteredDocuments[indexPath.item]
            cell.configure(with: document, index: indexPath.item)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == subjectsCollectionView {
            if selectedSubject?.id == subjects[indexPath.item].id {
                selectedSubject = nil
                filteredDocuments = documents
            } else {
                selectedSubject = subjects[indexPath.item]
                filterDocumentsBySubject(subjects[indexPath.item].id)
            }
            subjectsCollectionView.reloadData()
        } else {
            let document = filteredDocuments[indexPath.item]
            showStudyTechniquesModal(for: document)
        }
    }
}

// MARK: - Load Data
extension DocumentsViewController {
    func loadTestDocuments() {
        Task{
            let testDocuments = try await metadataDb.findAll()
            documents = testDocuments
            filteredDocuments = testDocuments
            documentsCollectionView.reloadData()
        }
    }
    
    func loadSubjects() {
        Task{
            subjects = try await subjectDb.findAll()
            subjectsCollectionView.reloadData()
        }
    }
}
