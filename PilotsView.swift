import SwiftUI
import SwiftData

@Model
class Pilot {
    var id: UUID
    var name: String
    var addressLine1: String
    var addressLine2: String
    var addressLine3: String
    var telephone: String
    var email: String
    
    init(name: String = "", addressLine1: String = "", addressLine2: String = "", addressLine3: String = "", telephone: String = "", email: String = "") {
        self.id = UUID()
        self.name = name
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressLine3 = addressLine3
        self.telephone = telephone
        self.email = email
    }
}

struct PilotsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pilots: [Pilot]
    @State private var isShowingAddForm = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                List {
                    ForEach(pilots) { pilot in
                        NavigationLink {
                            PilotDetailView(pilot: pilot)
                        } label: {
                            Text(pilot.name)
                                .font(.headline)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Pilots")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { isShowingAddForm = true }) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $isShowingAddForm) {
                AddPilotView(isPresented: $isShowingAddForm)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(pilots[index])
            }
        }
    }
}

struct PilotDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let pilot: Pilot
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedAddressLine1 = ""
    @State private var editedAddressLine2 = ""
    @State private var editedAddressLine3 = ""
    @State private var editedTelephone = ""
    @State private var editedEmail = ""
    
    var body: some View {
        List {
            if isEditing {
                Section(header: Text("Contact Information")) {
                    TextField("Name", text: $editedName)
                    TextField("Telephone", text: $editedTelephone)
                    TextField("Email", text: $editedEmail)
                }
                
                Section(header: Text("Address")) {
                    TextField("Address Line 1", text: $editedAddressLine1)
                    TextField("Address Line 2", text: $editedAddressLine2)
                    TextField("Address Line 3", text: $editedAddressLine3)
                }
            } else {
                Section(header: Text("Contact Information")) {
                    Text("Name: \(pilot.name)")
                    Text("Telephone: \(pilot.telephone)")
                    Text("Email: \(pilot.email)")
                }
                
                Section(header: Text("Address")) {
                    Text(pilot.addressLine1)
                    if !pilot.addressLine2.isEmpty {
                        Text(pilot.addressLine2)
                    }
                    if !pilot.addressLine3.isEmpty {
                        Text(pilot.addressLine3)
                    }
                }
            }
        }
        .navigationTitle("Pilot Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditing {
                        // Save changes
                        pilot.name = editedName
                        pilot.addressLine1 = editedAddressLine1
                        pilot.addressLine2 = editedAddressLine2
                        pilot.addressLine3 = editedAddressLine3
                        pilot.telephone = editedTelephone
                        pilot.email = editedEmail
                    } else {
                        // Start editing
                        editedName = pilot.name
                        editedAddressLine1 = pilot.addressLine1
                        editedAddressLine2 = pilot.addressLine2
                        editedAddressLine3 = pilot.addressLine3
                        editedTelephone = pilot.telephone
                        editedEmail = pilot.email
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Save" : "Edit")
                }
            }
            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isEditing = false
                    }
                }
            }
        }
    }
}

struct AddPilotView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var addressLine1 = ""
    @State private var addressLine2 = ""
    @State private var addressLine3 = ""
    @State private var telephone = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Contact Information")) {
                        TextField("Name", text: $name)
                        TextField("Telephone", text: $telephone)
                        TextField("Email", text: $email)
                    }
                    
                    Section(header: Text("Address")) {
                        TextField("Address Line 1", text: $addressLine1)
                        TextField("Address Line 2", text: $addressLine2)
                        TextField("Address Line 3", text: $addressLine3)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Pilot")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    let newPilot = Pilot(
                        name: name,
                        addressLine1: addressLine1,
                        addressLine2: addressLine2,
                        addressLine3: addressLine3,
                        telephone: telephone,
                        email: email
                    )
                    modelContext.insert(newPilot)
                    isPresented = false
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

#Preview {
    PilotsView()
        .modelContainer(for: Pilot.self, inMemory: true)
}
