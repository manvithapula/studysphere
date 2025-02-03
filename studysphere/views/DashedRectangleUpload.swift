//
//  DashedRectangleUpload.swift
//  Studysphere2
//
//  Created by Dev on 05/11/24.
//
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import PDFKit


protocol PDFProcessingDelegate: AnyObject {
    func processingCompleted(result: String)
    func processingFailed(error: Error)
}

class DashedRectangleUpload: UIView, UIDocumentPickerDelegate {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var dashWidth: CGFloat = 2
    @IBInspectable var dashColor: UIColor = .black
    @IBInspectable var dashLength: CGFloat = 10
    @IBInspectable var betweenDashesSpace: CGFloat = 15
    
    private var dashBorder: CAShapeLayer?
    private weak var parentViewController: UIViewController?
    weak var delegate: PDFProcessingDelegate?
    var document:URL? = nil

    
    // MARK: - Gemini Configuration
    private struct GeminiConfig {
        static let apiKey = "Api_key"
        
        static let apiEndpoint = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent"
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.03)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let innerContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let uploadIcon: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        imageView.image = UIImage(systemName: "arrow.up.doc.fill", withConfiguration: config)
        imageView.tintColor = .systemBlue.withAlphaComponent(0.8)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let uploadLabel: UILabel = {
        let label = UILabel()
        label.text = "Upload PDF"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to browse files"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var hoverView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        self.isUserInteractionEnabled = true
        backgroundColor = .clear
        
        // Add views
        addSubview(containerView)
        containerView.addSubview(innerContentView)
        innerContentView.addSubview(uploadIcon)
        innerContentView.addSubview(uploadLabel)
        innerContentView.addSubview(subtitleLabel)
        
        // Setup dashed border
        dashWidth = 5.5
        dashColor = UIColor.systemBlue.withAlphaComponent(0.2)
        dashLength = 6
        betweenDashesSpace = 4
        cornerRadius = 16
        
        // Add gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.03).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.05).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = bounds
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            innerContentView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            innerContentView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            uploadIcon.centerXAnchor.constraint(equalTo: innerContentView.centerXAnchor),
            uploadIcon.topAnchor.constraint(equalTo: innerContentView.topAnchor),
            
            uploadLabel.centerXAnchor.constraint(equalTo: innerContentView.centerXAnchor),
            uploadLabel.topAnchor.constraint(equalTo: uploadIcon.bottomAnchor, constant: 12),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: innerContentView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: uploadLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor)
        ])
        
        // Add tap gesture with visual feedback
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.addGestureRecognizer(tapGesture)
        
        // Add shadow
        layer.shadowColor = UIColor.systemBlue.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        
        // Add hover effect
        addHoverEffect()
    }
    
    private func addHoverEffect() {
        let hoverView = UIView()
        hoverView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        hoverView.isUserInteractionEnabled = false
        hoverView.alpha = 0
        hoverView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(hoverView)
        
        NSLayoutConstraint.activate([
            hoverView.topAnchor.constraint(equalTo: containerView.topAnchor),
            hoverView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hoverView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hoverView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Store hover view for animations
        self.hoverView = hoverView
        
        // Add gesture recognizer for touch handling
        let touchDownGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTouch(_:)))
        touchDownGesture.minimumPressDuration = 0
        touchDownGesture.cancelsTouchesInView = false
        addGestureRecognizer(touchDownGesture)
    }
    
    @objc private func handleTouch(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            UIView.animate(withDuration: 0.2) {
                self.hoverView?.alpha = 1
                self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }
        case .ended:
            UIView.animate(withDuration: 0.2) {
                self.hoverView?.alpha = 0
                self.transform = .identity
            } completion: { _ in
                self.presentDocumentPicker()
            }
        case .cancelled:
            UIView.animate(withDuration: 0.2) {
                self.hoverView?.alpha = 0
                self.transform = .identity
            }
        default:
            break
        }
    }
    
    func setup(in viewController: UIViewController) {
        self.parentViewController = viewController
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient frame
        if let gradientLayer = containerView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = containerView.bounds
        }
        
        // Update dashed border
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = containerView.bounds
        dashBorder.fillColor = nil
        dashBorder.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadius).cgPath
        containerView.layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
        
        // Update corner radius
        containerView.layer.cornerRadius = cornerRadius
        containerView.clipsToBounds = true
    }
    
    @objc private func viewTapped() {
        presentDocumentPicker()
    }
    
    @IBAction func tappp(_ sender: Any) {
        presentDocumentPicker()
    }
    
    
    // MARK: - Document Picker
    private func presentDocumentPicker() {
        guard let parentVC = parentViewController else { return }
        
        // Define supported file types (PDF)
        let supportedTypes: [UTType] = [.pdf,.text,.png,.jpeg]
        
        // Create and configure document picker
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        // Present the document picker
        parentVC.present(documentPicker, animated: true)
    }
    
   
    private func extractTextFromPDF(url: URL) -> String? {
        guard let pdfDocument = PDFDocument(url: url) else { return nil }
        
        var extractedText = ""
        for pageIndex in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: pageIndex),
               let pageText = page.string {
                extractedText += pageText + "\n"
            }
        }
        return extractedText
    }
    
    // MARK: - Gemini API Integration
    private func processFileWithGemini(pdfText: String) {
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": pdfText]
                    ]
                ]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            delegate?.processingFailed(error: NSError(domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to prepare request"]))
            return
        }
        
        guard var urlComponents = URLComponents(string: GeminiConfig.apiEndpoint) else { return }
        urlComponents.queryItems = [URLQueryItem(name: "key", value: GeminiConfig.apiKey)]
        
        guard let url = urlComponents.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.delegate?.processingFailed(error: error)
                }
                return
            }
            
            guard let data = data,
                  let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = result["candidates"] as? [[String: Any]],
                  let firstCandidate = candidates.first,
                  let content = firstCandidate["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let firstPart = parts.first,
                  let text = firstPart["text"] as? String else {
                DispatchQueue.main.async {
                    self?.delegate?.processingFailed(error: NSError(domain: "", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to parse API response"]))
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.delegate?.processingCompleted(result: text)
            }
        }
        task.resume()
    }
    
    // MARK: - UIDocumentPickerDelegate
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileUrl = urls.first else { return }
        
        // Update UI to show selected file
        let fileName = selectedFileUrl.lastPathComponent
        uploadLabel.text = fileName
        subtitleLabel.text = "PDF file selected"
        
        // Update icon to show selected state
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        uploadIcon.image = UIImage(systemName: "doc.fill.badge.checkmark", withConfiguration: config)
        uploadIcon.tintColor = .systemGreen
        
        // Add animation for success state
        UIView.animate(withDuration: 0.3) {
            self.containerView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.05)
            self.dashColor = UIColor.systemGreen.withAlphaComponent(0.3)
            self.setNeedsLayout()
        }
        
        // Optional: Add a remove button
        addRemoveButton()
        
        guard let selectedFileURL = urls.first else {
            return
        }
        document = selectedFileURL
    }
    
    private func addRemoveButton() {
        let removeButton = UIButton(type: .system)
        removeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        removeButton.tintColor = .systemGray3
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            removeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
        
        removeButton.addTarget(self, action: #selector(resetUploadView), for: .touchUpInside)
    }
    
    @objc private func resetUploadView() {
        // Reset to initial state
        uploadLabel.text = "Upload PDF"
        subtitleLabel.text = "Tap to browse files"
        
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        uploadIcon.image = UIImage(systemName: "arrow.up.doc.fill", withConfiguration: config)
        uploadIcon.tintColor = .systemBlue.withAlphaComponent(0.8)
        
        // Remove any remove button
        containerView.subviews.forEach { view in
            if let button = view as? UIButton {
                button.removeFromSuperview()
            }
        }
        
        // Reset colors
        UIView.animate(withDuration: 0.3) {
            self.containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.03)
            self.dashColor = UIColor.systemBlue.withAlphaComponent(0.2)
            self.setNeedsLayout()
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Reset any loading states if needed
    }
}
