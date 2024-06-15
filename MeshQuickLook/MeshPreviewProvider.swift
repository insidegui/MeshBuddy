import Cocoa
import Quartz
import OSLog

private let logger = Logger(subsystem: "codes.rambo.MeshBuddyQuickLook", category: "MeshPreviewProvider")

@objc(MeshPreviewProvider)
final class MeshPreviewProvider: QLPreviewProvider, QLPreviewingController {
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let path = request.fileURL.path

        do {
            logger.debug("Preview requested for \(request.fileURL.path)")

            let data = try Data(contentsOf: request.fileURL)
            let definition = try MeshGradientDefinitionDocument(data: data).definition

            let pngData = try await definition.renderImageData(of: .png)

            let reply = QLPreviewReply(dataOfContentType: .png, contentSize: definition.bounds.size) { reply in
                return pngData
            }

            return reply
        } catch {
            logger.debug("Preview failed for \(path): \(error, privacy: .public)")

            throw error
        }
    }
}
