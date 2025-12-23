//
//  EmojiTextField.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 21/12/25.
//

import SwiftUI

struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.font = UIFont.systemFont(ofSize: 32)
        textField.textAlignment = .center
        textField.placeholder = "✨"
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }


    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: EmojiTextField

        init(_ parent: EmojiTextField) {
            self.parent = parent
        }

        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {

            if let scalar = string.unicodeScalars.first,
               scalar.properties.isEmoji {
                parent.text = string
                textField.text = string
                return false
            }

            return false
        }
    }
}


#Preview {
//    EmojiTextField(text:)
}
