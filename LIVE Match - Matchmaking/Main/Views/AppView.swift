import SwiftUI

struct AppView: View {
    @StateObject private var authService = AuthService()
    @State private var showingSignIn = false
    @State private var showingSignUp = false
    
    var body: some View {
        Group {
            if authService.currentUser != nil {
                TabView {
                    MatchListView()
                        .tabItem {
                            Label("Matches", systemImage: "gamecontroller")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("LIVE Match")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Connect with players and create matches")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: { showingSignIn = true }) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Button(action: { showingSignUp = true }) {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding()
                .sheet(isPresented: $showingSignIn) {
                    SignInView()
                }
                .sheet(isPresented: $showingSignUp) {
                    SignUpView()
                }
            }
        }
        .environmentObject(authService)
    }
}

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }
                
                Section {
                    Button(action: signIn) {
                        HStack {
                            Spacer()
                            Text("Sign In")
                                .bold()
                            Spacer()
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                }
            }
            .navigationTitle("Sign In")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func signIn() {
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                }
                
                Section {
                    Button(action: signUp) {
                        HStack {
                            Spacer()
                            Text("Create Account")
                                .bold()
                            Spacer()
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || username.isEmpty)
                }
            }
            .navigationTitle("Create Account")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func signUp() {
        Task {
            do {
                try await authService.signUp(email: email, password: password, username: username)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if let user = authService.currentUser {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(user.username)
                                .font(.title2)
                                .bold()
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section {
                    Button(role: .destructive, action: { showingSignOutAlert = true }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    try? authService.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
} 