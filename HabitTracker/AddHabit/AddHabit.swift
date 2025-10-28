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
    @State private var selectedColor: Color = .red
    
    var body: some View {
        NavigationStack {
            
            Form{
                
                
                Section{
                    TextField("Enter Habit Name", text: $habitName)
                        .focused($nameFieldIsFocused)
                    
                }
                
                //                Section{
                //                    Picker("Frequency", selection: $habitFrequency){
                //                        ForEach(HabitFrequency.allCases){ frequency in
                //                            Text(frequency.rawValue)
                //                        }
                //                    }
                //                }
                //                .frame(height: 35)
                //
                Section {
                    Picker("Number of Days", selection: $noOfDays) {
                        ForEach(1...7, id: \.self) { i in
                            Text("\(i) days a week")
                        }
                    }
                }
                
                
                Section{
                    Toggle("Remind me", isOn: $isNotify)
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
                    //                        .listRowBackground(Color.clear)
                }
                
            }
            .listSectionSpacing(10)
            
            .onAppear{
                nameFieldIsFocused = true
            }
            
            .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button(action: {
                        dismiss()
                    }){
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .principal){
                    Text("Create Habit")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button("Save"){
                        if let colorData = selectedColor.toData() {
                            vibrate(style: .light)
                            viewModel.addHabit(name: habitName,
                                               priorityColor: colorData as NSObject,
                                               frequency: habitFrequency.rawValue,
                                               note: habitNote, noOfDays: noOfDays, isNotify: isNotify) {
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
