import SwiftUI
import UniformTypeIdentifiers
import Observation

@MainActor
@Observable final class ImageExporter {
    func runExportPanel(for gradient: MeshGradientDefinition) async {
        guard let window = NSApp.currentDocumentWindow else {
            assertionFailure("Couldn't find any window for the save panel. WAT?!")
            return
        }

        let savePanel = NSSavePanel()
        savePanel.identifier = NSUserInterfaceItemIdentifier("ImageExport")
        savePanel.showsContentTypes = true
        savePanel.allowedContentTypes = [.png, .jpeg, .heic]
        if let fileName = NSApp.currentDocumentFileName {
            savePanel.nameFieldStringValue = fileName
        }

        guard await savePanel.beginSheetModal(for: window) == .OK, let url = savePanel.url else { return }

        guard let contentType = savePanel.currentContentType else {
            assertionFailure("Save panel is missing a UTType for the destination file")
            return
        }

        do {
            try await export(gradient, to: url, type: contentType)
        } catch {
            NSApp.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
        }
    }

    func export(_ gradient: MeshGradientDefinition, to url: URL, type: UTType) async throws {
        try await gradient.renderImage(of: type, to: url)
    }
}
