//
//  BusinessTogglesSectionView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Toggles for BusinessSubType(s).
//
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct BusinessTogglesSectionView: View {
    public let allBusinessTypes: [BusinessSubType]
    @Binding public var selectedBusinessTypes: Set<BusinessSubType>
    
    public init(allBusinessTypes: [BusinessSubType],
                selectedBusinessTypes: Binding<Set<BusinessSubType>>) {
        self.allBusinessTypes = allBusinessTypes
        self._selectedBusinessTypes = selectedBusinessTypes
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose Business Subtypes").font(.headline)
            ForEach(allBusinessTypes, id: \.self) { subType in
                Toggle(isOn: Binding<Bool>(
                    get: { selectedBusinessTypes.contains(subType) },
                    set: { newValue in
                        if newValue { selectedBusinessTypes.insert(subType) }
                        else { selectedBusinessTypes.remove(subType) }
                    }
                )) {
                    Text(subType.rawValue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
