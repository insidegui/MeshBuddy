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
                ColorPaletteSection(gradient: $gradient)
            }
        }
        .formStyle(.grouped)
        .onColorPaletteDrop { droppedColors in
            withAnimation(.smooth) {
                gradient.distribute(palette: droppedColors, using: gradient.colorDistribution)
            }
        }
    }
}

struct ColorPaletteSection: View {
    @Binding var gradient: MeshGradientDefinition

    @State private var colorPalette = [Color]()
    @State private var distributionStyle = ColorDistributionStyle.uniform

    var body: some View {
        Section {
            ForEach(colorPalette.indices, id: \.self) { i in
                ColorPicker("Color \(i + 1)", selection: $colorPalette[i])
                    .labeledContentStyle(ColorPickerLabelStyle())
            }

            Picker("Distribution", selection: $distributionStyle) {
                ForEach(ColorDistributionStyle.allCases) { option in
                    Text(option.localizedTitle)
                        .tag(option)
                }
            }

            LabeledContent {
                Button("Apply") {
                    withAnimation(.smooth) {
                        gradient.distribute(palette: colorPalette, using: distributionStyle)
                    }
                }
            } label: {

            }
            .controlSize(.small)
        } header: {
            /// Feels kinda gross to attach these onChange modifiers to the header, but I needed a view
            /// that's not a ForEach-style container, which Section is, so there you go...
            header
                .onChange(of: gradient.colorPalette, initial: true) { _, newValue in
                    self.colorPalette = newValue
                }
                .onChange(of: gradient.colorDistribution, initial: true) { _, newValue in
                    self.distributionStyle = newValue
                }
        } footer: {
            Text("Tip: you can drag and drop a comma-separated list of hex colors here to define the palette.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }

    @ViewBuilder
    private var header: some View {
        HStack {
            Text("Color Palette")

            Spacer()

            Button {
                colorPalette.append(Color.randomSystemColor())
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.borderless)
            .help("Add Color")
        }
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
