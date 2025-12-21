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
    @State private var isBlocking = false
    var composedMailBody: String {
        """
        Feature Description:
        \(description)

        -----------------------

        Is this blocking progress?
        \(isBlocking ? "Yes" : "No")
        """
    }

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
                Toggle("This is blocking my progress", isOn: $isBlocking)
                    .tint(AppGradient.purple)
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
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMailSheet) {
            MailView(
                subject: "Feature Request: \(title)",
                body: composedMailBody,
                toEmail: "ritikahotwani24@gmail.com"
            ) { result in
                if result == .sent {
                    title = ""
                    description = ""
                    isBlocking = false
                }
            }
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
    var onResult: (MFMailComposeResult) -> Void
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
            parent.onResult(result)
        }
    }
}
