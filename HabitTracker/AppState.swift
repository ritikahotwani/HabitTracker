//
//  AppState.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 23/08/25.
//

import SwiftUI

import FirebaseAuth

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var sessionMessage: String?
    @Published var isSessionLoading: Bool = true

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        authListener = Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                if user == nil {
                    // Only show session expired message if we were previously logged in or it's not the initial load? 
                    // For now, keep original logic but handle loading state.
                    if self.isLoggedIn {
                         self.sessionMessage = "Your session has expired. Please log in again."
                    }
                    self.isLoggedIn = false
                } else {
                    self.isLoggedIn = true
                }
                self.isSessionLoading = false
            }
        }
    }

    deinit {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
