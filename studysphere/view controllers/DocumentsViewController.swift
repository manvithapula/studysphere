import UIKit
import FirebaseFirestore
import UniformTypeIdentifiers

class DocumentsViewController: UIViewController {
    // MARK: - Properties
    private var documents: [FileMetadata] = [] // Original list
    private var filteredDocuments: [FileMetadata] = [] // For search
    private var subjects: [Subject] = [] // Subject list
    private var selectedSubject: Subject? // Track selected subject
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search documents..."
        sb.searchBarStyle = .minimal
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
        cv.backgroundColor = .systemGray6
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
        cv.backgroundColor = .systemGray6
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
    
 
    
    private func createLayout() -> UICollectionViewLayout {
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
    @IBAction private func uploadButtonTapped(_ sender: Any) {
        // Show action sheet with options
        let actionSheet = UIAlertController(
            title: "Upload Document",
            message: "Choose a document to upload",
            preferredStyle: .actionSheet
        )
        
        // Add option to pick from files
        actionSheet.addAction(UIAlertAction(title: "Browse Files", style: .default) { [weak self] _ in
            self?.presentDocumentPicker()
        })
        
        // Add option to take a photo (scan document)
        actionSheet.addAction(UIAlertAction(title: "Scan Document", style: .default) { [weak self] _ in
            self?.presentDocumentScanner()
        })
        
        // Add cancel option
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the action sheet
        present(actionSheet, animated: true)
    }
    private func presentDocumentPicker() {
        // Create a document picker for PDFs
        let documentTypes = [UTType.pdf.identifier]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    private func presentDocumentScanner() {
        // This would typically use VNDocumentCameraViewController
        // For now, just show an alert that this feature is coming soon
        let alert = UIAlertController(
            title: "Coming Soon",
            message: "Document scanning will be available in a future update.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
    private func uploadDocument(from url: URL) {
        // Show subject selection for the document
        presentSubjectSelectionForUpload(documentURL: url)
    }
    private func presentSubjectSelectionForUpload(documentURL: URL) {
        // Create alert controller for subject selection
        let alert = UIAlertController(
            title: "Select Subject",
            message: "Choose a subject for this document",
            preferredStyle: .actionSheet
        )
        
        // Add actions for each subject
        for subject in subjects {
            alert.addAction(UIAlertAction(title: subject.name, style: .default) { [weak self] _ in
                self?.processDocumentUpload(url: documentURL, subject: subject)
            })
        }
        
        // Add option to create new subject
        alert.addAction(UIAlertAction(title: "New Subject", style: .default) { [weak self] _ in
            self?.presentNewSubjectDialog(documentURL: documentURL)
        })
        
        // Add cancel option
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the alert
        present(alert, animated: true)
    }
    private func presentNewSubjectDialog(documentURL: URL) {
        let alert = UIAlertController(
            title: "New Subject",
            message: "Enter a name for the new subject",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Subject Name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let textField = alert?.textFields?.first,
                  let subjectName = textField.text,
                  !subjectName.isEmpty else { return }
            
            // Create new subject
            self.createNewSubject(name: subjectName) { subject in
                self.processDocumentUpload(url: documentURL, subject: subject)
            }
        })
        
        present(alert, animated: true)
    }
    private func createNewSubject(name: String, completion: @escaping (Subject) -> Void) {
        var newSubject = Subject(
            id: "", name: name, createdAt: Timestamp(), updatedAt: Timestamp()
        )
        
        // Save to database
        newSubject = subjectDb.create(&newSubject)
        subjects.append(newSubject)
        subjectsCollectionView.reloadData()
        
        completion(newSubject)
    }
    private func processDocumentUpload(url: URL, subject: Subject) {
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
        Task {
            do {
                // Get file name
                let fileName = url.lastPathComponent
                
                // Create storage path
                let storagePath = "documents/\(UUID().uuidString)_\(fileName)"
                
                // Upload to Firebase Storage
                let storageURL = try await FirebaseStorageManager.shared.uploadFile(from: url, to: storagePath)
                
                // Create metadata object
                var metadata = FileMetadata(
                    id: "",
                    title: fileName,
                    documentUrl: storageURL.absoluteString,
                    subjectId: subject.id,
                    createdAt: Timestamp(),
                    updatedAt: Timestamp()
                )
                
                // Save metadata to database
                metadata = metadataDb.create(&metadata)
                
                // Update UI
                documents.append(metadata)
                if selectedSubject == nil || selectedSubject?.id == subject.id {
                    filteredDocuments.append(metadata)
                }
                
                DispatchQueue.main.async {
                    loadingIndicator.removeFromSuperview()
                    self.documentsCollectionView.reloadData()
                    
                    // Show success message
                    let successAlert = UIAlertController(
                        title: "Upload Successful",
                        message: "Your document has been uploaded.",
                        preferredStyle: .alert
                    )
                    successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(successAlert, animated: true)
                }
            } catch {
                DispatchQueue.main.async {
                    loadingIndicator.removeFromSuperview()
                    
                    // Show error message
                    let errorAlert = UIAlertController(
                        title: "Upload Failed",
                        message: "Could not upload document: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            }
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
extension DocumentsViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        
        // Secure access to the URL
        let securityScoped = selectedURL.startAccessingSecurityScopedResource()
        defer {
            if securityScoped {
                selectedURL.stopAccessingSecurityScopedResource()
            }
        }
        
        // Process the document
        uploadDocument(from: selectedURL)
    }
}
