// MARK: - NewsView.swift
import SwiftUI

// MARK: - Announcement Model
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct Announcement: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let date: String
    public let time: String
    public let content: String
    public let images: [String]?
    public let links: [String]?
    
    enum CodingKeys: String, CodingKey {
        case title, date, time, content, images, links
    }
    
    public init(
        title: String,
        date: String,
        time: String,
        content: String,
        images: [String]? = nil,
        links: [String]? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.time = time
        self.content = content
        self.images = images
        self.links = links
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.date = try container.decode(String.self, forKey: .date)
        self.time = try container.decode(String.self, forKey: .time)
        self.content = try container.decode(String.self, forKey: .content)
        self.images = try container.decodeIfPresent([String].self, forKey: .images)
        self.links = try container.decodeIfPresent([String].self, forKey: .links)
        self.id = UUID()
    }
}

// MARK: - AnnouncementsWrapper
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AnnouncementsWrapper: Codable {
    public let announcements: [Announcement]
}

// MARK: - AnnouncementsViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class AnnouncementsViewModel: ObservableObject {
    @Published public var announcements: [Announcement] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    public init() {}
    
    @MainActor
    public func fetchAnnouncements() async {
        isLoading = true
        errorMessage = nil
        let urlString = "https://jrftw.github.io/livematchmakingannouncements/Announcements.json"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(AnnouncementsWrapper.self, from: data)
            announcements = decoded.announcements
        } catch {
            errorMessage = "Failed to load announcements."
        }
        
        isLoading = false
    }
}

// MARK: - NewsView
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct NewsView: View {
    @StateObject private var viewModel = AnnouncementsViewModel()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("News")
                .font(.largeTitle)
            
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                if viewModel.announcements.isEmpty {
                    Text("No announcements available.")
                } else {
                    List(viewModel.announcements) { announcement in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(announcement.title)
                                .font(.headline)
                            Text("Date: \(announcement.date) | Time: \(announcement.time)")
                                .font(.subheadline)
                            Text(announcement.content)
                                .font(.body)
                            if let images = announcement.images, !images.isEmpty {
                                Text("Images: \(images.joined(separator: ", "))")
                                    .font(.caption)
                            }
                            if let links = announcement.links, !links.isEmpty {
                                Text("Links: \(links.joined(separator: ", "))")
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .padding()
        .task {
            await viewModel.fetchAnnouncements()
        }
    }
}
