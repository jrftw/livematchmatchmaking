//
//  MyBracketsListView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: MyBracketsListView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays all brackets created by the current user, allowing edit/duplicate/delete.

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct MyBracketsListView: View {
    @StateObject private var vm = MyBracketsViewModel()
    
    var body: some View {
        List {
            if vm.brackets.isEmpty {
                Text("You haven't created any brackets yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(vm.brackets) { bracket in
                    NavigationLink(destination: MyBracketDetailView(bracket: bracket)) {
                        VStack(alignment: .leading) {
                            Text(bracket.bracketName)
                                .font(.headline)
                            Text("Platform: \(bracket.platform)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("My Brackets")
        .onAppear {
            vm.fetchMyBrackets()
        }
    }
}
