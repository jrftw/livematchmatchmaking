// MARK: - UIColor+Extensions.swift
// Helps converting Color <-> UIColor with hex. iOS / visionOS only.

import UIKit

public extension UIColor {
    convenience init?(hex: String) {
        var normalized = hex
        if normalized.hasPrefix("#") {
            normalized.removeFirst()
        }
        if normalized.count == 3 {
            normalized = normalized.map { "\($0)\($0)" }.joined()
        }
        guard normalized.count == 6 else { return nil }
        
        let scanner = Scanner(string: normalized)
        var hexNum: UInt64 = 0
        guard scanner.scanHexInt64(&hexNum) else { return nil }
        
        let r = (hexNum & 0xFF0000) >> 16
        let g = (hexNum & 0x00FF00) >> 8
        let b = (hexNum & 0x0000FF)
        
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
    
    func toHex() -> String? {
        var rF: CGFloat = 0
        var gF: CGFloat = 0
        var bF: CGFloat = 0
        var aF: CGFloat = 0
        guard getRed(&rF, green: &gF, blue: &bF, alpha: &aF) else { return nil }
        
        let r = Int(rF * 255)
        let g = Int(gF * 255)
        let b = Int(bF * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
