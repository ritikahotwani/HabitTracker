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
    
    var body: some View {
        NavigationStack {
            
            Form{
                
                
                Section{
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
                
                
                Section{
                    Toggle("Remind me", isOn: $isNotify)
                        .tint(AppGradient.purple)
                }
                
                Section {
                    HStack {
                        Text("Icon")
                            .foregroundStyle(.primary)

                        Spacer()

                        EmojiTextField(text: $habitIcon)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.15))
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
            
            .navigationBarBackButtonHidden(true)
            .navigationTitle("Create Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
//                ToolbarItem(placement: .topBarLeading){
//                    Button(action: {
//                        dismiss()
//                    }){
//                        Image(systemName: "chevron.left")
//                            .foregroundColor(.black)
//                    }
//                }
//                ToolbarItem(placement: .principal){
//                    Text("Create Habit")
//                        .font(.headline)
//                }
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
        }
    }
}


#Preview {
    AddHabit()
}
