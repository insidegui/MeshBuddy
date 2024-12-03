import SwiftUI

extension Color {
    var nsColor: NSColor { NSColor(self) }
}


extension NSColor {
    /// Text to create the equivalent `SwiftUI.Color` object in code
    var swiftUIInitializer: String {
        let opacity = self.alphaComponent.isOne ? "" : ", opacity: \(self.alphaComponent)"
        return "Color(red: \(self.redComponent.roundedValue), green: \(self.greenComponent.roundedValue), blue: \(self.blueComponent.roundedValue)\(opacity))"
    }
}


extension Bool {
    var asText: String {
        self ? "true" : "false"
    }
}


extension Gradient.ColorSpace {
    var asText: String {
        switch self {
        case .device: return ".device"
        case .perceptual: return ".perceptual"
        default: return ".device" // If some new value, just assume device
        }
    }
}


extension CGFloat {
    /// This float as a string rounded to `4` decimal places
    private var roundedString: String {
        String(format: "%.4f", self)
    }
    
    /// The basic rounded value of this float
    var roundedValue: String {
        if isOne { return "1" }
        if isZero { return "0" }
        
        return roundedString
    }
    
    /**
     Whether this float is equivalent to `1` after rounding.
     */
    var isOne: Bool {
        guard let double = Double(roundedString) else { return false }
        return Int(double) == 1
    }
    
    /**
     Whether this float is equivalent to `0` after rounding.
     */
    private var isZero: Bool {
        guard let double = Double(roundedString) else { return false }
        return double == 0
    }
}
