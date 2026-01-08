//
//  GoogleAuthHelper.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 08/01/26.
//

import Foundation
import GoogleSignIn
import FirebaseAuth
class GoogleAuthHelper {
    
    @MainActor
    static func signIn(completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            completion(.failure(NSError(domain: "GoogleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find root view controller"])))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "GoogleAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not get ID Token"])))
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)
            completion(.success(credential))
        }
    }
}

