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

class DashedRectangleUpload: UIView {

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
    private var parentViewController: UIViewController?
    weak var delegate: PDFProcessingDelegate?
    
    // MARK: - Gemini Configuration
    private struct GeminiConfig {
        static let apiKey = "Api_key"
        
        static let apiEndpoint = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent"
    }
    
   
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    func setup(in viewController: UIViewController) {
        self.parentViewController = viewController
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
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
        let supportedTypes: [UTType] = [.text, .pdf]
        
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
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
}

// MARK: - UIDocumentPickerDelegate
extension DashedRectangleUpload: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileUrl = urls.first else { return }
        
        if selectedFileUrl.pathExtension.lowercased() == "pdf" {
            if let pdfText = extractTextFromPDF(url: selectedFileUrl) {
                processFileWithGemini(pdfText: pdfText)
            } else {
                delegate?.processingFailed(error: NSError(domain: "", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to extract PDF text"]))
            }
        } else {
            delegate?.processingFailed(error: NSError(domain: "", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Selected file is not a PDF"]))
        }
    }
}
