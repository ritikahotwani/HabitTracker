//
//  AddHabit.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 15/08/25.
//
import SwiftUI

struct AddHabit: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @State private var habitName: String = ""
    @State private var habitNote: String = ""
    @State private var isNotify: Bool = true
    @FocusState private var nameFieldIsFocused: Bool
    @State private var habitFrequency: HabitFrequency = .Daily
    @State private var noOfDays: Int = 7
    @State private var habitIcon: String = "✨"
    @State private var selectedColor: Color = .red
    @State private var showAuthAlert = false
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            
            Form{
                
                
                Section{
                    TextField("Enter habit name", text: $habitName)
                        .focused($nameFieldIsFocused)
                    
                }
                
                Section {
                    Picker("Number of days", selection: $noOfDays) {
                        ForEach(1...7, id: \.self) { i in
                            Text("\(i) days a week")
                        }
                    }
                }
                
                
                Section{
                    Toggle("Remind me", isOn: $isNotify)
                        .tint(AppGradient.purple)
                }
                
                Section {
                    HStack {
                        Text("Select a habit icon")
                            .foregroundStyle(.primary)

                        Spacer()

                        EmojiTextField(text: $habitIcon)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }


                Section{
                    ZStack(alignment: .topLeading) {
                        if habitNote.isEmpty {
                            Text("Add a note...")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
                        }
                        TextEditor(text: $habitNote)
                            .frame(minHeight: 80)
                    }
                    
                }
                
                
                Section{
                    ColorPickerView(selectedColor: $selectedColor)
                }
                
            }
            .listSectionSpacing(10)
            
            .onAppear{
                nameFieldIsFocused = true
            }
            .onChange(of: viewModel.authError) { _, newValue in
                if newValue != nil {
                    showAuthAlert = true
                }
            }

            .navigationBarBackButtonHidden(true)
            .navigationTitle("Create Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{

                ToolbarItem(placement: .topBarTrailing){
                    Button("Save"){
                        if let colorData = selectedColor.toData() {
                            vibrate(style: .light)
                            viewModel.addHabit(
                                name: habitName,
                                icon: habitIcon,
                                priorityColor: colorData as NSObject,
                                frequency: habitFrequency.rawValue,
                                note: habitNote,
                                noOfDays: noOfDays,
                                isNotify: isNotify
                            ) {
                                dismiss()
                            }

                        } else {
                            print("error converting color to data")
                        }
                    }.disabled(habitName.trimmingCharacters(in: .whitespaces).isEmpty)
                    
                    
                }
            }
        }.alert("Session Expired", isPresented: $showAuthAlert) {
            Button("OK") {
                if viewModel.signOut() {
                    appState.isLoggedIn = false
                }
            }
        } message: {
            Text(viewModel.authError ?? "")
        }

    }
}


#Preview {
    AddHabit()
}
