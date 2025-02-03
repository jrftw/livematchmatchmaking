//
//  EditProfileView.swift
//  LIVE Match - Matchmaking
//
//  No references to 'hex:' or '.toHex()'. Uses inline bridging for clan color.
//
import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

#if os(iOS) || os(visionOS)
import UIKit
#endif

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var profile: MyUserProfile
    @State private var savingInProgress = false
    
    @State private var newProfileImage: UIImage? = nil
    @State private var newBannerImage: UIImage? = nil
    @State private var showingProfilePicker = false
    @State private var showingBannerPicker = false
    
    public init(profile: MyUserProfile) {
        self._profile = State(initialValue: profile)
    }
    
    public var body: some View {
        NavigationView {
            Form {
                profileBannerSection()
                basicInfoSection()
                clanSection()
                tagsSection()
                
                Section {
                    Button("Save Changes") {
                        saveProfile()
                    }
                    .disabled(savingInProgress)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .sheet(isPresented: $showingProfilePicker) {
                #if os(iOS) || os(visionOS)
                ImagePicker(image: $newProfileImage)
                #endif
            }
            .sheet(isPresented: $showingBannerPicker) {
                #if os(iOS) || os(visionOS)
                ImagePicker(image: $newBannerImage)
                #endif
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

// MARK: - Subviews
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension EditProfileView {
    private func profileBannerSection() -> some View {
        Section("Profile & Banner") {
            HStack {
                if let pImage = newProfileImage {
                    Image(uiImage: pImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                } else if let urlStr = profile.profilePictureURL,
                          !urlStr.isEmpty,
                          let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Circle().fill(Color.gray.opacity(0.3))
                        case .success(let loaded):
                            loaded.resizable().scaledToFill()
                        case .failure:
                            Circle().fill(Color.gray.opacity(0.3))
                        @unknown default:
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                } else {
                    Circle().fill(Color.gray.opacity(0.3))
                        .frame(width: 70, height: 70)
                }
                Spacer()
                Button("Change Photo") {
                    showingProfilePicker = true
                }
            }
            
            HStack {
                if let bImage = newBannerImage {
                    Image(uiImage: bImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 60)
                        .cornerRadius(8)
                } else if let urlStr = profile.bannerURL,
                          !urlStr.isEmpty,
                          let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color.gray.opacity(0.3)
                        case .success(let loaded):
                            loaded.resizable().scaledToFill()
                        case .failure:
                            Color.gray.opacity(0.3)
                        @unknown default:
                            Color.gray.opacity(0.3)
                        }
                    }
                    .frame(height: 60)
                    .cornerRadius(8)
                } else {
                    Color.gray.opacity(0.3)
                        .frame(height: 60)
                        .cornerRadius(8)
                }
                Spacer()
                Button("Change Banner") {
                    showingBannerPicker = true
                }
            }
        }
    }
    
    private func basicInfoSection() -> some View {
        Section("Basic Info") {
            TextField("Username", text: $profile.username)
            TextField("Display Name", text: $profile.displayName)
            
            TextField("Bio", text: bindingFor(\.bio))
            TextField("Phone Number", text: bindingFor(\.phoneNumber))
            Toggle("Show Phone Publicly", isOn: $profile.phonePublicly)
            
            TextField("Birthday (YYYY-MM-DD)", text: bindingFor(\.birthday))
            Toggle("Show Birthday Publicly", isOn: $profile.birthdayPublicly)
            
            TextField("Email", text: bindingFor(\.email))
            Toggle("Show Email Publicly", isOn: $profile.emailPublicly)
        }
    }
    
    private func clanSection() -> some View {
        Section("Clan") {
            TextField("Clan Tag", text: bindingFor(\.clanTag))
            ColorPicker("Clan Color", selection: clanColorBinding, supportsOpacity: false)
        }
    }
    
    private func tagsSection() -> some View {
        Section("Tags") {
            TextField("Tags (comma separated)", text: Binding<String>(
                get: {
                    profile.tags.joined(separator: ", ")
                },
                set: {
                    let arr = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    profile.tags = arr.filter { !$0.isEmpty }
                }
            ))
        }
    }
}

// MARK: - Save Logic
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension EditProfileView {
    private func saveProfile() {
        savingInProgress = true
        
        if let newPic = newProfileImage {
            uploadImage(newPic, path: "profileImages") { url in
                profile.profilePictureURL = url
                if let newBan = newBannerImage {
                    uploadImage(newBan, path: "bannerImages") { bUrl in
                        profile.bannerURL = bUrl
                        finalizeSave()
                    }
                } else {
                    finalizeSave()
                }
            }
        } else if let newBan = newBannerImage {
            uploadImage(newBan, path: "bannerImages") { bUrl in
                profile.bannerURL = bUrl
                finalizeSave()
            }
        } else {
            finalizeSave()
        }
    }
    
    private func finalizeSave() {
        guard let uid = Auth.auth().currentUser?.uid else {
            savingInProgress = false
            dismiss()
            return
        }
        let ref = FirebaseManager.shared.db.collection("users").document(uid)
        
        do {
            try ref.setData(from: profile, merge: true) { _ in
                savingInProgress = false
                dismiss()
            }
        } catch {
            savingInProgress = false
            dismiss()
        }
    }
    
    private func uploadImage(_ image: UIImage, path: String, completion: @escaping (String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        let storageRef = Storage.storage().reference().child("\(path)/\(uid)_\(UUID().uuidString).jpg")
        storageRef.putData(data, metadata: nil) { _, error in
            if let _ = error {
                completion(nil)
            } else {
                storageRef.downloadURL { url, _ in
                    completion(url?.absoluteString)
                }
            }
        }
    }
}

// MARK: - Helpers
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension EditProfileView {
    private func bindingFor(_ keyPath: WritableKeyPath<MyUserProfile, String?>) -> Binding<String> {
        Binding<String>(
            get: { profile[keyPath: keyPath] ?? "" },
            set: { profile[keyPath: keyPath] = $0 }
        )
    }
    
    #if os(iOS) || os(visionOS)
    private var clanColorBinding: Binding<Color> {
        Binding<Color>(
            get: {
                guard let hex = profile.clanColorHex else { return .blue }
                return Color(uiColorFromHex(hex) ?? .blue)
            },
            set: { newVal in
                profile.clanColorHex = hexFromColor(newVal)
            }
        )
    }
    
    private func uiColorFromHex(_ hex: String) -> UIColor? {
        var h = hex
        if h.hasPrefix("#") { h.removeFirst() }
        if h.count == 3 {
            h = h.map { "\($0)\($0)" }.joined()
        }
        guard h.count == 6 else { return nil }
        
        var num: UInt64 = 0
        let scanner = Scanner(string: h)
        guard scanner.scanHexInt64(&num) else { return nil }
        
        let r = (num & 0xFF0000) >> 16
        let g = (num & 0x00FF00) >> 8
        let b = (num & 0x0000FF)
        return UIColor(
            red: CGFloat(r)/255.0,
            green: CGFloat(g)/255.0,
            blue: CGFloat(b)/255.0,
            alpha: 1.0
        )
    }
    
    private func hexFromColor(_ color: Color) -> String {
        let ui = UIColor(color)
        var rF: CGFloat = 0, gF: CGFloat = 0, bF: CGFloat = 0, aF: CGFloat = 0
        guard ui.getRed(&rF, green: &gF, blue: &bF, alpha: &aF) else { return "#0000FF" }
        
        let r = Int(rF * 255)
        let g = Int(gF * 255)
        let b = Int(bF * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    #else
    private var clanColorBinding: Binding<Color> {
        .constant(.blue)
    }
    #endif
}
