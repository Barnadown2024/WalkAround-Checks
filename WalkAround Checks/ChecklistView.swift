import SwiftUI

struct ChecklistView: View {
    @State private var truckNumber: String = ""
    @State private var driverName: String = ""
    @State private var checkDate = Date()
    @State private var completedItems = Set<String>()
    @State private var comments: String = ""
    @State private var showSummary = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // Categorized checklist items
    private let checklistCategories: [String: [String]] = [
        "Exterior Check": [
            "Tires: Inspect for proper inflation.",
            "Tires: Check for any visible wear or damage.",
            "Tires: Ensure lug nuts are tight.",
            "Lights and Reflectors: Test headlights, taillights, brake lights, and turn signals.",
            "Lights and Reflectors: Verify that clearance lights are visible and operational.",
            "Lights and Reflectors: Check reflectors and reflective tape for visibility.",
            "Mirrors and Windows: Clean and ensure windows and mirrors are free of cracks.",
            "Mirrors and Windows: Adjust mirrors for optimal rear visibility.",
            "Fluid Leaks: Check under the vehicle for any signs of oil, coolant, or fuel leaks.",
            "Body and Frame: Inspect the body for any visible damage, rust, or loose parts.",
            "Body and Frame: Ensure the frame is free of cracks or defects.",
            "Suspension: Check suspension components for wear or damage.",
            "Suspension: Ensure shock absorbers are in good condition."
        ],
        "Engine Compartment": [
            "Fluid Levels: Check oil, coolant, and windshield washer fluid levels.",
            "Fluid Levels: Inspect power steering and brake fluid levels.",
            "Battery: Ensure the battery is securely mounted.",
            "Battery: Check for corrosion on terminals.",
            "Belts and Hoses: Inspect for wear, cracks, or fraying."
        ],
        "Interior Check": [
            "Brakes: Test the operation of service and parking brakes.",
            "Steering: Ensure steering wheel has minimal play and operates smoothly.",
            "Gauges and Instruments: Verify that all gauges (fuel, temperature, pressure) are functioning.",
            "Emergency Equipment: Check for a functional fire extinguisher and first aid kit.",
            "Emergency Equipment: Ensure warning triangles or flares are present."
        ],
        "Safety Features": [
            "Seatbelts: Verify seatbelts are functional and not frayed.",
            "Horn: Test the horn to ensure it is operational.",
            "Emergency Exits: Ensure easy access to emergency exits in the cab."
        ],
        "Cargo and Trailer": [
            "Load Security: Check that cargo is properly loaded and secured.",
            "Trailer Connection: Inspect the kingpin and locking jaws.",
            "Trailer Connection: Verify that safety chains are attached.",
            "Trailer Doors: Ensure doors open, close, and lock securely."
        ]
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Form {
                    Section(header: Text("Driver Details")) {
                        TextField("Driver Name", text: $driverName)
                        TextField("Truck Number", text: $truckNumber)
                        DatePicker("Check Date", selection: $checkDate, displayedComponents: .date)
                    }
                    
                    ForEach(checklistCategories.keys.sorted(), id: \.self) { category in
                        DisclosureGroup {
                            Button(action: {
                                toggleAllItems(in: category)
                            }) {
                                Text("Select All")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .padding(.bottom, 5)
                            
                            ForEach(checklistCategories[category]!, id: \.self) { item in
                                HStack {
                                    Text(item)
                                    Spacer()
                                    if completedItems.contains(item) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .onTapGesture {
                                    toggleItem(item)
                                }
                            }
                        } label: {
                            Text(category)
                        }
                    }
                    
                    Section(header: Text("Comments")) {
                        TextEditor(text: $comments)
                            .frame(height: 100)
                            .border(Color.gray, width: 1)
                    }
                    
                    NavigationLink(destination: SummaryView(), isActive: $showSummary) {
                        EmptyView()
                    }
                    
                    Button(action: validateChecklist) {
                        Text("Submit Checklist")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .navigationTitle("Safety Check")
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Missing Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    private func toggleItem(_ item: String) {
        if completedItems.contains(item) {
            completedItems.remove(item)
        } else {
            completedItems.insert(item)
        }
    }
    
    private func toggleAllItems(in category: String) {
        let items = checklistCategories[category] ?? []
        let allSelected = items.allSatisfy { completedItems.contains($0) }
        
        if allSelected {
            // Deselect all items
            items.forEach { completedItems.remove($0) }
        } else {
            // Select all items
            items.forEach { completedItems.insert($0) }
        }
    }
    
    private func validateChecklist() {
        guard !driverName.isEmpty else {
            alertMessage = "Please enter the driver's name."
            showAlert = true
            return
        }
        
        guard !truckNumber.isEmpty else {
            alertMessage = "Please enter the truck number."
            showAlert = true
            return
        }
        
        let allItems = checklistCategories.values.flatMap { $0 }
        let allChecked = allItems.allSatisfy { completedItems.contains($0) }
        
        if allChecked {
            // Save the record
            saveRecord()
            // Proceed with submission
            showSummary = true
        } else {
            // Show an alert or message to the user
            alertMessage = "Please complete all checklist items before submitting."
            showAlert = true
        }
    }
    
    private func saveRecord() {
        let newRecord = Record(
            date: checkDate,
            driverName: driverName,
            truckNumber: truckNumber,
            completedItems: Array(completedItems),
            comments: comments
        )
        var savedRecords = loadSavedRecords()
        savedRecords.append(newRecord)
        
        if let encoded = try? JSONEncoder().encode(savedRecords) {
            UserDefaults.standard.set(encoded, forKey: "savedRecords")
        }
    }
    
    private func loadSavedRecords() -> [Record] {
        if let savedData = UserDefaults.standard.data(forKey: "savedRecords"),
           let decodedRecords = try? JSONDecoder().decode([Record].self, from: savedData) {
            return decodedRecords
        }
        return []
    }
}

struct ChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        ChecklistView()
    }
} 