//
//  FeatureRequestView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 28/11/25.
//

import SwiftUI
import MessageUI

struct FeatureRequestView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var showMailSheet = false
    @State private var showMailError = false
    
    var body: some View {
        Form {
            Section(header: Text("Feature Title")) {
                TextField("e.g. Add weekly summary screen", text: $title)
            }
            
            Section(header: Text("Description")) {
                TextEditor(text: $description)
                    .frame(minHeight: 120)
            }
            
            Section {
                Button("Send Feature Request") {
                    if MFMailComposeViewController.canSendMail() {
                        showMailSheet = true
                    } else {
                        showMailError = true
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Request a Feature")
        .sheet(isPresented: $showMailSheet) {
            MailView(
                subject: "Feature Request: \(title)",
                body: description,
                toEmail: "ritikahotwani24@gmail.com" // ← replace
            )
        }
        .alert("Mail services are not available.", isPresented: $showMailError) {
            Button("OK", role: .cancel) {}
        }
    }
}


#Preview {
    FeatureRequestView()
}
struct MailView: UIViewControllerRepresentable {
    var subject: String
    var body: String
    var toEmail: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        
        vc.setToRecipients([toEmail])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            controller.dismiss(animated: true)
        }
    }
}
