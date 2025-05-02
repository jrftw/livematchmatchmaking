import SwiftUI

struct MatchListView: View {
    @StateObject private var matchService = MatchService()
    @State private var showingCreateMatch = false
    @State private var searchText = ""
    @State private var selectedFilter: MatchFilter = .all
    
    enum MatchFilter {
        case all
        case upcoming
        case inProgress
        case myMatches
    }
    
    var filteredMatches: [Match] {
        var matches = matchService.matches
        
        if !searchText.isEmpty {
            matches = matches.filter { match in
                match.title.localizedCaseInsensitiveContains(searchText) ||
                match.description.localizedCaseInsensitiveContains(searchText) ||
                match.gameType.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch selectedFilter {
        case .upcoming:
            return matches.filter { $0.status == .upcoming }
        case .inProgress:
            return matches.filter { $0.status == .inProgress }
        case .myMatches:
            return matches.filter { $0.participants.contains("current_user_id") } // Replace with actual user ID
        case .all:
            return matches
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    Text("All").tag(MatchFilter.all)
                    Text("Upcoming").tag(MatchFilter.upcoming)
                    Text("In Progress").tag(MatchFilter.inProgress)
                    Text("My Matches").tag(MatchFilter.myMatches)
                }
                .pickerStyle(.segmented)
                .padding()
                
                List(filteredMatches) { match in
                    NavigationLink(destination: MatchDetailView(match: match)) {
                        MatchRowView(match: match)
                    }
                }
                .searchable(text: $searchText, prompt: "Search matches")
            }
            .navigationTitle("Live Matches")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateMatch = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateMatch) {
                CreateMatchView()
            }
            .onAppear {
                matchService.fetchMatches()
            }
        }
    }
}

struct MatchRowView: View {
    let match: Match
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(match.title)
                    .font(.headline)
                Spacer()
                Text(match.status.rawValue.capitalized)
                    .font(.caption)
                    .padding(4)
                    .background(statusColor)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            Text(match.gameType)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("\(match.currentPlayers)/\(match.maxPlayers)", systemImage: "person.2.fill")
                Spacer()
                Text(match.startTime, style: .relative)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch match.status {
        case .upcoming: return .blue
        case .inProgress: return .green
        case .completed: return .gray
        case .cancelled: return .red
        }
    }
}

struct MatchDetailView: View {
    let match: Match
    @StateObject private var matchService = MatchService()
    @State private var showingJoinAlert = false
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                    Text(match.title)
                        .font(.title)
                        .bold()
                    
                    Text(match.gameType)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    Text(match.description)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Match Info")
                        .font(.headline)
                    
                    InfoRow(title: "Status", value: match.status.rawValue.capitalized)
                    InfoRow(title: "Players", value: "\(match.currentPlayers)/\(match.maxPlayers)")
                    InfoRow(title: "Start Time", value: match.startTime.formatted())
                    InfoRow(title: "End Time", value: match.endTime.formatted())
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Settings")
                        .font(.headline)
                    
                    InfoRow(title: "Private", value: match.isPrivate ? "Yes" : "No")
                    InfoRow(title: "Allow Spectators", value: match.settings.allowSpectators ? "Yes" : "No")
                    InfoRow(title: "Auto Start", value: match.settings.autoStart ? "Yes" : "No")
                    InfoRow(title: "Min Players", value: "\(match.settings.minPlayers)")
                }
                
                Spacer()
                
                if !match.participants.contains("current_user_id") { // Replace with actual user ID
                    Button(action: { showingJoinAlert = true }) {
                        Text("Join Match")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: leaveMatch) {
                        Text("Leave Match")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Match Details")
        .alert("Join Match", isPresented: $showingJoinAlert) {
            if match.isPrivate {
                SecureField("Password", text: $password)
            }
            Button("Join", action: joinMatch)
            Button("Cancel", role: .cancel) { }
        } message: {
            if match.isPrivate {
                Text("Please enter the match password")
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func joinMatch() {
        Task {
            do {
                try await matchService.joinMatch(match.id ?? "", userId: "current_user_id") // Replace with actual user ID
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
    
    private func leaveMatch() {
        Task {
            do {
                try await matchService.leaveMatch(match.id ?? "", userId: "current_user_id") // Replace with actual user ID
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
} 