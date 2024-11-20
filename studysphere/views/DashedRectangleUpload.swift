//
//  DashedRectangleUpload.swift
//  Studysphere2
//
//  Created by Dev on 05/11/24.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class DashedRectangleUpload: UIView{

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
        
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
        
        var dashBorder: CAShapeLayer?
        
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
    
    private var parentViewController: UIViewController?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
        }
        
        private func setupView() {

            self.isUserInteractionEnabled = true
            
        }
        
        func setup(in viewController: UIViewController) {
            self.parentViewController = viewController
        }
        
        @objc private func viewTapped() {
            presentDocumentPicker()
        }
        
    @IBAction func tappp(_ sender: Any) {
        presentDocumentPicker()

    }
    private func presentDocumentPicker() {
            guard let parentVC = parentViewController else { return }
            
            // Define the file types you want to support
            let supportedTypes: [UTType] = [.pdf, .plainText, .image]
            
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false // Set to true if you want multiple file selection
            
            parentVC.present(documentPicker, animated: true)
        }

}
extension DashedRectangleUpload: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileUrl = urls.first else { return }
        
        // Handle the selected file
        do {
            // Get file data
            let fileData = try Data(contentsOf: selectedFileUrl)
            
            // Get file name
            let fileName = selectedFileUrl.lastPathComponent
            
            // Get file size
            _ = fileData.count
            
            // Here you can implement your file upload logic
            uploadFile(data: fileData, fileName: fileName)
            
        } catch {
            print("Error reading file: \(error.localizedDescription)")
        }
    }
    
    private func uploadFile(data: Data, fileName: String) {
        // Implement your file upload logic here
        // For example, using URLSession to upload to a server
        
        // Example implementation:
        /*
        let url = URL(string: "YOUR_UPLOAD_URL")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create body
        var body = Data()
        
        // Add file data
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            // Handle response
        }
        task.resume()
        */
    }
}
