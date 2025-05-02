import SwiftUI

struct CreateMatchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var matchService = MatchService()
    @State private var title = ""
    @State private var description = ""
    @State private var gameType = ""
    @State private var maxPlayers = 2
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var isPrivate = false
    @State private var password = ""
    @State private var allowSpectators = true
    @State private var autoStart = false
    @State private var minPlayers = 2
    @State private var customRules: [String: String] = [:]
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Match Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Game Type", text: $gameType)
                    Stepper("Max Players: \(maxPlayers)", value: $maxPlayers, in: 2...100)
                }
                
                Section(header: Text("Schedule")) {
                    DatePicker("Start Time", selection: $startTime)
                    DatePicker("End Time", selection: $endTime)
                }
                
                Section(header: Text("Settings")) {
                    Toggle("Private Match", isOn: $isPrivate)
                    if isPrivate {
                        SecureField("Password", text: $password)
                    }
                    Toggle("Allow Spectators", isOn: $allowSpectators)
                    Toggle("Auto Start", isOn: $autoStart)
                    Stepper("Min Players: \(minPlayers)", value: $minPlayers, in: 2...maxPlayers)
                }
                
                Section {
                    Button(action: createMatch) {
                        HStack {
                            Spacer()
                            Text("Create Match")
                                .bold()
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty || gameType.isEmpty)
                }
            }
            .navigationTitle("Create Match")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createMatch() {
        let settings = MatchSettings(
            allowSpectators: allowSpectators,
            autoStart: autoStart,
            minPlayers: minPlayers,
            customRules: customRules
        )
        
        let match = Match(
            title: title,
            description: description,
            creatorID: "current_user_id", // Replace with actual user ID
            creatorName: "Current User", // Replace with actual username
            gameType: gameType,
            maxPlayers: maxPlayers,
            currentPlayers: 0,
            startTime: startTime,
            endTime: endTime,
            status: .upcoming,
            participants: [],
            settings: settings,
            isPrivate: isPrivate,
            password: isPrivate ? password : nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        Task {
            do {
                _ = try await matchService.createMatch(match)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
} 