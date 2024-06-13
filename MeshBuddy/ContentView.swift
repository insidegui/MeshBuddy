import SwiftUI

struct ContentView: View {
    @Binding var document: MeshGradientDefinitionDocument

    @State private var showingConfigurationSheet = false

    var body: some View {
        MeshGradientEditor(gradient: $document.definition)
            .task {
                if document.definition.width <= 0 || document.definition.height <= 0 {
                    showingConfigurationSheet = true
                }
            }
            .id(document.definition.id)
            .sheet(isPresented: $showingConfigurationSheet) {
                DocumentConfigurationSheet(definition: $document.definition)
            }
    }
}

