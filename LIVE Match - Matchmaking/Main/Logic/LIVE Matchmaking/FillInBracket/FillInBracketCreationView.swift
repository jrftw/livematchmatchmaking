// FILE: FillInBracketCreationView.swift
// UPDATED FILE

import SwiftUI
import UniformTypeIdentifiers
import Foundation
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct FillInBracketCreationView: View {
    public let title: String
    public let platform: LivePlatformOption
    public let existingDoc: FillInBracketDoc?
    
    @State private var bracketName = ""
    @State private var slots: [FillInBracketSlot] = []
    
    @State private var showingNewSlotSheet = false
    @State private var showingExporter = false
    @State private var exportURL: URL? = nil
    
    @State private var showingImporter = false
    @State private var showingTemplateOptions = false
    @State private var templateURL: URL? = nil
    @State private var showingTemplateExporter = false
    
    // Controls bracket visibility (Public or Private)
    @State private var isPublic = true
    
    // Navigates back to "My Brackets" after save
    @State private var shouldGoToMyBrackets = false
    
    @Environment(\.openURL) private var openURL
    
    public init(
        title: String,
        platform: LivePlatformOption,
        existingDoc: FillInBracketDoc? = nil
    ) {
        self.title = title
        self.platform = platform
        self.existingDoc = existingDoc
    }
    
    public var body: some View {
        NavigationView {
            Form {
                // MARK: Bracket Info
                Section(header: Text("Bracket Info")) {
                    TextField("Bracket Name", text: $bracketName)
                    Text("Platform: \(platform.name)")
                    Toggle("Public (Visible to Everyone)", isOn: $isPublic)
                }
                
                // MARK: Slots to Fill
                Section(header: Text("Slots to Fill")) {
                    if slots.isEmpty {
                        Text("No slots added yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(slots) { slot in
                            NavigationLink {
                                FillInBracketSlotEditView(
                                    slot: slot,
                                    onSave: { updated in
                                        if let idx = slots.firstIndex(where: { $0.id == updated.id }) {
                                            slots[idx] = updated
                                        }
                                    }
                                )
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(slot.creator1.isEmpty ? "?" : slot.creator1) vs \(slot.creator2.isEmpty ? "?" : slot.creator2)")
                                        .font(.headline)
                                    Text("Date: \(formatDateTime(slot.startDateTime))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Status: \(slot.status.rawValue)")
                                        .font(.subheadline)
                                        .foregroundColor(colorForStatus(slot.status))
                                }
                            }
                        }
                        .onDelete { idxSet in
                            slots.remove(atOffsets: idxSet)
                        }
                    }
                    Button("Add New Slot") {
                        showingNewSlotSheet = true
                    }
                }
                
                // MARK: Import / Export
                Section(header: Text("Import / Export")) {
                    Button("Export to CSV") {
                        handleExportCSV()
                    }
                    .disabled(slots.isEmpty)
                    
                    Button("Import CSV / Excel / Sheets") {
                        showingImporter = true
                    }
                    
                    Button("Download Templates") {
                        showingTemplateOptions = true
                    }
                }
                
                // MARK: Save Bracket
                Section {
                    Button("Save Bracket") {
                        saveBracket()
                    }
                }
            }
            .navigationTitle(title)
            .sheet(isPresented: $showingNewSlotSheet) {
                FillInBracketSlotEditView(
                    slot: FillInBracketSlot(),
                    onSave: { newSlot in
                        slots.append(newSlot)
                        showingNewSlotSheet = false
                    },
                    onCancel: {
                        showingNewSlotSheet = false
                    }
                )
            }
            .sheet(isPresented: $showingExporter) {
                if let url = exportURL {
                    FillInSharesheetActivityView(activityItems: [url])
                } else {
                    Text("Export error: no URL generated.")
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.commaSeparatedText, .data, .plainText, .spreadsheet],
                allowsMultipleSelection: false
            ) { result in
                handleImportResult(result)
            }
            .confirmationDialog("Download Which Template?",
                                isPresented: $showingTemplateOptions,
                                titleVisibility: .visible) {
                Button("CSV Template") {
                    downloadCSVTemplate()
                }
                Button("Excel Template") {
                    downloadExcelTemplate()
                }
                Button("Google Sheets Template") {
                    openGoogleSheetsTemplate()
                }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showingTemplateExporter) {
                if let url = templateURL {
                    FillInSharesheetActivityView(activityItems: [url])
                } else {
                    Text("Template file generation error.")
                }
            }
            .background(
                // Hidden NavigationLink to jump to "MyBracketsListView" after saving
                NavigationLink(
                    destination: MyBracketsListView().navigationBarTitle("My Brackets"),
                    isActive: $shouldGoToMyBrackets
                ) {
                    EmptyView()
                }
                .hidden()
            )
            .onAppear {
                // Load data if editing an existing doc
                if let doc = existingDoc {
                    bracketName = doc.bracketName
                    slots = doc.slots
                    isPublic = doc.isPublic
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
    // MARK: Save Bracket
    private func saveBracket() {
        print("Saving bracket '\(bracketName)' with \(slots.count) slots.")
        
        guard let user = Auth.auth().currentUser else {
            print("User must be logged in to save bracket.")
            return
        }
        
        let db = FirebaseManager.shared.db
        
        if let existing = existingDoc, let docID = existing.id {
            // Update existing doc
            let ref = db.collection("fillInBrackets").document(docID)
            let updated = FillInBracketDoc(
                id: docID,
                bracketName: bracketName,
                platformName: platform.name,
                slots: slots,
                createdByUserID: existing.createdByUserID,
                createdAt: existing.createdAt,
                isPublic: isPublic
            )
            do {
                try ref.setData(from: updated) { err in
                    if let err = err {
                        print("Error updating bracket: \(err.localizedDescription)")
                    } else {
                        print("Bracket updated successfully.")
                        shouldGoToMyBrackets = true
                    }
                }
            } catch {
                print("Error encoding updated bracket: \(error.localizedDescription)")
            }
        } else {
            // Create a new doc
            let newDoc = FillInBracketDoc(
                bracketName: bracketName,
                platformName: platform.name,
                slots: slots,
                createdByUserID: user.uid,
                createdAt: Date(),
                isPublic: isPublic
            )
            do {
                _ = try db.collection("fillInBrackets").addDocument(from: newDoc) { err in
                    if let err = err {
                        print("Error creating bracket: \(err.localizedDescription)")
                    } else {
                        print("Bracket created successfully.")
                        shouldGoToMyBrackets = true
                    }
                }
            } catch {
                print("Error encoding new bracket: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Export CSV
    private func handleExportCSV() {
        let csvText = buildCSV(from: slots)
        let filename = "\(bracketName.isEmpty ? "Bracket" : bracketName)_Export.csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
            exportURL = tempURL
            showingExporter = true
        } catch {
            print("Failed writing CSV: \(error.localizedDescription)")
        }
    }
    
    // MARK: CSV Utilities
    private func buildCSV(from slots: [FillInBracketSlot]) -> String {
        var lines: [String] = []
        lines.append("Date,PT,MT,CT,ET,Creator1,Net/Agency1,Cat1,Diamond1,Creator2,Net/Agency2,Cat2,Diamond2,Status,Notes,Link")
        for slot in slots {
            let pt = formatTimeZone(slot.startDateTime, "America/Los_Angeles")
            let mt = formatTimeZone(slot.startDateTime, "America/Denver")
            let ct = formatTimeZone(slot.startDateTime, "America/Chicago")
            let et = formatTimeZone(slot.startDateTime, "America/New_York")
            let localDate = formatDateOnly(slot.startDateTime)
            let line = [
                localDate,
                pt,
                mt,
                ct,
                et,
                cleanForCSV(slot.creator1),
                cleanForCSV(slot.creatorNetworkOrAgency1),
                cleanForCSV(slot.category1),
                cleanForCSV(slot.diamondAvg1),
                cleanForCSV(slot.creator2),
                cleanForCSV(slot.creatorNetworkOrAgency2),
                cleanForCSV(slot.category2),
                cleanForCSV(slot.diamondAvg2),
                slot.status.rawValue,
                cleanForCSV(slot.notes),
                cleanForCSV(slot.link)
            ].joined(separator: ",")
            lines.append(line)
        }
        return lines.joined(separator: "\n")
    }
    
    private func cleanForCSV(_ val: String) -> String {
        if val.contains(",") || val.contains("\"") {
            let escaped = val.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return val
    }
    
    // MARK: Import Helpers
    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let err):
            print("Import error: \(err.localizedDescription)")
        case .success(let urls):
            guard let url = urls.first else { return }
            let ext = url.pathExtension.lowercased()
            if ext == "csv" {
                importCSV(url)
            } else {
                importExcelOrSheets(url)
            }
        }
    }
    
    private func importCSV(_ fileURL: URL) {
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            parseCSV(content)
        } catch {
            print("Reading CSV failed: \(error.localizedDescription)")
        }
    }
    
    private func parseCSV(_ text: String) {
        let lines = text.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count > 1 else { return }
        var newSlots: [FillInBracketSlot] = []
        for row in lines.dropFirst() {
            let cols = row.split(separator: ",").map { String($0) }
            if cols.count < 16 { continue }
            let localDateStr = cols[0]
            let statusStr = cols[13]
            let notes = cols[14]
            let link = cols[15]
            let c1 = cols[5]
            let net1 = cols[6]
            let cat1 = cols[7]
            let d1 = cols[8]
            let c2 = cols[9]
            let net2 = cols[10]
            let cat2 = cols[11]
            let d2 = cols[12]
            let statusParsed = MatchStatus(rawValue: statusStr) ?? .pending
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .none
            let date = df.date(from: localDateStr) ?? Date()
            let slot = FillInBracketSlot(
                startDateTime: date,
                creator1: c1,
                creatorNetworkOrAgency1: net1,
                category1: cat1,
                diamondAvg1: d1,
                creator2: c2,
                creatorNetworkOrAgency2: net2,
                category2: cat2,
                diamondAvg2: d2,
                status: statusParsed,
                notes: notes,
                link: link
            )
            newSlots.append(slot)
        }
        slots.append(contentsOf: newSlots)
    }
    
    private func importExcelOrSheets(_ fileURL: URL) {
        do {
            let _ = try Data(contentsOf: fileURL)
            print("Excel/Sheets import succeeded (basic data read).")
        } catch {
            print("Excel/Sheets import read failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: Template Downloads
    private func downloadCSVTemplate() {
        let lines = [
            "Date,PT,MT,CT,ET,Creator1,Net/Agency1,Cat1,Diamond1,Creator2,Net/Agency2,Cat2,Diamond2,Status,Notes,Link",
            "1/1/25,8:00 PM,9:00 PM,10:00 PM,11:00 PM,CreatorA,AgencyX,Music,1000,CreatorB,NetworkZ,Comedy,2000,Pending,Sample notes,https://example.com"
        ]
        let csvText = lines.joined(separator: "\n")
        let filename = "FillInBracket_Template.csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try csvText.write(to: tempURL, atomically: true, encoding: .utf8)
            templateURL = tempURL
            showingTemplateExporter = true
        } catch {
            print("Error creating CSV template: \(error)")
        }
    }
    
    private func downloadExcelTemplate() {
        let lines = [
            "Date,PT,MT,CT,ET,Creator1,Net/Agency1,Cat1,Diamond1,Creator2,Net/Agency2,Cat2,Diamond2,Status,Notes,Link",
            "1/1/25,8:00 PM,9:00 PM,10:00 PM,11:00 PM,CreatorA,AgencyX,Music,1000,CreatorB,NetworkZ,Comedy,2000,Pending,Sample notes,https://example.com"
        ]
        let pseudoExcel = lines.joined(separator: "\n")
        let filename = "FillInBracket_Template.xlsx"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try pseudoExcel.write(to: tempURL, atomically: true, encoding: .utf8)
            templateURL = tempURL
            showingTemplateExporter = true
        } catch {
            print("Error creating Excel template: \(error)")
        }
    }
    
    private func openGoogleSheetsTemplate() {
        guard let link = URL(string: "https://docs.google.com/spreadsheets/d/EXAMPLE_SHEET_ID") else { return }
        openURL(link)
    }
    
    // MARK: Formatting Helpers
    private func formatDateTime(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }
    
    private func formatTimeZone(_ date: Date, _ tzID: String) -> String {
        guard let tz = TimeZone(identifier: tzID) else { return "" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.timeZone = tz
        return formatter.string(from: date)
    }
    
    private func formatDateOnly(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df.string(from: date)
    }
    
    private func colorForStatus(_ st: MatchStatus) -> Color {
        switch st {
        case .confirmed: return .green
        case .declined:  return .red
        case .pending:   return .orange
        }
    }
}
