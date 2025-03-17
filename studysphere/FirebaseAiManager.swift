//
//  FirebaseAiManager.swift
//  studysphere
//
//  Created by dark on 12/03/25.
//

import Foundation
import FirebaseCore
import FirebaseVertexAI
import FirebaseStorage
class FirebaseAiManager {
    static let shared = FirebaseAiManager()
    let modelName = "gemini-2.0-flash"

    private func getFileUri(document: URL, selectedSubject: String) async
        -> String?
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
            let documentObject = FileMetadata(
                id: "", title: document.lastPathComponent,
                documentUrl: downloadURL.absoluteString,
                subjectId: selectedSubject, createdAt: Timestamp(),
                updatedAt: Timestamp())
            var temp = documentObject
            let _ = metadataDb.create(&temp)

            print("File uploaded successfully: \(downloadURL)")
            let storage = Storage.storage()
            let storageRef = storage.reference(withPath: toPath)
            let bucket = storageRef.bucket
            let fullPath = storageRef.fullPath
            let storageURL = "gs://\(bucket)/\(fullPath)"
            return storageURL
        } catch {
            return nil
        }
    }
    private func getResponse(model: GenerativeModel, content: ModelContent)
        async -> GenerateContentResponse?
    {
        do {
            let response = try await model.generateContent([content])
            return response
        } catch {
            return nil
        }
    }
    private func getModel(jsonSchema: Schema) -> GenerativeModel {
        let config = GenerationConfig(
            responseMIMEType: "application/json",
            responseSchema: jsonSchema

        )
        let generativeModel = VertexAI.vertexAI().generativeModel(
            modelName: modelName,
            generationConfig: config
        )
        return generativeModel
    }
    func createSummary(topic: String, document: Any, selectedSubject: String)
        async -> Summary?
    {

        do {
            let jsonSchema = Schema.object(
                properties: [
                    "response": Schema.object(
                        properties: [
                            "data": Schema.object(
                                properties: [
                                    "summary": .string()
                                ]
                            )
                        ]
                    )
                ]
            )
            var fileURI:String?
            let generativeModel = getModel(jsonSchema: jsonSchema)
            if let document = document as? URL{
                    fileURI = await getFileUri(
                        document: document, selectedSubject: selectedSubject)
            }
            else if let document = document as? String{
                fileURI = document
            }
            else{
                return nil
            }
            if(fileURI == nil){
                return nil
            }
            let prompt = """
                Create Summary for this PDF document.
                Focus on key concepts and important details from the content.
                do not add markup.
                make it atlest 200 words.
                Directly start from main content dont give this pdf contains 
                """

            let content = ModelContent(
                role: "user",
                parts: [
                    TextPart(prompt),
                    FileDataPart(uri: fileURI!, mimeType: "application/pdf"),
                ])

            let respons = await getResponse(
                model: generativeModel, content: content)
            print(respons as Any)
            if let jsonData = respons?.text?.data(using: .utf8),
                let json = try? JSONSerialization.jsonObject(with: jsonData)
                    as? [String: Any],
                let responseData = json["response"] as? [String: Any],
                let data = responseData["data"] as? [String: Any],
                let summaryText = data["summary"] as? String
            {

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
    }
    func createFlashcards(
        topic: String, document: Any, selectedSubject: String
    ) async -> [Flashcard] {
        let jsonSchema = Schema.object(
            properties: [
                "response": Schema.object(
                    properties: [
                        "data": Schema.array(
                            items: .object(
                                properties: [
                                    "question": .string(),
                                    "answer": .string(),
                                ]
                            )
                        )
                    ]
                )
            ]
        )
        do {
            let generativeModel = getModel(jsonSchema: jsonSchema)
            var fileURI:String?
            if let document = document as? URL{
                    fileURI = await getFileUri(
                        document: document, selectedSubject: selectedSubject)
            }
            else if let document = document as? String{
                fileURI = document
            }
            else{
                return []
            }
            if(fileURI == nil){
                return []
            }
            let prompt = """
                Create flashcards from this PDF document.
                Focus on key concepts and important details from the content.
                Please provide 7 question-answer pairs.
                """

            let content = ModelContent(
                role: "user",
                parts: [
                    TextPart(prompt),
                    FileDataPart(
                        uri: fileURI!,
                        mimeType:
                            "application/pdf"),
                ])

            let respons = await getResponse(
                model: generativeModel, content: content)
            print(respons as Any)
            if let jsonData = respons?.text?.data(using: .utf8),
                let json = try? JSONSerialization.jsonObject(with: jsonData)
                    as? [String: Any],
                let responseData = json["response"] as? [String: Any],
                let cards = responseData["data"] as? [[String: String]]
            {
                print(cards)
                var flashcards: [Flashcard] = []
                for cardData in cards {
                    if let question = cardData["question"],
                        let answer = cardData["answer"]
                    {
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
        }
    }
    func createQuiz(
        topic: String, document: Any, selectedSubject: String
    ) async -> [Questions] {
        let jsonSchema = Schema.object(
            properties: [
                "response": Schema.object(
                    properties: [
                        "data": Schema.array(
                            items: .object(
                                properties: [
                                    "question": .string(),
                                    "option1": .string(),
                                    "option2": .string(),
                                    "option3": .string(),
                                    "option4": .string(),
                                    "correctOption": .string(),
                                ]
                            )
                        )
                    ]
                )
            ]
        )
        do {
            var fileURI:String?
            let generativeModel = getModel(jsonSchema: jsonSchema)
            if let document = document as? URL{
                    fileURI = await getFileUri(
                        document: document, selectedSubject: selectedSubject)
            }
            else if let document = document as? String{
                fileURI = document
            }
            else{
                return []
            }
            if(fileURI == nil){
                return []
            }
            let prompt = """
                Create Questions from this PDF document.
                Focus on key concepts and important details from the content.
                make sure the answers are small as possible and fit in one line.
                one of the option should be the correct answer and randomize this option
                Please provide at least 5 questions
                """

            let content = ModelContent(
                role: "user",
                parts: [
                    TextPart(prompt),
                    FileDataPart(uri: fileURI!, mimeType: "application/pdf"),
                ])

            // Generate content using the model
            let respons = await getResponse(
                model: generativeModel, content: content)
            print(respons as Any)
            // Parse the response and create flashcards
            if let jsonData = respons?.text?.data(using: .utf8),
                let json = try? JSONSerialization.jsonObject(with: jsonData)
                    as? [String: Any],
                let responseData = json["response"] as? [String: Any],
                let cards = responseData["data"] as? [[String: String]]
            {

                var questions: [Questions] = []
                var i = 1
                for cardData in cards {
                    print(cardData)
                    if let question = cardData["question"],
                        let answer = cardData["correctOption"],
                        let a = cardData["option1"],
                        let b = cardData["option2"],
                        let c = cardData["option3"],
                        let d = cardData["option4"]
                    {
                        var question1 = Questions(
                            id: "",
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
    }
}
