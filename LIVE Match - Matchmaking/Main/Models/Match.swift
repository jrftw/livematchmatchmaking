import Foundation

struct Match: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var creatorID: String
    var creatorName: String
    var gameType: String
    var maxPlayers: Int
    var currentPlayers: Int
    var startTime: Date
    var endTime: Date
    var status: MatchStatus
    var participants: [String] // User IDs
    var settings: MatchSettings
    var isPrivate: Bool
    var password: String?
    var createdAt: Date
    var updatedAt: Date
    
    enum MatchStatus: String, Codable {
        case upcoming
        case inProgress
        case completed
        case cancelled
    }
}

struct MatchSettings: Codable {
    var allowSpectators: Bool
    var autoStart: Bool
    var minPlayers: Int
    var customRules: [String: String]
} 
