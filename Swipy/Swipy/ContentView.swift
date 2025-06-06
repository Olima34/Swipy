//
//  ContentView.swift
//  Swipy
//
//  Created by Vianney Dubosc on 06/06/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isSignedIn {
                WelcomeView(firstName: authViewModel.firstName ?? "")
            } else {
                VStack(spacing: 24) {
                    Text("Bienvenue sur Swipy 👋")
                        .font(.title)
                    SignInWithAppleView()
                }
                .padding()
            }
        }
    }
}

struct WelcomeView: View {
    let firstName: String
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            Text("Bienvenue sur Swipy \(firstName) 🎉")
                .font(.largeTitle)
                .padding()
            Button("Déconnexion") {
                authViewModel.signOut()
            }
            .padding()
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
