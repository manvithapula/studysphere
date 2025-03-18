import UIKit
import AVFoundation

class SummaryViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var summaryTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: fontSize, weight: .regular)
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.layer.cornerRadius = 16
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOpacity = 0.05
        textView.layer.shadowRadius = 5
        textView.layer.shadowOffset = CGSize(width: 0, height: 2)
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = true
        textView.delegate = self
        return textView
    }()
    
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    private var fontSize: CGFloat = 16
    private var isPlayingAudio: Bool = false
    private var synthesizer = AVSpeechSynthesizer()
    var topic: Topics?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureSynthesizer()
        loadContent()
        hideTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
    }
    
    // MARK: - Setup
    private func hideTabBar() {
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGray6
        
        view.addSubview(headingLabel)
        view.addSubview(summaryTextView)
        view.addSubview(buttonStack)
        
        let buttons = [
            createButton(imageName: "doc.on.doc", action: #selector(copyText)),
            createButton(imageName: "square.and.arrow.up", action: #selector(shareText)),
            createButton(imageName: "play.circle", action: #selector(toggleAudioPlayback)),
            createButton(imageName: "textformat.size", action: #selector(toggleFontSize))
        ]
        
        buttons.forEach { buttonStack.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            summaryTextView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 16),
            summaryTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            summaryTextView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -20),
            
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func createButton(imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        button.tintColor = AppTheme.primary
        button.backgroundColor = AppTheme.primary.withAlphaComponent(0.1)
        button.layer.cornerRadius = 22
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func showToast(message: String) {
        let toast = UILabel()
        toast.backgroundColor = AppTheme.primary
        toast.textColor = .white
        toast.textAlignment = .center
        toast.font = .systemFont(ofSize: 14, weight: .medium)
        toast.text = "  \(message)  "
        toast.alpha = 0
        toast.layer.cornerRadius = 16
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -20),
            toast.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40),
            toast.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseOut, animations: {
                toast.alpha = 0
            }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
    
    private func loadContent() {
        headingLabel.text = topic?.title ?? "Summary"
        Task {
            let alldata = try await summaryDb.findAll(where: ["topic": topic?.id ?? 0])
            if let summary = alldata.first {
                summaryTextView.text = summary.data
            } else {
                summaryTextView.text = "No summary available"
            }
        }
    }
    
    private func configureSynthesizer() {
        synthesizer.delegate = self
    }
    
    // MARK: - Actions
    @objc private func copyText() {
        UIPasteboard.general.string = summaryTextView.text
        showToast(message: "Text copied to clipboard")
    }
    
    @objc private func shareText() {
        let activityVC = UIActivityViewController(activityItems: [summaryTextView.text ?? ""], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        present(activityVC, animated: true)
    }
    
    @objc private func toggleAudioPlayback() {
        if isPlayingAudio {
            synthesizer.stopSpeaking(at: .immediate)
            isPlayingAudio = false
        } else {
            let utterance = AVSpeechUtterance(string: summaryTextView.text ?? "")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            synthesizer.speak(utterance)
            isPlayingAudio = true
        }
        
        let imageName = isPlayingAudio ? "pause.circle" : "play.circle"
        let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .medium)
        (buttonStack.arrangedSubviews[2] as? UIButton)?.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    @objc private func toggleFontSize() {
        let sizes: [CGFloat] = [14, 16, 18, 20, 22]
        let currentIndex = sizes.firstIndex(of: fontSize) ?? 1
        fontSize = sizes[(currentIndex + 1) % sizes.count]
        summaryTextView.font = .systemFont(ofSize: fontSize, weight: .regular)
    }
}

// MARK: - UITextViewDelegate
extension SummaryViewController: UITextViewDelegate {
    // Empty implementation - removed progress tracking
}

// MARK: - AVSpeechSynthesizerDelegate
extension SummaryViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isPlayingAudio = false
        let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .medium)
        (buttonStack.arrangedSubviews[2] as? UIButton)?.setImage(UIImage(systemName: "play.circle", withConfiguration: config), for: .normal)
    }
}
