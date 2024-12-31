import SwiftUI

struct SummaryView: View {
    @State private var records: [Record] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(records) { record in
                    NavigationLink(destination: RecordDetailView(record: record)) {
                        VStack(alignment: .leading) {
                            Text("Date: \(record.date, formatter: dateFormatter)")
                            Text("Driver: \(record.driverName)")
                            Text("Truck: \(record.truckNumber)")
                        }
                    }
                    .contextMenu {
                        Button(action: {
                            viewRecord(record)
                        }) {
                            Text("View")
                            Image(systemName: "eye")
                        }
                        Button(action: {
                            deleteRecord(record)
                        }) {
                            Text("Delete")
                            Image(systemName: "trash")
                        }
                    }
                }
                .onDelete(perform: deleteRecords)
            }
            .navigationTitle("History")
            .onAppear {
                loadRecords()
            }
            .refreshable {
                refreshRecords()
            }
        }
    }

    private func loadRecords() {
        if let savedData = UserDefaults.standard.data(forKey: "savedRecords"),
           let decodedRecords = try? JSONDecoder().decode([Record].self, from: savedData) {
            records = decodedRecords
        }
    }
    
    private func refreshRecords() {
        loadRecords()
        print("Records refreshed")
    }
    
    private func viewRecord(_ record: Record) {
        // This function can be used for additional actions if needed
        print("Viewing record for \(record.driverName)")
    }
    
    private func deleteRecord(_ record: Record) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records.remove(at: index)
            saveRecords()
        }
    }
    
    private func deleteRecords(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        saveRecords()
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: "savedRecords")
        }
    }
}

struct Record: Identifiable, Codable {
    let id: UUID
    let date: Date
    let driverName: String
    let truckNumber: String
    let completedItems: [String]
    let comments: String

    init(id: UUID = UUID(), date: Date, driverName: String, truckNumber: String, completedItems: [String], comments: String) {
        self.id = id
        self.date = date
        self.driverName = driverName
        self.truckNumber = truckNumber
        self.completedItems = completedItems
        self.comments = comments
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
} 