//
//  SoloTogglesSectionView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Toggles for SoloSubType(s).
//
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct SoloTogglesSectionView: View {
    public let allSoloTypes: [SoloSubType]
    @Binding public var selectedSoloTypes: Set<SoloSubType>
    
    public init(allSoloTypes: [SoloSubType],
                selectedSoloTypes: Binding<Set<SoloSubType>>) {
        self.allSoloTypes = allSoloTypes
        self._selectedSoloTypes = selectedSoloTypes
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose Solo Subtypes").font(.headline)
            ForEach(allSoloTypes, id: \.self) { subType in
                Toggle(isOn: Binding<Bool>(
                    get: { selectedSoloTypes.contains(subType) },
                    set: { newValue in
                        if newValue {
                            selectedSoloTypes.insert(subType)
                        } else {
                            selectedSoloTypes.remove(subType)
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
