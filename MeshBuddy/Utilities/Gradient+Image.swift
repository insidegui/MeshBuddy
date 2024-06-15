import SwiftUI
import UniformTypeIdentifiers

enum ImageRenderingError: LocalizedError {
    case destination
    case cgImage
    case finalize

    var failureReason: String? {
        switch self {
        case .destination:
            return NSLocalizedString("Failed to create image destination.", comment: "Image export error")
        case .cgImage:
            return NSLocalizedString("Failed to render a CGImage.", comment: "Image export error")
        case .finalize:
            return NSLocalizedString("Failed to finalize image destination.", comment: "Image export error")
        }
    }
}

@MainActor
extension MeshGradientDefinition {
    func renderImage(of type: UTType, to outputURL: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, type.identifier as CFString, 1, nil) else {
            throw ImageRenderingError.destination
        }

        try renderImage(of: type, to: destination)
    }

    func renderImageData(of type: UTType) throws -> Data {
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            throw ImageRenderingError.destination
        }
        guard let destination = CGImageDestinationCreateWithData(data, type.identifier as CFString, 1, nil) else {
            throw ImageRenderingError.destination
        }

        try renderImage(of: type, to: destination)

        return data as Data
    }

    func renderImage(of type: UTType, to destination: CGImageDestination) throws {
        let image = try renderCGImage()

        CGImageDestinationAddImage(destination, image, nil)

        guard CGImageDestinationFinalize(destination) else {
            throw ImageRenderingError.cgImage
        }
    }

    func renderCGImage() throws -> CGImage {
        let renderView = MeshGradient(self)
            .frame(
                width: CGFloat(self.viewPortWidth),
                height: CGFloat(self.viewPortHeight)
            )
        
        let imageRenderer = ImageRenderer(content: renderView)

        guard let image = imageRenderer.cgImage else {
            throw ImageRenderingError.cgImage
        }

        return image
    }
}

extension ImageRenderer: @unchecked @retroactive Sendable { }
