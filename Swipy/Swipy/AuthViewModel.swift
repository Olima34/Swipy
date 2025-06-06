//
//  AuthViewModel.swift
//  Swipy
//
//  Created by Vianney Dubosc on 07/06/2025.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var firstName: String?
    @Published var isSignedIn = false

    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.firstName   = user?.displayName
                self?.isSignedIn  = (user != nil)
            }
        }
    }

    func signIn(with credential: OAuthCredential, fullName: PersonNameComponents?) {
        Auth.auth().signIn(with: credential) { result, error in
            print("🔥 signIn completion called. error:", error as Any, "user:", result?.user as Any)
            guard error == nil, let user = result?.user else { return }

            // 1) Déterminer un prénom : appleName > displayName déjà existant > préfixe email > “Utilisateur”
            let name: String = {
                if let given = fullName?.givenName { return given }
                if let existing = user.displayName { return existing }
                if let email = user.email?.components(separatedBy: "@").first { return email }
                return "Utilisateur"
            }()

            // 2) Mettre à jour le displayName dans Firebase pour les prochaines connexions
            let change = user.createProfileChangeRequest()
            change.displayName = name
            change.commitChanges { _ in
                DispatchQueue.main.async {
                    self.firstName = name
                }
            }
        }
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // Allow user to sign out and reset view state
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.firstName = nil
                self.isSignedIn = false
            }
        } catch {
            print("❌ Error signing out:", error)
        }
    }
}
