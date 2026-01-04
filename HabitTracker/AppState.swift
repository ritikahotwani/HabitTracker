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

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        authListener = Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                if user == nil {
                    self.sessionMessage = "Your session has expired. Please log in again."
                    self.isLoggedIn = false
                } else {
                    self.isLoggedIn = true
                }
            }
        }
    }

    deinit {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
