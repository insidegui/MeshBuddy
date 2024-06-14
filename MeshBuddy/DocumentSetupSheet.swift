import SwiftUI

struct DocumentSetupSheet: View {
    @Binding var document: MeshGradientDefinitionDocument

    @State private var template = MeshGradientDefinition.default

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        MeshGradientInspector(
            gradient: $template,
            selectedPoints: .constant([]),
            documentConfiguration: true
        )
        .frame(minWidth: 320, maxWidth: .infinity, minHeight: 340, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Create") {
                    document.needsSetup = false
                    document.definition = MeshGradientDefinition(from: template)
                    
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .controlSize(.large)
            .padding()
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var document = MeshGradientDefinitionDocument(definition: .default)

    DocumentSetupSheet(document: $document)
}
#endif
