import SwiftUI

struct DocumentView: View {
    @Environment(\.undoManager)
    private var undoManager

    @Binding var document: MeshGradientDefinitionDocument

    @State private var showingConfigurationSheet = false

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        MeshGradientEditor(gradient: undoBinding)
            .focusable()
            .focusEffectDisabled()
            .task {
                showingConfigurationSheet = document.needsSetup
            }
            .sheet(isPresented: $showingConfigurationSheet) {
                /// Close document if configuration sheet is closed without clicking the Done button.
                if document.needsSetup {
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
            } content: {
                DocumentSetupSheet(document: $document)
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

            guard newValue != oldValue else { return }

            undoManager.registerUndo(withTarget: NSApplication.shared) { target in
                self.document.definition = oldValue
            }
        }
    }

}

