import SwiftUI

struct DocumentConfigurationSheet: View {
    @Binding var definition: MeshGradientDefinition

    @State private var editingDefinition = MeshGradientDefinition(width: 5, height: 5, backgroundColor: .indigo)

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        MeshGradientInspector(
            gradient: $editingDefinition,
            selectedPoints: .constant([]),
            documentConfiguration: true
        )
        .frame(minWidth: 320, maxWidth: .infinity, minHeight: 340, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()

                Button("Create") {
                    definition = editingDefinition
                    dismiss()
                }
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var definition = MeshGradientDefinition(width: 4, height: 4)

    DocumentConfigurationSheet(definition: $definition)
}
#endif
