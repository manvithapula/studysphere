//
//  DocumentManager.swift
//  studysphere
//
//  Created by dark on 20/03/25.
//

import Foundation
import FirebaseStorage

class DocumentManager{
    static let shared = DocumentManager()
    
    func upload(document:URL,metadata:FileMetadata) async
    -> FileMetadata?
    {
        guard let pdfData = try? Data(contentsOf: document) else {
            print("Error reading PDF data")
            return nil
        }
        print(pdfData)
        do {
            let toPath = "documents/\(UUID().uuidString).pdf"
            let downloadURL = try await FirebaseStorageManager.shared
                .uploadFile(
                    from: document,
                    to: toPath
                )
            var documentObject = metadata
            documentObject.title = document.lastPathComponent
            documentObject.documentUrl  = downloadURL.absoluteString
            
            let doc = metadataDb.create(&documentObject)
            let fileName = doc.id + ".pdf"
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let localFileURL = documentsDirectory.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: localFileURL.path) {
                try FileManager.default.removeItem(at: localFileURL)
            }
            try FileManager.default.copyItem(at: document, to: localFileURL)

            print("File uploaded successfully: \(downloadURL)")
            return documentObject
        } catch {
            return nil
        }
    }
    func load(metadata: FileMetadata) async -> URL? {
        let fileName = metadata.id + ".pdf"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localFileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Check if file already exists locally
        if FileManager.default.fileExists(atPath: localFileURL.path) {
            print("PDF found in cache, loading from: \(localFileURL.path)")
            return localFileURL
        } else {
            print("PDF not in cache, downloading...")
            
            guard let remoteURL = URL(string: metadata.documentUrl) else {
                print("Invalid document URL")
                return nil
            }
            
            do {
                // Create a URLSession data task using async/await
                let (downloadedURL, response) = try await URLSession.shared.download(from: remoteURL)
                
                // Check for valid response
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response status code")
                    return nil
                }
                
                try FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
                
                // If there's already a file at the destination, remove it first
                if FileManager.default.fileExists(atPath: localFileURL.path) {
                    try FileManager.default.removeItem(at: localFileURL)
                }
                
                // Move downloaded file to local storage
                try FileManager.default.copyItem(at: downloadedURL, to: localFileURL)
                print("PDF saved to cache: \(localFileURL.path)")
                
                return localFileURL
            } catch {
                print("Error downloading or saving PDF: \(error.localizedDescription)")
                return nil
            }
        }
    }
}
