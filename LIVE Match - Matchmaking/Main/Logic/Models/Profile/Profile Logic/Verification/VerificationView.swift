// MARK: VerificationView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct VerificationView: View {
    @ObservedObject var vm = VerificationManager()
    @State private var desiredColor = Color.blue
    @State private var userToVerify = ""
    @State private var showingSafari = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            Text("Request Verification")
                .font(.title2)
            TextField("Enter your username", text: $userToVerify)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            ColorPicker("Pick Verification Color", selection: $desiredColor)
                .padding()
            Button("Request Verification") {
                vm.requestVerification(for: userToVerify, colorChoice: desiredColor)
                showingSafari = true
            }
            .padding()
            Spacer()
        }
        .onAppear {
            vm.loadPreVerified()
        }
        .navigationTitle("Verification")
        #if os(iOS) || os(visionOS)
        .sheet(isPresented: $showingSafari) {
            SafariSheet()
        }
        #else
        .onChange(of: showingSafari) { newVal in
            if newVal {
                if let url = URL(string: "https://forms.gle/F2mcUX597PyYiJDm6") {
                    NSWorkspace.shared.open(url)
                    showingSafari = false
                }
            }
        }
        #endif
    }
}

#if os(iOS) || os(visionOS)
import SafariServices

@available(iOS 15.6, visionOS 2.0, *)
private struct SafariSheet: View {
    var body: some View {
        SafariViewWrapper(url: URL(string: "https://forms.gle/F2mcUX597PyYiJDm6")!)
            .edgesIgnoringSafeArea(.all)
    }
}

@available(iOS 15.6, visionOS 2.0, *)
private struct SafariViewWrapper: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
#endif
