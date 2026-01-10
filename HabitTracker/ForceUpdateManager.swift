//
//  ForceUpdateManager.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 08/01/26.
//

import Foundation
import FirebaseRemoteConfig

class ForceUpdateManager: ObservableObject {
    @Published var isUpdateRequired: Bool = false
    
    // Key used in Firebase Console
    private let kMinVersion = "ios_min_version"
    
    init() {
        fetchRemoteConfig()
    }
    
    func fetchRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // For dev; use higher for prod
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch { [weak self] status, error in
            if status == .success {
                remoteConfig.activate { _, _ in
                    self?.checkVersion()
                }
            } else {
                print("Config fetch failed: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    private func checkVersion() {
        let minVersion = RemoteConfig.remoteConfig().configValue(forKey: kMinVersion).stringValue ?? "1.0.0"
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        DispatchQueue.main.async {
            self.isUpdateRequired = self.compareVersions(current: currentVersion, min: minVersion)
        }
    }
    
    /// Returns true if current < min
    private func compareVersions(current: String, min: String) -> Bool {
        // If min version string is empty/invalid, assume no update required
        if min.isEmpty { return false }
        
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }
        let minComponents = min.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(currentComponents.count, minComponents.count)
        
        for i in 0..<maxLength {
            let v1 = i < currentComponents.count ? currentComponents[i] : 0
            let v2 = i < minComponents.count ? minComponents[i] : 0
            
            if v1 < v2 {
                return true
            } else if v1 > v2 {
                return false
            }
        }
        
        return false
    }
}
