import SwiftUI

@main
struct MeshBuddyApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MeshGradientDefinitionDocument()) { configuration in
            ContentView(document: configuration.$document)
        }
    }
}
