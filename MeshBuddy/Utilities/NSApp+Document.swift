import SwiftUI

extension NSApplication {
    var currentDocumentWindow: NSWindow? {
        NSDocumentController.shared
            .currentDocument?
            .windowControllers
            .first?
            .window
        ?? NSApp.keyWindow
        ?? NSApp.mainWindow
    }

    var currentDocumentFileName: String? {
        NSDocumentController.shared
            .currentDocument?
            .fileURL?
            .deletingPathExtension()
            .lastPathComponent
    }
}
