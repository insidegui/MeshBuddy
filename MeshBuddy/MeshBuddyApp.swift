import SwiftUI

@main
struct MeshBuddyApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MeshGradientDefinitionDocument()) { configuration in
            DocumentView(document: configuration.$document)
        }
    }
}
