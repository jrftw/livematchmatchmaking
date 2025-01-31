//
//  LoadingView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


import SwiftUI
import FirebaseAuth

struct LoadingView: View {
    @State private var isLoggedIn = false
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else {
                if isLoggedIn {
                    MainMenuView()
                } else {
                    LoginView()
                }
            }
        }
        .onAppear {
            checkAuthStatus()
        }
    }

    func checkAuthStatus() {
        if Auth.auth().currentUser != nil {
            isLoggedIn = true
        }
        isLoading = false
    }
}
