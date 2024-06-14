import SwiftUI

struct DocumentConfigurationSheet: View {
    @Binding var definition: MeshGradientDefinition

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
                Spacer()

                Button("Create") {
                    definition = MeshGradientDefinition(from: template)
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
    @Previewable @State var definition = MeshGradientDefinition.default

    DocumentConfigurationSheet(definition: $definition)
}
#endif
