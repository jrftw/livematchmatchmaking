#if canImport(UIKit)
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
        var rF: CGFloat = 0, gF: CGFloat = 0, bF: CGFloat = 0, aF: CGFloat = 0
        guard getRed(&rF, green: &gF, blue: &bF, alpha: &aF) else { return nil }
        return String(format: "#%02X%02X%02X", Int(rF * 255), Int(gF * 255), Int(bF * 255))
    }
}

#elseif canImport(AppKit)
import AppKit

public extension NSColor {
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
            calibratedRed: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
    
    func toHex() -> String? {
        var rF: CGFloat = 0, gF: CGFloat = 0, bF: CGFloat = 0, aF: CGFloat = 0
        guard let rgbColor = usingColorSpace(NSColorSpace.deviceRGB) else { return nil }
        guard rgbColor.getRed(&rF, green: &gF, blue: &bF, alpha: &aF) else { return nil }
        return String(format: "#%02X%02X%02X", Int(rF * 255), Int(gF * 255), Int(bF * 255))
    }
}
#endif
