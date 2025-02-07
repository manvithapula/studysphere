//
//  SummariserViewController.swift
//  studysphere
//
//  Created by admin64 on 05/11/24.
//
import UIKit
import AVFoundation
import FirebaseCore

class SummariserViewController: UIViewController, UITextViewDelegate, AVSpeechSynthesizerDelegate {
    
    // MARK: - UI Components
    private var headingLabel: UILabel!
    private var summaryTextView: UITextView!
    private var buttonContainer: UIView!
    private var progressContainer: UIView!
    private var progressBar: UIProgressView!
    private var progressLabel: UILabel!
    private var copyButton: UIButton!
    private var shareButton: UIButton!
    private var audioButton: UIButton!
    private var fontSizeButton: UIButton!
    
    // MARK: - Properties
    var heading: String = "English Summary"
    var summaryText: String = ""
    var topic: Topics?
    var completionHandler: ((Topics) -> Void)?
    
    private var fontSize: CGFloat = 16
    private var isPlayingAudio: Bool = false
    private let synthesizer = AVSpeechSynthesizer()
    
    var progress: Float = 0.0 {
        didSet {
            updateProgress()
            checkCompletion()
        }
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        heading = topic?.title ?? "Summary"
        Task{
            let allItems = try await summaryDb.findAll(where: ["topic": topic?.id ?? 0])
            if let summary = allItems.first{
                summaryText = summary.data
            } else {
                summaryText = "No summary available"
            }
            
            synthesizer.delegate = self
            setupView()
            setupProgressView()
            setupActionButtons()
            summaryTextView.delegate = self
        }
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(hex: "1A1A33")
        
        // Heading setup
        headingLabel = UILabel()
        headingLabel.text = heading
        headingLabel.font = .systemFont(ofSize: 28, weight: .bold)
        headingLabel.textColor = .white
        headingLabel.textAlignment = .left
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headingLabel)
        
        // Summary text view
        summaryTextView = UITextView()
        summaryTextView.text = summaryText
        summaryTextView.font = .systemFont(ofSize: fontSize, weight: .regular)
        summaryTextView.backgroundColor = UIColor(hex: "2A2A4A")
        summaryTextView.textColor = .white
        summaryTextView.layer.cornerRadius = 12
        summaryTextView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        summaryTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryTextView)
        
        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            summaryTextView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 16),
            summaryTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            summaryTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120)
        ])
    }
    
    private func setupProgressView() {
        progressContainer = UIView()
        progressContainer.backgroundColor = UIColor(hex: "2A2A4A")
        progressContainer.layer.cornerRadius = 8
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressContainer)
        
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progress = progress
        progressBar.progressTintColor = UIColor.systemBlue
        progressBar.trackTintColor = UIColor(hex: "3A3A5A")
        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.addSubview(progressBar)
        
        progressLabel = UILabel()
        progressLabel.text = "\(Int(progress * 100))%"
        progressLabel.font = .systemFont(ofSize: 14, weight: .medium)
        progressLabel.textColor = .white
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.addSubview(progressLabel)
        
        NSLayoutConstraint.activate([
            progressContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            progressContainer.heightAnchor.constraint(equalToConstant: 40),
            
            progressBar.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor, constant: 12),
            progressBar.trailingAnchor.constraint(equalTo: progressLabel.leadingAnchor, constant: -12),
            progressBar.centerYAnchor.constraint(equalTo: progressContainer.centerYAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 4),
            
            progressLabel.trailingAnchor.constraint(equalTo: progressContainer.trailingAnchor, constant: -12),
            progressLabel.centerYAnchor.constraint(equalTo: progressContainer.centerYAnchor),
            progressLabel.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupActionButtons() {
        buttonContainer = UIView()
        buttonContainer.backgroundColor = UIColor(hex: "2A2A4A")
        buttonContainer.layer.cornerRadius = 12
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonContainer)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addSubview(stackView)
        
        copyButton = createActionButton(imageName: "doc.on.doc", action: #selector(copyText))
        shareButton = createActionButton(imageName: "square.and.arrow.up", action: #selector(shareText))
        audioButton = createActionButton(imageName: "play.circle", action: #selector(toggleAudioPlayback))
        fontSizeButton = createActionButton(imageName: "textformat.size", action: #selector(toggleFontSize))
        
        [copyButton, shareButton, audioButton, fontSizeButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            buttonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonContainer.bottomAnchor.constraint(equalTo: progressContainer.topAnchor, constant: -16),
            buttonContainer.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor)
        ])
    }
    
    private func createActionButton(imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        button.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // MARK: - Progress and Scroll Handling
    private func updateProgress() {
        progressBar.progress = progress
        progressLabel.text = "\(Int(progress * 100))%"
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.frame.size.height
        let offsetY = scrollView.contentOffset.y
        
        if contentHeight > visibleHeight {
            progress = min(max(Float(offsetY / (contentHeight - visibleHeight)), 0.0), 1.0)
        } else {
            progress = 1.0
        }
    }
    
    private func checkCompletion() {
        if progress >= 1.0 {
            topic?.completed = Timestamp()
            Task{
                var newTopic = topic!
                try await topicsDb.update(&newTopic)
                if let completedTopic = topic {
                    completionHandler?(completedTopic)
                }
            }
        }
    }
    
    // MARK: - Button Actions
    @objc private func copyText() {
        UIPasteboard.general.string = summaryText
        showToast(message: "Text copied to clipboard")
    }
    
    @objc private func shareText() {
        let activityVC = UIActivityViewController(activityItems: [summaryText], applicationActivities: nil)
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
    
    @objc private func toggleAudioPlayback() {
        if isPlayingAudio {
            synthesizer.stopSpeaking(at: .immediate)
            isPlayingAudio = false
            audioButton.setImage(UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)), for: .normal)
        } else {
            let utterance = AVSpeechUtterance(string: summaryText)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.5
            synthesizer.speak(utterance)
            isPlayingAudio = true
            audioButton.setImage(UIImage(systemName: "pause.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)), for: .normal)
        }
    }
    
    @objc private func toggleFontSize() {
        let sizes: [CGFloat] = [14, 16, 18, 20, 22]
        let currentIndex = sizes.firstIndex(of: fontSize) ?? 1
        let nextIndex = (currentIndex + 1) % sizes.count
        fontSize = sizes[nextIndex]
        summaryTextView.font = .systemFont(ofSize: fontSize, weight: .regular)
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isPlayingAudio = false
        audioButton.setImage(UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)), for: .normal)
    }
    
    // MARK: - Helper Methods
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: -20),
            toastLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40),
            toastLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseInOut, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

// MARK: - UIColor Extension
extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = scanner.string.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: 1
        )
    }
}
