//
//  SplashView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Displays a modern splash screen, then transitions to ContentView after a short delay.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct SplashView: View {
    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - State
    @State private var isActive = false
    @State private var progress: Float = 0.0
    
    // MARK: - Init
    init() {
        print("[SplashView] init called. Initial isActive: \(isActive), progress: \(progress)")
    }
    
    // MARK: - Body
    var body: some View {
        let _ = print("[SplashView] body invoked. Checking isActive: \(isActive)")
        
        if isActive {
            let _ = print("[SplashView] isActive == true. Navigating to ContentView.")
            ContentView()
                .onAppear {
                    print("[SplashView] ContentView onAppear triggered.")
                }
        } else {
            let _ = print("[SplashView] isActive == false. Showing SplashView UI.")
            
            ZStack {
                let _ = print("[SplashView] Building background gradient.")
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    let _ = print("[SplashView] Adding splash icon and text labels.")
                    
                    // Make sure this exact name matches your asset catalog entry
                    Image("LIVEMatchmakericon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 10)
                    
                    Text("LIVE Match - Matchmaking - The Ultimate Matchmaking App")
                        .font(.headline)
                    
                    Text("For viewers, LIVE creators, gamers, communities and businesses to easily collaborate when scheduling and creating events. No more confusion or missed events!")
                        .font(.subheadline)
                    
                    Text("Created by @JrFTW")
                        .font(.subheadline)
                    
                    Text("© 2025 Infinitum Imagery LLC & Infinitum_US\nAll rights reserved.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                    
                    let _ = print("[SplashView] Adding linear ProgressView with progress: \(progress)")
                    ProgressView(value: progress, total: 100)
                        .frame(width: 200)
                        .progressViewStyle(LinearProgressViewStyle())
                    
                    let _ = print("[SplashView] Adding circular ProgressView.")
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .padding()
            }
            .onAppear {
                print("[SplashView] onAppear triggered. Starting animateProgress(), scheduling transition.")
                animateProgress()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    print("[SplashView] 2.5 second delay completed. Setting isActive to true.")
                    isActive = true
                }
            }
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: LinearGradient {
        print("[SplashView] backgroundGradient computed. colorScheme: \(colorScheme == .dark ? "dark" : "light")")
        
        if colorScheme == .dark {
            return LinearGradient(
                gradient: Gradient(colors: [.black, .gray]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [.white, Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // MARK: - Animate Progress
    private func animateProgress() {
        print("[SplashView] animateProgress called. Setting up timer for progress updates.")
        
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if progress < 100 {
                progress += 1
                print("[SplashView] animateProgress timer tick => progress: \(progress)")
            } else {
                print("[SplashView] animateProgress reached 100. Invalidating timer.")
                timer.invalidate()
            }
        }
    }
}
