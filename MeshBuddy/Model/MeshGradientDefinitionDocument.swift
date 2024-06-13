import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let meshDefinition = UTType(exportedAs: "codes.rambo.MeshGradientDocument", conformingTo: .propertyList)
}

struct MeshGradientDefinitionDocument: FileDocument {
    var definition: MeshGradientDefinition

    init(definition: MeshGradientDefinition = .init(width: 0, height: 0, backgroundColor: .white)) {
        self.definition = definition
    }

    static var readableContentTypes: [UTType] { [.meshDefinition] }

    init(configuration: ReadConfiguration) throws {
        guard let contents = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "The file has no content."])
        }

        let definition = try PropertyListDecoder.meshDefinition.decode(MeshGradientDefinition.self, from: contents)

        self.init(definition: definition)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try PropertyListEncoder.meshDefinition.encode(definition)
        return FileWrapper(regularFileWithContents: data)
    }

}

// MARK: - Encoding / Decoding

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

    public init(from decoder: Decoder) throws {
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

    public func encode(to encoder: Encoder) throws {
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
