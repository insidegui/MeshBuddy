import SwiftUI

@main
struct MeshBuddyApp: App {
    private let updateManager = AppUpdateManager()

    var body: some Scene {
        DocumentGroup(newDocument: MeshGradientDefinitionDocument()) { configuration in
            DocumentView(document: configuration.$document)
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesButton(manager: updateManager)
            }
        }
    }
}
