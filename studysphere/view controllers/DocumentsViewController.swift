import UIKit
import FirebaseFirestore
import UniformTypeIdentifiers
import PDFKit
import VisionKit

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
        label.text = "No documentd yet.\nTap '+' to add a upload a new document."
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
        setupTapGesture()
        setupUI()
        loadTestDocuments()
        loadSubjects()
    }
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
            
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
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
            section.interGroupSpacing = 8
            
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
       
        let documentTypes = [UTType.pdf.identifier]
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    private func presentDocumentScanner() {
        // Check if document scanning is available on this device
        if VNDocumentCameraViewController.isSupported {
            let documentCameraViewController = VNDocumentCameraViewController()
            documentCameraViewController.delegate = self
            present(documentCameraViewController, animated: true)
        } else {
            // Device doesn't support document scanning
            let alert = UIAlertController(
                title: "Not Available",
                message: "Document scanning is not available on this device.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
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
            cell.previewButton.tag = indexPath.row
            cell.previewButton.addTarget(self, action: #selector(previewPDFTapped(_:)), for: .touchUpInside)

            return cell
        }
    }
    @objc func previewPDFTapped(_ sender: UIButton) {
        // Get the document URL from the tag or from the cell
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let document = documents[indexPath.row]
        
        
        displayPDF(at: document)

    }
    func displayPDF(at document: FileMetadata) {
        let fileName = document.id + ".pdf"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localFileURL = documentsDirectory.appendingPathComponent(fileName)
        
        func showPDF(at url: URL) {
            let pdfView = PDFView()
            pdfView.autoScales = true
            
            if let pdfDocument = PDFDocument(url: url) {
                pdfView.document = pdfDocument
            } else {
                print("Failed to load PDF document")
                return
            }
            
            let pdfViewController = UIViewController()
            
            let navigationController = UINavigationController(rootViewController: pdfViewController)
            navigationController.modalPresentationStyle = .fullScreen
            
            pdfViewController.title = document.title
            
            let backButton = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissPDFView))
            pdfViewController.navigationItem.rightBarButtonItem = backButton
            
            pdfView.translatesAutoresizingMaskIntoConstraints = false
            pdfViewController.view.addSubview(pdfView)
            
            NSLayoutConstraint.activate([
                pdfView.topAnchor.constraint(equalTo: pdfViewController.view.topAnchor),
                pdfView.bottomAnchor.constraint(equalTo: pdfViewController.view.bottomAnchor),
                pdfView.leadingAnchor.constraint(equalTo: pdfViewController.view.leadingAnchor),
                pdfView.trailingAnchor.constraint(equalTo: pdfViewController.view.trailingAnchor)
            ])
            
            pdfViewController.view.backgroundColor = .white
            
            present(navigationController, animated: true)
        }
        
        if FileManager.default.fileExists(atPath: localFileURL.path) {
            print("PDF found in cache, loading from: \(localFileURL.path)")
            showPDF(at: localFileURL)
        } else {
            print("PDF not in cache, downloading...")
            
            guard let remoteURL = URL(string: document.documentUrl) else {
                print("Invalid document URL")
                return
            }
            
            let loadingAlert = UIAlertController(title: "Loading", message: "Downloading document...", preferredStyle: .alert)
            present(loadingAlert, animated: true)
            
            let task = URLSession.shared.downloadTask(with: remoteURL) { (tempLocalUrl, response, error) in
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true)
                }
                
                if let error = error {
                    print("Download error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let tempLocalUrl = tempLocalUrl else {
                    print("Invalid response or missing temporary URL")
                    return
                }
                
                do {
                    try FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
                    
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localFileURL)
                    print("PDF saved to cache: \(localFileURL.path)")
                    
                    DispatchQueue.main.async {
                        showPDF(at: localFileURL)
                    }
                } catch {
                    print("Error saving PDF to cache: \(error.localizedDescription)")
                }
            }
            
            task.resume()
        }
    }

    @objc func dismissPDFView() {
        dismiss(animated: true)
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
                
                var metadata = FileMetadata(
                    id: "",
                    title: fileName,
                    documentUrl: "",
                    subjectId: subject.id,
                    createdAt: Timestamp(),
                    updatedAt: Timestamp()
                )
                if let uploaded = await DocumentManager.shared.upload(document: url, metadata: metadata){
                    
                    
                    // Update UI
                    documents.append(uploaded)
                    if selectedSubject == nil || selectedSubject?.id == subject.id {
                        filteredDocuments.append(uploaded)
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
                }
                else{
                    DispatchQueue.main.async {
                        loadingIndicator.removeFromSuperview()
                        
                        // Show success message
                        let errorAlert = UIAlertController(
                            title: "Upload Failed",
                            message: "Could not upload document",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
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
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let selectedFileURL = urls.first else { return }
        
        // Start accessing the security-scoped resource
        let didStartAccessing = selectedFileURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                selectedFileURL.stopAccessingSecurityScopedResource()
            }
        }
        
        // Create a security-scoped bookmark for later access
        do {
            let bookmarkData = try selectedFileURL.bookmarkData(options: .minimalBookmark)
            UserDefaults.standard.set(bookmarkData, forKey: "documentBookmark")
            
            // Copy the file to app's documents directory
            let fileName = UUID().uuidString + ".pdf" // Or use a meaningful name if you have one
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let localFileURL = documentsDirectory.appendingPathComponent(fileName)
            
            // Remove the file if it already exists
            if FileManager.default.fileExists(atPath: localFileURL.path) {
                try FileManager.default.removeItem(at: localFileURL)
            }
            
            // Copy the file
            try FileManager.default.copyItem(at: selectedFileURL, to: localFileURL)
            
            // Store the local URL instead of the security-scoped URL
            uploadDocument(from: localFileURL)
        } catch {
            print("Error processing document: \(error.localizedDescription)")
        }
    }
}


extension DocumentsViewController: VNDocumentCameraViewControllerDelegate,UIDocumentInteractionControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        // Dismiss the camera controller
        controller.dismiss(animated: true)
        
        // Process the scanned images
        let images = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }
        
        // Do something with the scanned images
        processScannedDocuments(images)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        // Handle the error
        controller.dismiss(animated: true)
        
        let alert = UIAlertController(
            title: "Scanning Failed",
            message: "There was an error scanning your document: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        // User canceled the scan
        controller.dismiss(animated: true)
    }
    
    // Process the scanned document images
    private func processScannedDocuments(_ images: [UIImage]) {
        // Save original images to document directory
        for (index, image) in images.enumerated() {
            if let data = image.jpegData(compressionQuality: 0.8) {
                let filename = getDocumentsDirectory().appendingPathComponent("scan_\(Date().timeIntervalSince1970)_\(index).jpg")
                try? data.write(to: filename)
            }
        }
        
        // Create PDF from images
        let pdfURL = createPDF(from: images)
        
        // Example: Show confirmation to the user with PDF path
        let alert = UIAlertController(
            title: "Scan Complete",
            message: "Successfully scanned \(images.count) page(s) and created PDF",
            preferredStyle: .alert
        )
        
        // Add action to view the PDF
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        uploadDocument(from: pdfURL)
    }

    // Create PDF from array of images
    private func createPDF(from images: [UIImage]) -> URL {
        // Create a unique filename for the PDF
        let pdfFilename = getDocumentsDirectory().appendingPathComponent("scan_\(Date().timeIntervalSince1970).pdf")
        
        // PDF page width and height
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        
        // Create PDF context
        UIGraphicsBeginPDFContextToFile(pdfFilename.path, CGRect.zero, nil)
        
        // Go through all images
        for image in images {
            // Start a new PDF page
            UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), nil)
            
            // Calculate scaling to fit image proportionally within the page
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let ratio = min(pageWidth / imageWidth, pageHeight / imageHeight)
            let newWidth = imageWidth * ratio
            let newHeight = imageHeight * ratio
            
            // Center the image on the page
            let xOffset = (pageWidth - newWidth) / 2
            let yOffset = (pageHeight - newHeight) / 2
            
            // Draw the image on the PDF page
            image.draw(in: CGRect(x: xOffset, y: yOffset, width: newWidth, height: newHeight))
        }
        
        // End the PDF context to save the file
        UIGraphicsEndPDFContext()
        
        return pdfFilename
    }

    // Helper method to view the PDF
    private func viewPDF(at url: URL) {
        // This is a simple implementation that uses a UIDocumentInteractionController
        // For a more integrated experience, you might want to use PDFKit or a custom view
        let documentInteractionController = UIDocumentInteractionController(url: url)
        documentInteractionController.delegate = self
        documentInteractionController.presentPreview(animated: true)
    }
    
    // Helper to get documents directory
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            return self
        }
}
