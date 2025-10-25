//
//  EditHabitView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 25/10/25.
//

import SwiftUI

struct EditHabitView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @ObservedObject var habit: Habit
    
    @State private var habitName: String = ""
    @State private var habitNote: String = ""
    @State private var isNotify: Bool = true
    @FocusState private var nameFieldIsFocused: Bool
    @State private var habitFrequency: HabitFrequency = .Daily
    @State private var noOfDays: Int = 7
    @State private var selectedColor: Color = .red
    
    // MARK: - Body
    var body: some View {
        NavigationStack{
        Form {
            Section {
                TextField("Enter Habit Name", text: $habitName)
                    .focused($nameFieldIsFocused)
            }
            
            Section {
                Picker("Number of Days", selection: $noOfDays) {
                    ForEach(1...7, id: \.self) { i in
                        Text("\(i) days a week")
                    }
                }
            }
            
            Section {
                Toggle("Remind me", isOn: $isNotify)
            }
            
            Section {
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
            
            Section {
                ColorPickerView(selectedColor: $selectedColor)
            }
        }
        .listSectionSpacing(10)
        .onAppear(perform: populateExistingData)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Edit Habit")
                    .font(.headline)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(habitName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
    }
    
    // MARK: - Methods
    
    private func populateExistingData() {
        habitName = habit.name ?? ""
        habitNote = habit.note ?? ""
        isNotify = habit.isNotify?.boolValue ?? true
        noOfDays = habit.noOfDays?.intValue ?? 7
        habitFrequency = HabitFrequency(rawValue: habit.frequency ?? "Daily") ?? .Daily
        
        // Convert stored color (NSObject) back to SwiftUI Color
        if let colorData = habit.priorityColor as? Data,
           let color = Color.fromData(colorData) {
            selectedColor = color
        }
    }
    
    private func saveChanges() {
        if let colorData = selectedColor.toData() {
            habit.name = habitName
            habit.note = habitNote
            habit.isNotify = NSNumber(value: isNotify)
            habit.noOfDays = NSNumber(value: noOfDays)
            habit.priorityColor = colorData as NSObject
            habit.frequency = habitFrequency.rawValue
            
            viewModel.saveContext()
            vibrate(style: .light)
            dismiss()
        } else {
            print("Error converting color to data")
        }
    }
}
