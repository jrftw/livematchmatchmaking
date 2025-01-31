// MARK: CommunityTogglesSectionView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CommunityTogglesSectionView: View {
    public let allCommunityTypes: [CommunitySubType]
    @Binding public var selectedCommunityTypes: Set<CommunitySubType>
    
    public init(allCommunityTypes: [CommunitySubType],
                selectedCommunityTypes: Binding<Set<CommunitySubType>>) {
        self.allCommunityTypes = allCommunityTypes
        self._selectedCommunityTypes = selectedCommunityTypes
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose Community Subtypes").font(.headline)
            ForEach(allCommunityTypes, id: \.self) { subType in
                Toggle(isOn: Binding<Bool>(
                    get: { selectedCommunityTypes.contains(subType) },
                    set: { newValue in
                        if newValue {
                            selectedCommunityTypes.insert(subType)
                        } else {
                            selectedCommunityTypes.remove(subType)
                        }
                    }
                )) {
                    Text(subType.rawValue.capitalized)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
