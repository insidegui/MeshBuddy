import SwiftUI

extension Color {
    func swiftUIInitializer(in environmentValues: EnvironmentValues) -> String {
        let resolvedColor = self.resolve(in: environmentValues)
        let opacity = resolvedColor.opacity == 1 ? "" : ", opacity: \(resolvedColor.opacity)"

        return "Color(red: \(resolvedColor.red.roundedValue), green: \(resolvedColor.green.roundedValue), blue: \(resolvedColor.blue.roundedValue)\(opacity))"
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


extension Float {
    /// This float as a string rounded to `4` decimal places
    private var roundedString: String {
        String(format: "%.3f", self)
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
    private var isOne: Bool {
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
