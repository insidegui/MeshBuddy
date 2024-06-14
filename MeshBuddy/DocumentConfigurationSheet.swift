import SwiftUI

struct DocumentConfigurationSheet: View {
    @Binding var definition: MeshGradientDefinition

    @State private var template = MeshGradientDefinition(width: 5, height: 5, backgroundColor: .indigo)

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

extension MeshGradientDefinition {
    init(from template: Self) {
        self.init(
            width: template.width,
            height: template.height,
            smoothsColors: template.smoothsColors,
            backgroundColor: template.backgroundColor,
            colorSpace: template.colorSpace
        )
    }
}

#if DEBUG
#Preview {
    @Previewable @State var definition = MeshGradientDefinition(width: 4, height: 4)

    DocumentConfigurationSheet(definition: $definition)
}
#endif
