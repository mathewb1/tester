import SwiftUI
import SwiftData
import PhotosUI

@Model
class Aircraft {
    var id: UUID
    var registration: String
    var make: String
    var model: String
    var code: String
    var engineType: String
    var photoData: Data?
    
    init(registration: String = "", make: String = "", model: String = "", code: String = "", engineType: String = "SEP", photoData: Data? = nil) {
        self.id = UUID()
        self.registration = registration
        self.make = make
        self.model = model
        self.code = code
        self.engineType = engineType
        self.photoData = photoData
    }
}

struct AircraftView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var aircraft: [Aircraft]
    @State private var isShowingAddForm = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                List {
                    ForEach(aircraft) { aircraft in
                        NavigationLink {
                            AircraftDetailView(aircraft: aircraft)
                        } label: {
                            HStack {
                                if let photoData = aircraft.photoData,
                                   let uiImage = UIImage(data: photoData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Image(systemName: "airplane")
                                        .frame(width: 50, height: 50)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(aircraft.registration)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    HStack {
                                        Text("Type:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(aircraft.make) \(aircraft.model)")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    HStack {
                                        Text("Engine Type:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(aircraft.engineType)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Aircraft")
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
                AddAircraftView(isPresented: $isShowingAddForm)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(aircraft[index])
            }
        }
    }
}

struct AircraftDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let aircraft: Aircraft
    @State private var isEditing = false
    @State private var editedRegistration = ""
    @State private var editedMake = ""
    @State private var editedModel = ""
    @State private var editedCode = ""
    @State private var editedEngineType = "SEP"
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var image: UIImage?
    @State private var showingPhotoOptions = false
    
    let engineTypes = ["SEP", "MEP"]
    
    var body: some View {
        List {
            if isEditing {
                Section(header: Text("Photo")) {
                    HStack {
                        if let photoData = aircraft.photoData,
                           let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        }
                        
                        if isEditing {
                            Button(action: {
                                showingPhotoOptions = true
                            }) {
                                Label("Change Photo", systemImage: "photo.fill")
                            }
                        }
                    }
                }
                .confirmationDialog("Choose Photo Source", isPresented: $showingPhotoOptions, titleVisibility: .visible) {
                    Button("Photo Library") {
                        showingImagePicker = true
                    }
                    Button("Camera") {
                        showingCamera = true
                    }
                    Button("Cancel", role: .cancel) {}
                }

                
                Section(header: Text("Aircraft Information")) {
                    TextField("Registration", text: $editedRegistration)
                    TextField("Make", text: $editedMake)
                    TextField("Model", text: $editedModel)
                    TextField("Code", text: $editedCode)
                    
                    Picker("Engine Type", selection: $editedEngineType) {
                        ForEach(engineTypes, id: \.self) {
                            Text($0)
                        }
                    }
                }
            } else {
                if let photoData = aircraft.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Section(header: Text("Photo")) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                }
                
                Section(header: Text("Aircraft Information")) {
                    Text("Registration: \(aircraft.registration)")
                    Text("Make: \(aircraft.make)")
                    Text("Model: \(aircraft.model)")
                    Text("Code: \(aircraft.code)")
                    Text("Engine Type: \(aircraft.engineType)")
                }
            }
        }
        .navigationTitle("Aircraft Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditing {
                        // Save changes
                        aircraft.registration = editedRegistration
                        aircraft.make = editedMake
                        aircraft.model = editedModel
                        aircraft.code = editedCode
                        aircraft.engineType = editedEngineType
                        if let image = image {
                            aircraft.photoData = image.jpegData(compressionQuality: 0.8)
                        }
                    } else {
                        // Start editing
                        editedRegistration = aircraft.registration
                        editedMake = aircraft.make
                        editedModel = aircraft.model
                        editedCode = aircraft.code
                        editedEngineType = aircraft.engineType
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
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $image)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $image)
        }
    }
}
struct AddAircraftView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    
    @State private var registration = ""
    @State private var make = ""
    @State private var model = ""
    @State private var code = ""
    @State private var engineType = "SEP"
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var image: UIImage?
    @State private var showingPhotoOptions = false
    
    let engineTypes = ["SEP", "MEP"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Photo")) {
                        HStack {
                            if let image = image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            }
                            
                            Button(action: {
                                showingPhotoOptions = true
                            }) {
                                Label("Add Photo", systemImage: "photo.fill")
                            }
                        }
                    }
                    .confirmationDialog("Choose Photo Source", isPresented: $showingPhotoOptions, titleVisibility: .visible) {
                        Button("Photo Library") {
                            showingImagePicker = true
                        }
                        Button("Camera") {
                            showingCamera = true
                        }
                        Button("Cancel", role: .cancel) {}
                    }

                    
                    Section(header: Text("Aircraft Information")) {
                        TextField("Registration", text: $registration)
                        TextField("Make", text: $make)
                        TextField("Model", text: $model)
                        TextField("Code", text: $code)
                        
                        Picker("Engine Type", selection: $engineType) {
                            ForEach(engineTypes, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Aircraft")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    let newAircraft = Aircraft(
                        registration: registration,
                        make: make,
                        model: model,
                        code: code,
                        engineType: engineType,
                        photoData: image?.jpegData(compressionQuality: 0.8)
                    )
                    modelContext.insert(newAircraft)
                    isPresented = false
                }
                .disabled(registration.isEmpty)
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $image)
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $image)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    AircraftView()
        .modelContainer(for: Aircraft.self, inMemory: true)
}
