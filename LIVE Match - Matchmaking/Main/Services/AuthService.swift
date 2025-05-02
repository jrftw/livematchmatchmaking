import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var error: Error?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        auth.addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.fetchUser(user.uid)
            } else {
                self?.currentUser = nil
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            try await fetchUser(result.user.uid)
        } catch {
            self.error = error
            throw error
        }
    }
    
    func signUp(email: String, password: String, username: String) async throws {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = User(
                id: result.user.uid,
                email: email,
                username: username,
                createdAt: Date(),
                updatedAt: Date()
            )
            try await db.collection("users").document(user.id).setData(from: user)
            self.currentUser = user
        } catch {
            self.error = error
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try auth.signOut()
            currentUser = nil
        } catch {
            self.error = error
            throw error
        }
    }
    
    private func fetchUser(_ userId: String) async throws {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            currentUser = try document.data(as: User.self)
        } catch {
            self.error = error
            throw error
        }
    }
}

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let email: String
    let username: String
    let createdAt: Date
    let updatedAt: Date
} 
