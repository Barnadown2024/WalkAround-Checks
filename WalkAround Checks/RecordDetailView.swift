import SwiftUI
import PDFKit

struct RecordDetailView: View {
    let record: Record

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Date: \(record.date, formatter: dateFormatter)")
                Text("Driver: \(record.driverName)")
                Text("Truck: \(record.truckNumber)")
                
                Text("Completed Checklist Items:")
                    .font(.headline)
                
                ForEach(record.completedItems, id: \.self) { item in
                    Text(item)
                }
                
                if !record.comments.isEmpty {
                    Text("Comments:")
                        .font(.headline)
                    Text(record.comments)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: sharePDF) {
                    Text("Share PDF")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Record Details")
    }
    
    private func sharePDF() {
        let pdfData = createPDF()
        
        // Check if PDF data is generated
        print("PDF Data Size: \(pdfData.count) bytes")
        
        // Generate a file name using the driver's name and date in DD-MM-YYYY format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: record.date)
        let sanitizedDriverName = record.driverName.replacingOccurrences(of: " ", with: "_")
        let fileName = "\(sanitizedDriverName)_\(dateString)_Checklist.pdf"
        
        // Save PDF data to a temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try pdfData.write(to: tempURL)
            let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        } catch {
            print("Failed to write PDF data to file: \(error)")
        }
    }
    
    private func createPDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "WalkAround Checks",
            kCGPDFContextAuthor: "Your App Name",
            kCGPDFContextTitle: "WalkAround Checklist Record"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let padding: CGFloat = 20.0
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            var pageNumber = 1
            func drawFooter() {
                let footerAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)]
                
                // Left-justified text
                let leftText = "Generated by WalkAround-Checks App"
                let leftTextSize = leftText.size(withAttributes: footerAttributes)
                let leftTextRect = CGRect(x: padding, y: pageHeight - 40, width: leftTextSize.width, height: leftTextSize.height)
                leftText.draw(in: leftTextRect, withAttributes: footerAttributes)
                
                // Right-justified text
                let rightText = "Page \(pageNumber)"
                let rightTextSize = rightText.size(withAttributes: footerAttributes)
                let rightTextRect = CGRect(x: pageWidth - rightTextSize.width - padding, y: pageHeight - 40, width: rightTextSize.width, height: rightTextSize.height)
                rightText.draw(in: rightTextRect, withAttributes: footerAttributes)
            }
            
            context.beginPage()
            drawFooter()
            
            let titleAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
            let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
            let categoryAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]
            
            var yOffset: CGFloat = padding
            
            let title = "WalkAround Checklist Record"
            title.draw(at: CGPoint(x: padding, y: yOffset), withAttributes: titleAttributes)
            yOffset += 40
            
            // Use DD/MM/YYYY format for the date in the PDF
            let pdfDateFormatter = DateFormatter()
            pdfDateFormatter.dateFormat = "dd/MM/yyyy"
            let dateText = "Date: \(pdfDateFormatter.string(from: record.date))"
            dateText.draw(at: CGPoint(x: padding, y: yOffset), withAttributes: textAttributes)
            yOffset += 20
            
            let driverText = "Driver: \(record.driverName)"
            driverText.draw(at: CGPoint(x: padding, y: yOffset), withAttributes: textAttributes)
            yOffset += 20
            
            let truckText = "Truck: \(record.truckNumber)"
            truckText.draw(at: CGPoint(x: padding, y: yOffset), withAttributes: textAttributes)
            yOffset += 40
            
            let checklistTitle = "Completed Checklist Items:"
            checklistTitle.draw(at: CGPoint(x: padding, y: yOffset), withAttributes: titleAttributes)
            yOffset += 20
            
            // Define the checklist categories in the desired order
            let checklistCategories: [String: [String]] = [
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
            
            // Iterate over categories in the defined order
            for (category, items) in checklistCategories {
                let completedItems = items.filter { record.completedItems.contains($0) }
                if !completedItems.isEmpty {
                    if yOffset + 20 > pageHeight - 60 { // Adjust for footer
                        context.beginPage()
                        pageNumber += 1
                        drawFooter()
                        yOffset = padding
                    }
                    category.draw(at: CGPoint(x: padding, y: yOffset), withAttributes: categoryAttributes)
                    yOffset += 20
                    
                    for item in completedItems {
                        if yOffset + 20 > pageHeight - 60 { // Adjust for footer
                            context.beginPage()
                            pageNumber += 1
                            drawFooter()
                            yOffset = padding
                        }
                        item.draw(at: CGPoint(x: padding + 20, y: yOffset), withAttributes: textAttributes)
                        yOffset += 20
                    }
                }
            }
            
            if !record.comments.isEmpty {
                if yOffset + 40 > pageHeight - 60 { // Adjust for footer
                    context.beginPage()
                    pageNumber += 1
                    drawFooter()
                    yOffset = padding
                }
                yOffset += 20
                let commentsTitle = "Comments:"
                commentsTitle.draw(at: CGPoint(x: padding, y: yOffset), withAttributes: titleAttributes)
                yOffset += 20
                
                let commentsText = record.comments
                commentsText.draw(at: CGPoint(x: padding, y: yOffset), withAttributes: textAttributes)
            }
        }
        
        return data
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecordDetailView(record: Record(
            date: Date(),
            driverName: "John Doe",
            truckNumber: "1234",
            completedItems: [
                "Tires: Inspect for proper inflation.",
                "Brakes: Test the operation of service and parking brakes.",
                "Lights and Reflectors: Test headlights, taillights, brake lights, and turn signals.",
                "Mirrors and Windows: Clean and ensure windows and mirrors are free of cracks.",
                "Fluid Levels: Check oil, coolant, and windshield washer fluid levels.",
                "Battery: Ensure the battery is securely mounted.",
                "Brakes: Test the operation of service and parking brakes.",
                "Seatbelts: Verify seatbelts are functional and not frayed.",
                "Load Security: Check that cargo is properly loaded and secured.",
                "Emergency Exits: Ensure easy access to emergency exits in the cab."
            ],
            comments: "Checked all items thoroughly. No issues found."
        ))
    }
} 