//
//  SignInWithAppleView.swift
//  Swipy
//
//  Created by Vianney Dubosc on 07/06/2025.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import CryptoKit

struct SignInWithAppleView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentNonce: String?

    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: configureRequest,
            onCompletion: handleAuthorization
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 45)
        .frame(maxWidth: 375)
        .padding()
    }

    private func configureRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    private func handleAuthorization(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            guard
                let appleID = authResults.credential as? ASAuthorizationAppleIDCredential,
                let token = appleID.identityToken,
                let tokenString = String(data: token, encoding: .utf8),
                let nonce = currentNonce
            else {
                print("❌ Problème lors de la récupération du token Apple")
                return
            }

            let credential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: tokenString,
                rawNonce: nonce
            )
            print("🍏 Apple fullName:", appleID.fullName?.givenName ?? "nil")
            print("🍏 Apple email:", appleID.email ?? "nil")
            authViewModel.signIn(with: credential, fullName: appleID.fullName)

        case .failure(let error):
            print("❌ Autorisation Apple échouée :", error.localizedDescription)
        }
    }

    // Génère une chaîne aléatoire sécurisée
    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length

        while remaining > 0 {
            var random: UInt8 = 0
            _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if Int(random) < charset.count {
                result.append(charset[Int(random)])
                remaining -= 1
            }
        }
        return result
    }

    // SHA256 utilitaire
    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
