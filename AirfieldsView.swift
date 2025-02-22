import SwiftUI
import SwiftData

@Model
class Airfield {
    var id: UUID
    var code: String
    var name: String?
    var county: String?
    var country: String?
    var telephone: String?
    var website: String?
    
    init(code: String, name: String? = nil, county: String? = nil, country: String? = nil, telephone: String? = nil, website: String? = nil) {
        self.id = UUID()
        self.code = code
        self.name = name
        self.county = county
        self.country = country
        self.telephone = telephone
        self.website = website
    }
}

struct AirfieldsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var airfields: [Airfield]
    @State private var isShowingAddForm = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                List {
                    ForEach(airfields) { airfield in
                        NavigationLink {
                            AirfieldDetailView(airfield: airfield)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(airfield.code)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if let name = airfield.name {
                                    Text(name)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let location = airfield.county {
                                    Text(location)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Airfields")
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
                AddAirfieldView(isPresented: $isShowingAddForm)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(airfields[index])
            }
        }
    }
}

struct AirfieldDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let airfield: Airfield
    @State private var isEditing = false
    @State private var editedCode = ""
    @State private var editedName = ""
    @State private var editedCounty = ""
    @State private var editedCountry = ""
    @State private var editedTelephone = ""
    @State private var editedWebsite = ""
    
    var body: some View {
        List {
            if isEditing {
                Section(header: Text("Airfield Information")) {
                    TextField("Code", text: $editedCode)
                    TextField("Name", text: $editedName)
                    TextField("County", text: $editedCounty)
                    TextField("Country", text: $editedCountry)
                    TextField("Telephone", text: $editedTelephone)
                    TextField("Website", text: $editedWebsite)
                }
            } else {
                Section(header: Text("Basic Information")) {
                    Text("Code: \(airfield.code)")
                    if let name = airfield.name {
                        Text("Name: \(name)")
                    }
                }
                
                Section(header: Text("Location")) {
                    if let county = airfield.county {
                        Text("County: \(county)")
                    }
                    if let country = airfield.country {
                        Text("Country: \(country)")
                    }
                }
                
                Section(header: Text("Contact")) {
                    if let telephone = airfield.telephone {
                        Text("Telephone: \(telephone)")
                    }
                    if let website = airfield.website {
                        Text("Website: \(website)")
                    }
                }
            }
        }
        .navigationTitle("Airfield Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditing {
                        // Save changes
                        airfield.code = editedCode
                        airfield.name = editedName.isEmpty ? nil : editedName
                        airfield.county = editedCounty.isEmpty ? nil : editedCounty
                        airfield.country = editedCountry.isEmpty ? nil : editedCountry
                        airfield.telephone = editedTelephone.isEmpty ? nil : editedTelephone
                        airfield.website = editedWebsite.isEmpty ? nil : editedWebsite
                    } else {
                        // Start editing
                        editedCode = airfield.code
                        editedName = airfield.name ?? ""
                        editedCounty = airfield.county ?? ""
                        editedCountry = airfield.country ?? ""
                        editedTelephone = airfield.telephone ?? ""
                        editedWebsite = airfield.website ?? ""
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

struct AddAirfieldView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    
    @State private var code = ""
    @State private var name = ""
    @State private var county = ""
    @State private var country = ""
    @State private var telephone = ""
    @State private var website = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                Form {
                    TextField("Code (Required)", text: $code)
                    TextField("Name", text: $name)
                    TextField("County", text: $county)
                    TextField("Country", text: $country)
                    TextField("Telephone", text: $telephone)
                    TextField("Website", text: $website)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Airfield")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    let newAirfield = Airfield(
                        code: code,
                        name: name.isEmpty ? nil : name,
                        county: county.isEmpty ? nil : county,
                        country: country.isEmpty ? nil : country,
                        telephone: telephone.isEmpty ? nil : telephone,
                        website: website.isEmpty ? nil : website
                    )
                    modelContext.insert(newAirfield)
                    isPresented = false
                }
                .disabled(code.isEmpty)
            )
        }
    }
}

#Preview {
    AirfieldsView()
        .modelContainer(for: Airfield.self, inMemory: true)
}
