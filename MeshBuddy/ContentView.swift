import SwiftUI

struct ContentView: View {
    @Environment(\.undoManager)
    private var undoManager

    @Binding var document: MeshGradientDefinitionDocument

    @State private var showingConfigurationSheet = false

    var body: some View {
        MeshGradientEditor(gradient: undoBinding)
            .task {
                if document.definition.width <= 0 || document.definition.height <= 0 {
                    showingConfigurationSheet = true
                }
            }
            .sheet(isPresented: $showingConfigurationSheet) {
                DocumentConfigurationSheet(definition: $document.definition)
            }
    }

    /// This binding is sent to the editor view, so that every change performed creates a snapshot
    /// of the current gradient definition state, enabling undo/redo by just registering the gradient state
    /// with the undo manager as it's changed.
    private var undoBinding: Binding<MeshGradientDefinition> {
        Binding {
            return document.definition
        } set: { newValue in
            guard let undoManager else {
                self.document.definition = newValue
                return
            }

            let oldValue = self.document.definition

            self.document.definition = newValue

            undoManager.registerUndo(withTarget: NSApplication.shared) { target in
                self.document.definition = oldValue
            }
        }
    }
}

