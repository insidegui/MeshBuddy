import SwiftUI

struct MeshGradientInspector: View {
    @Binding var gradient: MeshGradientDefinition
    @Binding var selectedPoints: Set<MeshGradientPoint.ID>
    var documentConfiguration = false

    var body: some View {
        Form {
            Section {
                TextField("Width", value: $gradient.viewPortWidth, format: .number)
                TextField("Height", value: $gradient.viewPortHeight, format: .number)
            } header: {
                Text("Canvas")
            }

            Section {
                TextField("Rows", value: $gradient.height, format: .number)
                    .disabled(!documentConfiguration)

                TextField("Columns", value: $gradient.width, format: .number)
                    .disabled(!documentConfiguration)

                if !documentConfiguration {
                    Toggle("Smooth Colors", isOn: $gradient.smoothsColors)
                }

                ColorPicker("Background", selection: $gradient.backgroundColor)
                    .labeledContentStyle(ColorPickerLabelStyle())
            } header: {
                Text("Gradient")
            }

            if !documentConfiguration {
                Section {
                    ColorPicker("Color", selection: $gradient.colorBinding(for: selectedPoints))
                        .labeledContentStyle(ColorPickerLabelStyle())
                        .disabled(selectedPoints.isEmpty)
                } header: {
                    Text("Selection")
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct ColorPickerLabelStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.label

            Spacer()

            configuration
                .content
                .controlSize(.small)
        }
    }
}

extension Binding where Value == MeshGradientDefinition {
    func colorBinding(for selection: Set<MeshGradientPoint.ID>) -> Binding<Color> {
        .init {
            guard let id = selection.first else { return .clear }
            return wrappedValue[id].color
        } set: { newValue in
            for id in selection {
                wrappedValue[id].color = newValue
            }
        }

    }
}

#if DEBUG
#Preview {
    @Previewable @State var gradient = MeshGradientDefinition(
        viewPortWidth: 300,
        viewPortHeight: 300,
        width: 5,
        height: 5,
        colorPalette: [
            .red,
            .green,
            .blue,
            .yellow,
            .pink
        ],
        colorDistribution: .uniform
    )
    
    MeshGradientInspector(gradient: $gradient, selectedPoints: .constant([]))
        .frame(width: 340, height: 600)
}
#endif
