import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let meshDefinition = UTType(exportedAs: "codes.rambo.MeshGradientDocument", conformingTo: .propertyList)
}

enum DocumentFileError: LocalizedError {
    case invalidVersion
    case unableToLoadData
    case unableToSaveData

    var failureReason: String? {
        switch self {
        case .invalidVersion:
            return "The file is not compatible with this version of the app, please update the app and try again."
        case .unableToLoadData:
            return "Unable to load data from the file."
        case .unableToSaveData:
            return "Unable to save data to the file."
        }
    }
}

/// Wrapper type for encoding/decoding documents.
struct DocumentFileContainer: Codable {
    /// The document file version produced by this version of the app.
    /// Any breaking changes to document data will require incrementing this version.
    static let currentVersion = 1

    /// The document version when the file was saved.
    /// When decoding, if the encoded version is greater than ``currentVersion``,
    /// an appropriate error is thrown.
    var version = DocumentFileContainer.currentVersion

    var definition: MeshGradientDefinition

    init(definition: MeshGradientDefinition) {
        self.definition = definition
    }

    enum CodingKeys: String, CodingKey {
        case version, definition
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(Int.self, forKey: .version)

        guard version <= DocumentFileContainer.currentVersion else {
            throw DocumentFileError.invalidVersion
        }

        self.definition = try container.decode(MeshGradientDefinition.self, forKey: .definition)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.version, forKey: .version)
        try container.encode(self.definition, forKey: .definition)
    }
}

// MARK: - Encoding / Decoding Support

extension PropertyListDecoder {
    static let meshDefinition = PropertyListDecoder()
}
extension PropertyListEncoder {
    static let meshDefinition = PropertyListEncoder()
}

extension Color: Codable {

    public enum CodingKeys: String, CodingKey {
        case r, g, b, a
        case catalog
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let name = try? container.decodeIfPresent(String.self, forKey: .catalog) {
            if name == "primary" {
                self = .primary
            } else if name == "secondary" {
                self = .secondary
            } else {
                self = .black
            }
        } else {
            let r = try container.decode(CGFloat.self, forKey: .r)
            let g = try container.decode(CGFloat.self, forKey: .g)
            let b = try container.decode(CGFloat.self, forKey: .b)
            let a = try container.decode(CGFloat.self, forKey: .a)

            let underlyingColor = NSColor(displayP3Red: r, green: g, blue: b, alpha: a)

            self.init(underlyingColor)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let values = rgba

        try container.encode(values.red, forKey: .r)
        try container.encode(values.green, forKey: .g)
        try container.encode(values.blue, forKey: .b)
        try container.encode(values.alpha, forKey: .a)
    }

}

public extension NSColor {
    typealias RGBAValue = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

    var rgba: RGBAValue {
        guard let converted = usingColorSpace(.displayP3) else {
            assertionFailure("Failed to convert colorspace")
            return (0,0,0,0)
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        converted.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}

public extension Color {
    typealias RGBAValue = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

    var rgba: RGBAValue { NSColor(self).rgba }
}

extension Gradient.ColorSpace: Codable {
    private static let perceptualEncodedValue = "perceptual"
    private static let deviceEncodedValue = "device"

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        if self == .perceptual {
            try container.encode(Self.perceptualEncodedValue)
        } else {
            try container.encode(Self.deviceEncodedValue)
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            if value == Self.perceptualEncodedValue {
                self = .perceptual
            } else {
                self = .device
            }
        } else {
            self = .device
        }
    }
}
