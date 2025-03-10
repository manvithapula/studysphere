import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import Foundation
import FirebaseCore
import GoogleGenerativeAI

// MARK: - Subject Model
//struct Subject: Codable, Identifiable {
//    var id: String
//    let name: String
//
//    init(id: String = UUID().uuidString, name: String) {
//        self.id = id
//        self.name = name
//    }
//}
struct Technique{
  var name: String
}


// MARK: - Custom Views
class StyledTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }

    func setupStyle() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray5.cgColor
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: frame.height))
        leftViewMode = .always
        font = .systemFont(ofSize: 16)
        heightAnchor.constraint(equalToConstant: 50).isActive = true
        tintColor = .systemBlue
    }
}

class DropdownField: StyledTextField {
    private let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.down"))

    override func setupStyle() {
        super.setupStyle()

//        chevronImageView.tintColor = .systemGray2
//        chevronImageView.contentMode = .center
//        chevronImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
//
//        rightView = chevronImageView
//        rightViewMode = .always

    }
}

class TechniqueButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }

    private func setupStyle() {
        backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        layer.cornerRadius = 20
        titleLabel?.font = .systemFont(ofSize: 16)
        setTitleColor(AppTheme.primary, for: .normal)
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    }

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? AppTheme.primary.withAlphaComponent(0.2) : AppTheme.primary.withAlphaComponent(0.1)
        }
    }
}

class CreateViewController: UIViewController {
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let unitNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Unit Name"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    private let Topic = StyledTextField()

    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.text = "Subject"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    private let subjectField = DropdownField()


    // Add button for adding new subject
    private lazy var addSubjectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        button.tintColor = AppTheme.primary
        button.addTarget(self, action: #selector(addSubjectTapped), for: .touchUpInside)
        return button
    }()

    private let techniqueLabel: UILabel = {
        let label = UILabel()
        label.text = "Learning Technique"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    // Replace horizontal scroll with vertical stack
    private let techniquesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        return stackView
    }()
    private let techniques = [Technique(name: "Space Repetition"), Technique(name: "Active Recall"), Technique(name: "Summariser")]
    private lazy var spacedRepetitionButton: TechniqueButton = {
        let button = TechniqueButton()
        let imageConfig = UIImage.SymbolConfiguration(scale: .small)
        let clockImage = UIImage(systemName: "clock", withConfiguration: imageConfig)
        button.setImage(clockImage, for: .normal)
        button.setTitle(techniques[0].name, for: .normal)
        button.addTarget(self, action: #selector(techniqueTapped(_:)), for: .touchUpInside)
        button.tintColor = AppTheme.primary
        return button
    }()

    private lazy var activeRecallButton: TechniqueButton = {
        let button = TechniqueButton()
        let imageConfig = UIImage.SymbolConfiguration(scale: .small)
        let brainImage = UIImage(systemName: "brain", withConfiguration: imageConfig)
        button.setImage(brainImage, for: .normal)
        button.setTitle(techniques[1].name, for: .normal)
        button.addTarget(self, action: #selector(techniqueTapped(_:)), for: .touchUpInside)
        button.tintColor = AppTheme.primary
        return button
    }()

    private lazy var summariserButton: TechniqueButton = {
        let button = TechniqueButton()
        let imageConfig = UIImage.SymbolConfiguration(scale: .small)
        let textImage = UIImage(systemName: "text.alignleft", withConfiguration: imageConfig)
        button.setImage(textImage, for: .normal)
        button.setTitle(techniques[2].name, for: .normal)
        button.addTarget(self, action: #selector(techniqueTapped(_:)), for: .touchUpInside)
        button.tintColor = AppTheme.primary
        return button
    }()

    private let uploadLabel: UILabel = {
        let label = UILabel()
        label.text = "Upload Document"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    private let fileUploadView = DashedRectangle()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .systemGray4
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()

    private var dropdownTableView: UITableView?
    private let tableRowHeight = CGFloat(44)
    private var subjects: [Subject] = []
    private var selectedTechnique: String?
    var filteredSubjects: [Subject] {
        return subjects.filter { card in
            let matchesSearch = subjectField.text?.isEmpty ?? true || card.name.lowercased().contains(subjectField.text!.lowercased())
                return matchesSearch
            }
        }

    // Add alert controller for new subject
    private var newSubjectAlertController: UIAlertController?

    var generativeModel: GenerativeModel?
    var apiKey: String?
    private var selectedSubject: Subject?
    private var document:URL?
    //  add a boolean to track when the document is already uploaded
    private var isDocUploaded: Bool = false


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        apiKey = Secrets.geminiAPIKey
        setupUI()
        setupActions()
//        setupTapGesture()
    }
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSubjects()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Setup scroll view and content
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [scrollView, contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Add all components
        [unitNameLabel, Topic, subjectLabel, subjectField,
         techniqueLabel, techniquesStackView, uploadLabel,
         fileUploadView, createButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Add technique buttons to stack view
        [spacedRepetitionButton, activeRecallButton, summariserButton].forEach {
            techniquesStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Setup text fields
        Topic.placeholder = "Enter unit name"
        subjectField.placeholder = "Select Subject"

        // Layout constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Unit Name
            unitNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            unitNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            Topic.topAnchor.constraint(equalTo: unitNameLabel.bottomAnchor, constant: 8),
            Topic.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            Topic.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Subject
            subjectLabel.topAnchor.constraint(equalTo: Topic.bottomAnchor, constant: 20),
            subjectLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subjectField.topAnchor.constraint(equalTo: subjectLabel.bottomAnchor, constant: 8),
            subjectField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subjectField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

//            // Add Subject Button
//            addSubjectButton.centerYAnchor.constraint(equalTo: subjectField.centerYAnchor),
//            addSubjectButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            addSubjectButton.widthAnchor.constraint(equalToConstant: 44),
//            addSubjectButton.heightAnchor.constraint(equalToConstant: 44),

            // Technique
            techniqueLabel.topAnchor.constraint(equalTo: subjectField.bottomAnchor, constant: 20),
            techniqueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            // Technique stack view
            techniquesStackView.topAnchor.constraint(equalTo: techniqueLabel.bottomAnchor, constant: 8),
            techniquesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            techniquesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Make technique buttons full width
            spacedRepetitionButton.widthAnchor.constraint(equalTo: techniquesStackView.widthAnchor),
            activeRecallButton.widthAnchor.constraint(equalTo: techniquesStackView.widthAnchor),
            summariserButton.widthAnchor.constraint(equalTo: techniquesStackView.widthAnchor),

            // Upload
            uploadLabel.topAnchor.constraint(equalTo: techniquesStackView.bottomAnchor, constant: 20),
            uploadLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fileUploadView.topAnchor.constraint(equalTo: uploadLabel.bottomAnchor, constant: 8),
            fileUploadView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fileUploadView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            fileUploadView.heightAnchor.constraint(equalToConstant: 200),

            // Create Button
            createButton.topAnchor.constraint(equalTo: fileUploadView.bottomAnchor, constant: 30),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])

        // Setup file upload view
        fileUploadView.setup(in: self)
    }

    private func setupActions() {
        subjectField.addTarget(self, action: #selector(showSubjectDropdown), for: .allEditingEvents)
        subjectField.addTarget(self, action: #selector(hideDrpdown), for: .editingDidEnd)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)

    }
    @objc private func hideDrpdown(){
        hideDropdown()
    }

    // MARK: - Subject Methods
    func loadSubjects() {
        Task {
            do {
                subjects = try await subjectDb.findAll()
                if let tableView = dropdownTableView {
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
            } catch {
                print("Error loading subjects: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Actions
    @objc private func showSubjectDropdown() {
        dropdownTableView?.removeFromSuperview()

        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = 12
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.systemGray5.cgColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SubjectCell")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: subjectField.bottomAnchor, constant: 5),
            tableView.leadingAnchor.constraint(equalTo: subjectField.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: subjectField.trailingAnchor),
            tableView.heightAnchor.constraint(lessThanOrEqualToConstant: CGFloat(filteredSubjects.count) * tableRowHeight)
        ])

        dropdownTableView = tableView

        // Load subjects if needed
        if subjects.isEmpty {
            loadSubjects()
        } else {
            tableView.reloadData()
        }
    }

    @objc private func techniqueTapped(_ sender: TechniqueButton) {
        // Clear all selections
        for view in techniquesStackView.arrangedSubviews {
            if let button = view as? TechniqueButton {
                button.isSelected = false
            }
        }

        // Select the tapped button
        sender.isSelected = true
        selectedTechnique = sender.titleLabel?.text?.trimmingCharacters(in: .whitespaces)

        // Enable create button if all fields are filled
        updateCreateButtonState()
    }

    @objc private func addSubjectTapped() {
        // Create alert controller
        let alertController = UIAlertController(
            title: "Add New Subject",
            message: "Enter the name of the new subject",
            preferredStyle: .alert
        )

        // Add text field
        alertController.addTextField { textField in
            textField.placeholder = "Subject Name"
        }

        // Add actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alertController.textFields?.first,
                  let subjectName = textField.text,
                  !subjectName.isEmpty else {
                return
            }

            // Create and save new subject
            self.saveNewSubject(name: subjectName)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        // Present alert
        present(alertController, animated: true)
    }

    private func saveNewSubject(name: String) {
        // Create new subject object
        //let newSubject = subjectDb.create(subject: Subject(name: name))

        // Save to database
        Task {
            do {
                //try await subjectDb.save(newSubject)
                // Reload subjects
                subjects = try await subjectDb.findAll()

                // Select the new subject
                subjectField.text = name
                updateCreateButtonState()

                // Show success message
                let successAlert = UIAlertController(
                    title: "Success",
                    message: "Subject '\(name)' has been added",
                    preferredStyle: .alert
                )
                successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                present(successAlert, animated: true)
            } catch {
                // Show error message
                let errorAlert = UIAlertController(
                    title: "Error",
                    message: "Failed to save subject: \(error.localizedDescription)",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                present(errorAlert, animated: true)
            }
        }
    }

    fileprivate func createNewSubject() {
        var newSubject = Subject(id:"",name: subjectField.text!,createdAt:Timestamp(),updatedAt: Timestamp())
        newSubject = subjectDb.create(&newSubject)
        self.selectedSubject = newSubject
    }

    @objc private func createButtonTapped() {
        Task{
            if let selectedSubject = selectedSubject{
                if(selectedSubject.name != subjectField.text){
                    createNewSubject()
                }
            }
            else{
                let allSubjects = try await subjectDb.findAll(where: ["name":subjectField.text!])
                if let existingSubject = allSubjects.first{
                    selectedSubject = existingSubject
                }
                else{
                    createNewSubject()
                }
            }
            switch(selectedTechnique){
            case techniques[0].name:
                createSR(self)
                break
            case techniques[1].name:
                createAR(self)
                break
            case techniques[2].name:
                createSummarizer(self)
                break
            default:
                break
            }
        }
    }

    private func updateCreateButtonState() {
        let isValid = !(Topic.text?.isEmpty ?? true) && !(subjectField.text?.isEmpty ?? true) &&
        selectedTechnique != nil && document != nil
       // change isValid to check doc uploaded
        let isValidDoc = !(Topic.text?.isEmpty ?? true) && !(subjectField.text?.isEmpty ?? true) &&
        selectedTechnique != nil && isDocUploaded == true

        createButton.backgroundColor = isValidDoc ? AppTheme.primary : .systemGray4
        createButton.isEnabled = isValidDoc
    }

    private func hideDropdown() {
        dropdownTableView?.removeFromSuperview()
        dropdownTableView = nil
    }
}

// MARK: - UITableViewDelegate & DataSource
extension CreateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSubjects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath)
        cell.textLabel?.text = filteredSubjects[indexPath.row].name
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.backgroundColor = .clear

        // Remove the selection style
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sub = filteredSubjects[indexPath.row]
        subjectField.text = sub.name
        selectedSubject = sub
        hideDropdown()
        updateCreateButtonState()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRowHeight
    }
}

// MARK: - UITextFieldDelegate
extension CreateViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Only allow editing for unitNameField
        return textField == Topic
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateCreateButtonState()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == subjectField {
            textField.resignFirstResponder()
            showSubjectDropdown()
        }
    }
}

// MARK: - Touch Handling
extension CreateViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        // Hide dropdown when tapping outside
        if let touch = touches.first {
            let location = touch.location(in: view)
            if let dropdownTableView = dropdownTableView,
               !dropdownTableView.frame.contains(location) && !subjectField.frame.contains(location) {
                hideDropdown()
            }
        }

        view.endEditing(true)
    }
}

// MARK: - UIDocumentPickerDelegate
extension CreateViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }

        document = selectedFileURL
        // call docUploaded func to change the backgroundColor of the fileuploadview
        docUploaded()
        updateCreateButtonState()
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Handle cancelled picker if needed
    }
   // create function that runs once the document is uploaded
    func docUploaded(){
        isDocUploaded = true
        fileUploadView.backgroundColor = UIColor.green.withAlphaComponent(0.1)
        fileUploadView.iconImageView.tintColor = .black
        fileUploadView.titleLabel.textColor = .black
        fileUploadView.subtitleLabel.textColor = .black
        fileUploadView.supportLabel.textColor = .black
        fileUploadView.layer.borderWidth = 0.5
        fileUploadView.titleLabel.text = "Uploaded!";
        fileUploadView.subtitleLabel.text = document?.lastPathComponent;
    }
    func createSR(_ sender: Any) {
            if let apiKey = apiKey {
                let config = GenerationConfig(
                    temperature: 1,
                    topP: 0.95,
                    topK: 64,
                    maxOutputTokens: 8192,
                    responseMIMEType: "application/json",
                    responseSchema: Schema(type: .object,properties:[
                        "response":Schema(type: .object,properties: [
                            "data":Schema(type: .array,items:Schema(type: .object,properties: [
                                "question":Schema(type: .string),
                                "answer":Schema(type: .string)
                            ]))
                        ])
                    ])


                )
                generativeModel = GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey,generationConfig: config)
            } else {
                print("API Key not found!")
            }
            var newTopic = Topics(id: "", title: Topic.text!, subject: selectedSubject!.id, type: .flashcards,subtitle: "6 more to go",createdAt: Timestamp(),updatedAt: Timestamp())
            newTopic = topicsDb.create(&newTopic)
            showLoading(text:"Generating flashcards...")
            Task{
                let cards = await createFlashCards(topic: newTopic.id)
                if(cards.isEmpty){
                    hideLoading()
                    showError(message: "Faled to generate flashcards")
                    topicsDb.delete(id: newTopic.id)
                    return
                }

                let mySchedules = spacedRepetitionSchedule(startDate: Foundation.Date(), title:newTopic.title,topic: newTopic.id,topicsType: TopicsType.flashcards)
                for var schedule in mySchedules{
                    let _ = schedulesDb.create(&schedule)
                }
                hideLoading()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.makeKeyAndVisible()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let navigationVC = tabBarVC.viewControllers?.first(where: { $0 is UINavigationController }) as? UINavigationController,
                           let homeVC = navigationVC.viewControllers.first(where: { $0 is homeScreenViewController }) as? homeScreenViewController {
                            homeVC.performSegue(withIdentifier: "toSrListView", sender: nil)
                        } else {
                            print("Error: HomeViewController is not properly embedded in UINavigationController under TabBarController.")
                        }
                    }
                } else {
                    print("Error: Could not instantiate TabBarController.")
                }

            }

        }
        func createAR(_ sender: Any) {
            if let apiKey = apiKey {
                let config = GenerationConfig(
                    temperature: 1,
                    topP: 0.95,
                    topK: 64,
                    maxOutputTokens: 8192,
                    responseMIMEType: "application/json",
                    responseSchema: Schema(type: .object,properties:[
                        "response":Schema(type: .object,properties: [
                            "data":Schema(type: .array,items:Schema(type: .object,properties: [
                                "question":Schema(type: .string),
                                "option1":Schema(type: .string),
                                "option2":Schema(type: .string),
                                "option3":Schema(type: .string),
                                "option4":Schema(type: .string),
                                "correctOption":Schema(type: .string)
                            ]))
                        ])
                    ])


                )
                generativeModel = GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey,generationConfig: config)
            } else {
                print("API Key not found!")
            }
            var newTopic = Topics(id: "", title: Topic.text!, subject: selectedSubject!.id, type: .quizzes,subtitle: "6 more to go",createdAt: Timestamp(),updatedAt: Timestamp())
            newTopic = topicsDb.create(&newTopic)
            showLoading(text:"Generating Quiz...")
            Task{
                let ques = await createQuestions(topic: newTopic.id)
                if(ques.isEmpty){
                    hideLoading()
                    showError(message: "Failed to generate Quiz")
                    topicsDb.delete(id: newTopic.id)
                    return
                }
                let mySchedules = spacedRepetitionSchedule(startDate: Foundation.Date(), title:newTopic.title,topic: newTopic.id,topicsType: TopicsType.quizzes)
                for var schedule in mySchedules{
                    let _ = schedulesDb.create(&schedule)
                }
                hideLoading()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.makeKeyAndVisible()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let navigationVC = tabBarVC.viewControllers?.first(where: { $0 is UINavigationController }) as? UINavigationController,
                           let homeVC = navigationVC.viewControllers.first(where: { $0 is homeScreenViewController }) as? homeScreenViewController {
                            homeVC.performSegue(withIdentifier: "toArListView", sender: nil)
                        } else {
                            print("Error: HomeViewController is not properly embedded in UINavigationController under TabBarController.")
                        }
                    }
                } else {
                    print("Error: Could not instantiate TabBarController.")
                }
            }
        }

        func createSummarizer(_ sender: Any) {
            if let apiKey = apiKey {
                let config = GenerationConfig(
                    temperature: 1,
                    topP: 0.95,
                    topK: 64,
                    maxOutputTokens: 8192,
                    responseMIMEType: "application/json",
                    responseSchema: Schema(type: .object,properties:[
                        "response":Schema(type: .object,properties: [
                            "data":Schema(type: .object,properties: [
                                "summary":Schema(type: .string)
                            ])
                        ])
                    ])


                )
                generativeModel = GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey,generationConfig: config)
            } else {
                print("API Key not found!")
            }
            var newTopic = Topics(id: "", title: Topic.text!, subject: selectedSubject!.id, type: .summary,subtitle: "",createdAt: Timestamp(),updatedAt: Timestamp())
            newTopic = topicsDb.create(&newTopic)
            showLoading(text:"Generating summary...")
            Task{
                let summary = await createSummary(topic: newTopic.id)
                hideLoading()
                if(summary == nil){
                    showError(message: "Failed to create summary")
                    topicsDb.delete(id:newTopic.id)
                    return
                }
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = tabBarVC
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.makeKeyAndVisible()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let navigationVC = tabBarVC.viewControllers?.first(where: { $0 is UINavigationController }) as? UINavigationController,
                           let homeVC = navigationVC.viewControllers.first(where: { $0 is homeScreenViewController }) as? homeScreenViewController {
                            homeVC.performSegue(withIdentifier: "toSuListView", sender: nil)
                        } else {
                            print("Error: HomeViewController is not properly embedded in UINavigationController under TabBarController.")
                        }
                    }
                } else {
                    print("Error: Could not instantiate TabBarController.")
                }
            }

            }


        private func getFileUri() async -> String? {
            guard let pdfData = try? Data(contentsOf: document!) else {
                        print("Error reading PDF data")
                        return nil
                    }
            print(pdfData)
            let baseURL = "https://generativelanguage.googleapis.com"
            let fileSize = pdfData.count
            do {
                // Create upload URL request
                var urlComponents = URLComponents(string: "\(baseURL)/upload/v1beta/files")!
                urlComponents.queryItems = [URLQueryItem(name: "key", value: apiKey)]

                var request = URLRequest(url: urlComponents.url!)
                request.httpMethod = "POST"
                request.setValue("resumable", forHTTPHeaderField: "X-Goog-Upload-Protocol")
                request.setValue("start", forHTTPHeaderField: "X-Goog-Upload-Command")
                request.setValue("\(fileSize)", forHTTPHeaderField: "X-Goog-Upload-Header-Content-Length")
                request.setValue("application/pdf", forHTTPHeaderField: "X-Goog-Upload-Header-Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                let metadata = ["file": ["display_name": "PDF_Document"]]
                request.httpBody = try JSONSerialization.data(withJSONObject: metadata)

                // Get upload URL
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse,
                      let uploadURL = httpResponse.value(forHTTPHeaderField: "X-Goog-Upload-URL") else {
                    throw NSError(domain: "PDFUploader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get upload URL"])
                }

                // Upload the PDF
                var uploadRequest = URLRequest(url: URL(string: uploadURL)!)
                uploadRequest.httpMethod = "POST"
                uploadRequest.setValue("\(fileSize)", forHTTPHeaderField: "Content-Length")
                uploadRequest.setValue("0", forHTTPHeaderField: "X-Goog-Upload-Offset")
                uploadRequest.setValue("upload, finalize", forHTTPHeaderField: "X-Goog-Upload-Command")
                uploadRequest.httpBody = pdfData

                let (fileInfoData, _) = try await URLSession.shared.data(for: uploadRequest)
                let fileInfo = try JSONSerialization.jsonObject(with: fileInfoData) as! [String: Any]
                return (fileInfo["file"] as? [String: Any])?["uri"] as? String
            }
            catch{
                return nil
            }
        }
        private func createSummary(topic:String)async -> Summary?{


            do{
                guard let fileURI = await getFileUri() else {
                    throw NSError(domain: "PDFUploader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get file URI"])
                }
                let prompt = """
                Create Summary for this PDF document.
                Focus on key concepts and important details from the content.
                so that i can give a quick look before the exam
                """

                let content = ModelContent(role: "user", parts: [
                            ModelContent.Part.text(prompt),
                            ModelContent.Part.fileData(mimetype: "application/pdf", uri: fileURI)])

                                                    // Generate content using the model
                                            let respons = try await generativeModel?.generateContent([content])
                                            print(respons as Any)
                                                // Parse the response and create flashcards
                                            if let jsonData = respons?.text?.data(using: .utf8),
                                               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                                               let responseData = json["response"] as? [String: Any],
                                               let data = responseData["data"] as? [String: Any],
                                               let summaryText = data["summary"] as? String {

                                                var summary = Summary(
                                                    id: "",
                                                    topic: topic,
                                                    data: summaryText,
                                                    createdAt: Timestamp(),
                                                    updatedAt: Timestamp()
                                                )
                                                summary = summaryDb.create(&summary)
                                                return summary
                                            }

                                            return nil
                                        }
                                        catch{
                                            print(error)
                                            return nil
                                        }

                                    }
                                    private func createFlashCards(topic:String) async -> [Flashcard]{
                                                guard let pdfData = try? Data(contentsOf:document!) else {
                                                            print("Error reading PDF data")
                                                            return []
                                                        }
                                                let baseURL = "https://generativelanguage.googleapis.com"
                                                let fileSize = pdfData.count
                                                        // Send the request to the model
                                //                let response = try await model.generateContent(prompt, parts: [part])
                                //                print(response)
                                                do {
                                                        // Create upload URL request
                                                        var urlComponents = URLComponents(string: "\(baseURL)/upload/v1beta/files")!
                                                        urlComponents.queryItems = [URLQueryItem(name: "key", value: apiKey)]

                                                        var request = URLRequest(url: urlComponents.url!)
                                                        request.httpMethod = "POST"
                                                        request.setValue("resumable", forHTTPHeaderField: "X-Goog-Upload-Protocol")
                                                        request.setValue("start", forHTTPHeaderField: "X-Goog-Upload-Command")
                                                        request.setValue("\(fileSize)", forHTTPHeaderField: "X-Goog-Upload-Header-Content-Length")
                                                        request.setValue("application/pdf", forHTTPHeaderField: "X-Goog-Upload-Header-Content-Type")
                                                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                                                        let metadata = ["file": ["display_name": "PDF_Document"]]
                                                        request.httpBody = try JSONSerialization.data(withJSONObject: metadata)

                                                        // Get upload URL
                                                        let (_, response) = try await URLSession.shared.data(for: request)
                                                        guard let httpResponse = response as? HTTPURLResponse,
                                                              let uploadURL = httpResponse.value(forHTTPHeaderField: "X-Goog-Upload-URL") else {
                                                            throw NSError(domain: "PDFUploader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get upload URL"])
                                                        }

                                                        // Upload the PDF
                                                        var uploadRequest = URLRequest(url: URL(string: uploadURL)!)
                                                        uploadRequest.httpMethod = "POST"
                                                        uploadRequest.setValue("\(fileSize)", forHTTPHeaderField: "Content-Length")
                                                        uploadRequest.setValue("0", forHTTPHeaderField: "X-Goog-Upload-Offset")
                                                        uploadRequest.setValue("upload, finalize", forHTTPHeaderField: "X-Goog-Upload-Command")
                                                        uploadRequest.httpBody = pdfData

                                                        let (fileInfoData, _) = try await URLSession.shared.data(for: uploadRequest)
                                                        let fileInfo = try JSONSerialization.jsonObject(with: fileInfoData) as! [String: Any]
                                                        guard let fileURI = (fileInfo["file"] as? [String: Any])?["uri"] as? String else {
                                                            throw NSError(domain: "PDFUploader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get file URI"])
                                                        }

                                                        // Create prompt for flashcard generation
                                                        let prompt = """
                                                        Create flashcards from this PDF document.
                                                        Focus on key concepts and important details from the content.
                                                        Please provide 7 question-answer pairs.
                                                        """

                                                    let content = ModelContent(role: "user", parts: [
                                                                ModelContent.Part.text(prompt),
                                                                ModelContent.Part.fileData(mimetype: "application/pdf", uri: fileURI)
                                                            ])

                                                            // Generate content using the model
                                                    let respons = try await generativeModel?.generateContent([content])
                                                    print(respons as Any)
                                                        // Parse the response and create flashcards
                                                    if let jsonData = respons?.text?.data(using: .utf8),
                                                           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                                                           let responseData = json["response"] as? [String: Any],
                                                           let cards = responseData["data"] as? [[String: String]] {

                                                            var flashcards: [Flashcard] = []
                                                            for cardData in cards {
                                                                if let question = cardData["question"],
                                                                   let answer = cardData["answer"] {
                                                                    var flashcard = Flashcard(
                                                                        id: "",
                                                                        question: question,
                                                                        answer: answer,
                                                                        topic: topic,
                                                                        createdAt: Timestamp(),
                                                                        updatedAt: Timestamp()
                                                                    )
                                                                    let _ = flashCardDb.create(&flashcard)
                                                                    flashcards.append(flashcard)
                                                                }
                                                            }
                                                            return flashcards
                                                        }

                                                        return []

                                                    } catch {
                                                        print("Error processing PDF: \(error)")
                                                        return []
                                                    }
                                            }
                                    private func createQuestions(topic: String) async -> [Questions] {


                                        do{
                                            guard let fileURI = await getFileUri() else {
                                                print("Failed to upload")
                                                throw NSError(domain: "PDFUploader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to get file URI"])
                                            }
                                            let prompt = """
                                            Create Questions from this PDF document.
                                            Focus on key concepts and important details from the content.
                                            make sure the answers are small as possible and fit in one line.
                                            one of the option should be the correct answer and randomize this option
                                            Please provide at least 5 questions
                                            """

                                            let content = ModelContent(role: "user", parts: [
                                                        ModelContent.Part.text(prompt),
                                                        ModelContent.Part.fileData(mimetype: "application/pdf", uri: fileURI)
                                                    ])

                                                    // Generate content using the model
                                            let respons = try await generativeModel?.generateContent([content])
                                            print(respons as Any)
                                                // Parse the response and create flashcards
                                            if let jsonData = respons?.text?.data(using: .utf8),
                                                   let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                                                   let responseData = json["response"] as? [String: Any],
                                                   let cards = responseData["data"] as? [[String: String]] {

                                                var questions: [Questions] = []
                                                    var i = 1
                                                    for cardData in cards {
                                                        print(cardData)
                                                        if let question = cardData["question"],
                                                           let answer = cardData["correctOption"],
                                                           let a = cardData["option1"],
                                                           let b = cardData["option2"],
                                                           let c = cardData["option3"],
                                                           let d = cardData["option4"]{
                                                            var question1 = Questions(
                                                                id:"",
                                                                questionLabel: "\(i)",
                                                                question: question,
                                                                correctanswer: answer,
                                                                option1: a,
                                                                option2: b,
                                                                option3: c,
                                                                option4: d,
                                                                topic: topic
                                                            )
                                                            let _ = questionsDb.create(&question1)
                                                            questions.append(question1)
                                                            i += 1
                                                        }
                                                    }
                                                return questions
                                                }

                                                return []
                                        }
                                        catch{
                                            return []
                                        }

                                    }
                                    private func showLoading(text:String) {
                                            let loadingView = LoadingView()
                                            loadingView.tag = 999 // Tag for easy removal
                                            loadingView.text = text
                                            view.addSubview(loadingView)
                                            loadingView.translatesAutoresizingMaskIntoConstraints = false

                                            NSLayoutConstraint.activate([
                                                loadingView.topAnchor.constraint(equalTo: view.topAnchor),
                                                loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                                loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                                loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                                            ])

                                            loadingView.show()
                                        }

                                        private func hideLoading() {
                                            if let loadingView = view.viewWithTag(999) {
                                                loadingView.removeFromSuperview()
                                            }
                                        }
                                    private func showError(message: String) {
                                        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        present(alert, animated: true, completion: nil)
                                    }
                            }

                            // MARK: - File Upload View
                            class DashedRectangle: UIView {
                                let iconImageView: UIImageView = {
                                    let imageView = UIImageView()
                                    let config = UIImage.SymbolConfiguration(pointSize: 30)
                                    imageView.image = UIImage(systemName: "doc.badge.plus", withConfiguration: config)
                                    imageView.tintColor = AppTheme.primary
                                    imageView.contentMode = .scaleAspectFit
                                    return imageView
                                }()

                                let titleLabel: UILabel = {
                                    let label = UILabel()
                                    label.text = "Drop your files here"
                                    label.font = .systemFont(ofSize: 16, weight: .medium)
                                    label.textColor = AppTheme.primary
                                    return label
                                }()

                                let subtitleLabel: UILabel = {
                                    let label = UILabel()
                                    label.text = "or click to browse"
                                    label.font = .systemFont(ofSize: 14)
                                    label.textColor = .systemGray
                                    return label
                                }()

                                let supportLabel: UILabel = {
                                    let label = UILabel()
                                    label.text = "Supports PDF files"
                                    label.font = .systemFont(ofSize: 12)
                                    label.textColor = .systemGray
                                    return label
                                }()

                                override init(frame: CGRect) {
                                    super.init(frame: frame)
                                    setupView()
                                }

                                required init?(coder: NSCoder) {
                                    super.init(coder: coder)
                                    setupView()
                                }

                                private func setupView() {
                                    backgroundColor = .systemBackground
                                    layer.cornerRadius = 12

                                    // Add dashed border
                                    let borderLayer = CAShapeLayer()
                                    borderLayer.strokeColor = UIColor.systemGray4.cgColor
                                    borderLayer.lineDashPattern = [6, 6]
                                    borderLayer.frame = bounds
                                    borderLayer.fillColor = nil
                                    borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
                                    layer.addSublayer(borderLayer)

                                    // Add subviews
                                    [iconImageView, titleLabel, subtitleLabel, supportLabel].forEach {
                                        addSubview($0)
                                        $0.translatesAutoresizingMaskIntoConstraints = false
                                    }

                                    NSLayoutConstraint.activate([
                                        iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                                        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),

                                        titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
                                        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

                                        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                                        subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

                                        supportLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),
                                        supportLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
                                    ])

                                    // Update border layer when frame changes
                                    addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
                                }


                                override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
                                    if keyPath == "bounds" {
                                        // Update border layer path when bounds change
                                        if let borderLayer = layer.sublayers?.first as? CAShapeLayer {
                                            borderLayer.frame = bounds
                                            borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
                                        }
                                    }
                                }

                                func setup(in viewController: UIViewController) {
                                    // Add tap gesture
                                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                                    addGestureRecognizer(tapGesture)
                                    isUserInteractionEnabled = true
                                }

                                @objc private func handleTap() {
                                    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
                                    documentPicker.delegate = self.superview?.parentViewController as? UIDocumentPickerDelegate
                                    documentPicker.allowsMultipleSelection = false
                                    self.superview?.parentViewController?.present(documentPicker, animated: true)
                                }

                                deinit {
                                    removeObserver(self, forKeyPath: "bounds")
                                }
                            }

                            // MARK: - Helper Extension
                            extension UIView {
                                var parentViewController: UIViewController? {
                                    var parentResponder: UIResponder? = self
                                    while parentResponder != nil {
                                        parentResponder = parentResponder?.next
                                        if let viewController = parentResponder as? UIViewController {
                                            return viewController
                                        }
                                    }
                                    return nil
                                }
                            }
