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

extension MeshGradientDefinition {
    func renderImage(of type: UTType, to outputURL: URL) async throws {
        guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, type.identifier as CFString, 1, nil) else {
            throw ImageRenderingError.destination
        }

        try await renderImage(of: type, to: destination)
    }

    func renderImage(of type: UTType, to destination: CGImageDestination) async throws {
        let image = try await renderCGImage()

        CGImageDestinationAddImage(destination, image, nil)

        guard CGImageDestinationFinalize(destination) else {
            throw ImageRenderingError.cgImage
        }
    }

    func renderCGImage() async throws -> CGImage {
        let renderView = await MeshGradient(self)
            .frame(
                width: CGFloat(self.viewPortWidth),
                height: CGFloat(self.viewPortHeight)
            )
        
        let imageRenderer = await ImageRenderer(content: renderView)

        guard let image = await imageRenderer.cgImage else {
            throw ImageRenderingError.cgImage
        }

        return image
    }
}

extension ImageRenderer: @unchecked @retroactive Sendable { }
