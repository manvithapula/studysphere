//
//  Secrets.swift
//  studysphere
//
//  Created by dark on 16/02/25.
//

// Secrets.swift

import Foundation

struct Secrets {
    static var geminiAPIKey: String? {
        guard let apiKey = Bundle.main.infoDictionary?["Api_key"] as? String else {
            print("⚠️ Gemini API Key not found in Info.plist. Please add 'GeminiAPIKey' to your Info.plist file.")
            return nil
        }
        if apiKey.isEmpty || apiKey == "YOUR_ACTUAL_API_KEY" { // Basic check for placeholder
            print("⚠️ Gemini API Key in Info.plist is empty or still placeholder. Please update it with your actual API key.")
            return nil
        }
        return apiKey
    }
}
