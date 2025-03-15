//
//  FirebaseAuth.swift
//  studysphere
//
//  Created by dark on 15/03/25.
//

import Firebase
import FirebaseAuth
import UIKit

class FirebaseAuthManager {

    // MARK: - Singleton
    static let shared = FirebaseAuthManager()
    private init() {}

    // MARK: - Properties
    var currentUser: User? {
        return Auth.auth().currentUser
    }

    var isUserLoggedIn: Bool {
        return currentUser != nil
    }

    // MARK: - Sign Up
    func signUp(
        email: String, password: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) {
            authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = authResult?.user else {
                completion(
                    .failure(
                        NSError(
                            domain: "FirebaseAuthError", code: 0,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Failed to get user"
                            ])))
                return
            }

            completion(.success(user))
        }
    }

    // MARK: - Sign In
    func signIn(
        email: String, password: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) {
            authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = authResult?.user else {
                completion(
                    .failure(
                        NSError(
                            domain: "FirebaseAuthError", code: 0,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Failed to get user"
                            ])))
                return
            }

            completion(.success(user))
        }
    }

    // MARK: - Sign In with Google
    func signInWithGoogle(
        presenting: UIViewController,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        // This method requires GoogleSignIn SDK
        // You'll need to add GoogleSignIn to your project and implement further code here
        // This is just a placeholder for the method
        completion(
            .failure(
                NSError(
                    domain: "FirebaseAuthError", code: 0,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Google Sign In not implemented"
                    ])))
    }

    // MARK: - Sign In with Apple
    func signInWithApple(completion: @escaping (Result<User, Error>) -> Void) {
        // This requires implementing ASAuthorizationControllerDelegate protocol
        // This is just a placeholder for the method
        completion(
            .failure(
                NSError(
                    domain: "FirebaseAuthError", code: 0,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Apple Sign In not implemented"
                    ])))
    }

    // MARK: - Sign Out
    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Password Reset
    func resetPassword(
        email: String, completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    // MARK: - Profile Management
    func updateProfile(
        displayName: String? = nil, photoURL: URL? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = currentUser else {
            completion(
                .failure(
                    NSError(
                        domain: "FirebaseAuthError", code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey: "No user logged in"
                        ])))
            return
        }

        let changeRequest = user.createProfileChangeRequest()

        if let displayName = displayName {
            changeRequest.displayName = displayName
        }

        if let photoURL = photoURL {
            changeRequest.photoURL = photoURL
        }

        changeRequest.commitChanges { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    // MARK: - Email Verification
    func sendEmailVerification(
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = currentUser else {
            completion(
                .failure(
                    NSError(
                        domain: "FirebaseAuthError", code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey: "No user logged in"
                        ])))
            return
        }

        user.sendEmailVerification { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    // MARK: - Change Email
    func updateEmail(
        to newEmail: String, completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = currentUser else {
            completion(
                .failure(
                    NSError(
                        domain: "FirebaseAuthError", code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey: "No user logged in"
                        ])))
            return
        }

        user.updateEmail(to: newEmail) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    // MARK: - Change Password
    func updatePassword(
        to newPassword: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = currentUser else {
            completion(
                .failure(
                    NSError(
                        domain: "FirebaseAuthError", code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey: "No user logged in"
                        ])))
            return
        }

        user.updatePassword(to: newPassword) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    // MARK: - Delete Account
    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = currentUser else {
            completion(
                .failure(
                    NSError(
                        domain: "FirebaseAuthError", code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey: "No user logged in"
                        ])))
            return
        }

        user.delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    // MARK: - Re-authenticate User
    func reauthenticate(
        email: String, password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let user = currentUser else {
            completion(
                .failure(
                    NSError(
                        domain: "FirebaseAuthError", code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey: "No user logged in"
                        ])))
            return
        }

        let credential = EmailAuthProvider.credential(
            withEmail: email, password: password)

        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
