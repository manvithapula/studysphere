import UIKit
import AVFoundation
import FirebaseCore

class SummariserViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var headingLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 28, weight: .bold)
            label.textColor = .black // Changed to black for white background
            label.textAlignment = .left
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private lazy var summaryTextView: UITextView = {
            let textView = UITextView()
            textView.font = .systemFont(ofSize: fontSize, weight: .regular)
            textView.backgroundColor = .main
            textView.textColor = .white
            textView.layer.cornerRadius = 12
            textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
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
            stack.spacing = 20
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()
        
        private lazy var progressView: UIProgressView = {
            let progress = UIProgressView(progressViewStyle: .default)
            progress.progressTintColor = .systemOrange // Changed to system orange
            progress.trackTintColor = .systemGray5 // Light gray for white background
            progress.layer.cornerRadius = 2
            progress.clipsToBounds = true
            progress.translatesAutoresizingMaskIntoConstraints = false
            return progress
        }()
        
        private lazy var progressLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .black // Changed to black for white background
            label.textAlignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
    // MARK: - Properties
    private var fontSize: CGFloat = 16
    private var isPlayingAudio: Bool = false
    private let synthesizer = AVSpeechSynthesizer()
    private var hasCompletedReading: Bool = false
    
    var topic: Topics?
    var completionHandler: ((Topics) -> Void)?
    
    private var progress: Float = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureSynthesizer()
        loadContent()
        //setupCompleteButton()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(headingLabel)
        view.addSubview(summaryTextView)
        view.addSubview(buttonStack)
        view.addSubview(progressView)
        view.addSubview(progressLabel)
        
        let buttons = [
            createButton(imageName: "doc.on.doc", action: #selector(copyText)),
            createButton(imageName: "square.and.arrow.up", action: #selector(shareText)),
            createButton(imageName: "play.circle", action: #selector(toggleAudioPlayback)),
            createButton(imageName: "textformat.size", action: #selector(toggleFontSize))
        ]
        
        buttons.forEach { buttonStack.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            summaryTextView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 16),
            summaryTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            summaryTextView.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -20),
            
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: progressLabel.leadingAnchor, constant: -8),
            progressView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            progressLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            progressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressLabel.widthAnchor.constraint(equalToConstant: 50),
            
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 40) // Reduced from 44 to 40
        ])
    }
    
  /*  private func setupCompleteButton() {
        let completeButton = UIBarButtonItem(title: "Complete", style: .done, target: self, action: #selector(completeReading))
        navigationItem.rightBarButtonItem = completeButton
        completeButton.isEnabled = false
    } */
    
    private func loadContent() {
        headingLabel.text = topic?.title ?? "Summary"
        Task{
            let alldata = try await summaryDb.findAll(where: ["topic": topic?.id ?? 0])
            if let summary = alldata.first{
                summaryTextView.text = summary.data
            } else {
                summaryTextView.text = "No summary available"
            }
            updateProgress()
        }
    }
    
    private func configureSynthesizer() {
        synthesizer.delegate = self
    }
    

    
    private func updateProgress() {
        progressView.progress = progress
        progressLabel.text = "\(Int(progress * 100))%"
        navigationItem.rightBarButtonItem?.isEnabled = progress >= 0.99
    }
    
    // MARK: - Actions
    @objc private func completeReading() {
        guard progress >= 0.99 else { return }
        topic?.completed = Timestamp()
        Task{
                        var newTopic = topic!
                        try await topicsDb.update(&newTopic)
                        if let completedTopic = topic {
                            completionHandler?(completedTopic)
                        }
                    }
    }
    
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
    
    private func createButton(imageName: String, action: Selector) -> UIButton {
           let button = UIButton(type: .system)
           let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .medium)
           button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
           button.tintColor = .systemOrange // Changed to system orange
           button.addTarget(self, action: action, for: .touchUpInside)
           return button
       }
       
       private func setupCompleteButton() {
           let completeButton = UIBarButtonItem(title: "Complete", style: .done, target: self, action: #selector(completeReading))
           completeButton.tintColor = .systemOrange // Changed to system orange
           navigationItem.rightBarButtonItem = completeButton
           completeButton.isEnabled = false
       }
       
       private func showToast(message: String) {
           let toast = UILabel()
           toast.backgroundColor = .systemOrange // Changed to system orange
           toast.textColor = .white // White text for contrast
           toast.textAlignment = .center
           toast.font = .systemFont(ofSize: 14)
           toast.text = message
           toast.alpha = 0
           toast.layer.cornerRadius = 10
           toast.clipsToBounds = true
           toast.translatesAutoresizingMaskIntoConstraints = false
    
        
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -20),
            toast.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40),
            toast.heightAnchor.constraint(equalToConstant: 35)
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
}

// MARK: - UITextViewDelegate
extension SummariserViewController: UITextViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.frame.size.height
        let offsetY = scrollView.contentOffset.y
        let maximumOffset = contentHeight - visibleHeight
        
        if maximumOffset > 0 {
            progress = min(max(Float(offsetY / maximumOffset), 0.0), 1.0)
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension SummariserViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isPlayingAudio = false
        let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .medium)
        (buttonStack.arrangedSubviews[2] as? UIButton)?.setImage(UIImage(systemName: "play.circle", withConfiguration: config), for: .normal)
    }
}

