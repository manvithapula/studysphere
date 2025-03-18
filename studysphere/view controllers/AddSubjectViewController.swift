import UIKit

class AddSubjectViewController: UIViewController {

    var onSubjectAdded: ((String) -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add New Subject"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let subjectNameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Enter subject name"
        textField.font = .systemFont(ofSize: 16)
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.setPadding(left: 10, right: 10)
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppTheme.primary
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(saveSubject), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupUI()
//        setupTapGesture()
    }
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subjectNameTextField, saveButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            subjectNameTextField.heightAnchor.constraint(equalToConstant: 44),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func saveSubject() {
        guard let subjectName = subjectNameTextField.text, !subjectName.isEmpty else {
            return
        }
        onSubjectAdded?(subjectName)
        dismiss(animated: true, completion: nil)
    }
}

// UITextField Padding Extension
extension UITextField {
    func setPadding(left: CGFloat, right: CGFloat) {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: frame.height))
        self.leftView = leftView
        self.leftViewMode = .always
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: frame.height))
        self.rightView = rightView
        self.rightViewMode = .always
    }
}

