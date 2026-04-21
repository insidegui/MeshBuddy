import SwiftUI
import Observation

@main
struct MeshBuddyApp: App {
    @State private var updateManager = AppUpdateManager()

    init() {
        AcceptsFirstMouseSwizzle.install()
    }

    var body: some Scene {
        DocumentGroup(newDocument: MeshGradientDefinitionDocument()) { configuration in
            DocumentView(document: configuration.$document)
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesButton(manager: updateManager)
            }

            ColorPaletteCommands()
        }
        
        SwiftCodeWindow()
    }
}

private struct ColorPaletteCommands: Commands {
    @FocusedValue(ColorPaletteCommandContext.self)
    private var colorPaletteCommandContext

    var body: some Commands {
        CommandGroup(after: .pasteboard) {
            Button {
                colorPaletteCommandContext?.duplicateSelection()
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
            .keyboardShortcut("d", modifiers: .command)
            .disabled(!(colorPaletteCommandContext?.canDuplicate ?? false))
        }
    }
}

@MainActor
@Observable final class ColorPaletteCommandContext {
    var canDuplicate = false
    var duplicateSelection: () -> Void = {}
}
