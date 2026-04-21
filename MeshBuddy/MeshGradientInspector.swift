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
                    .labeledContentStyle(.centered)
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
            ColorPaletteList(colorPalette: $colorPalette)

            Picker("Distribution", selection: $distributionStyle) {
                ForEach(ColorDistributionStyle.allCases) { option in
                    Text(option.localizedTitle)
                        .tag(option)
                }
            }

            Button("Apply") {
                withAnimation(.smooth) {
                    gradient.distribute(palette: colorPalette, using: distributionStyle)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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

private struct ColorPaletteList: View {
    @Binding var colorPalette: [Color]
    @State private var selection: Set<Int> = []

    var body: some View {
        List(selection: $selection) {
            ForEach(Array(colorPalette.indices), id: \.self) { index in
                ColorPaletteRow(
                    title: "Color \(index + 1)",
                    color: $colorPalette[index],
                    onDuplicate: {
                        colorPalette.append(colorPalette[index])
                    },
                    onDelete: {
                        colorPalette.remove(at: index)
                    })
                .tag(index)
            }
            .onDelete(perform: deleteColors)
        }
        .onDeleteCommand {
            guard !selection.isEmpty else { return }
            deleteColors(at: IndexSet(selection))
        }
    }

    private func deleteColors(at offsets: IndexSet) {
        guard colorPalette.count > 2 else { return }
        let validOffsets = offsets.suffix(max(1, colorPalette.count - 2))
        colorPalette.remove(atOffsets: IndexSet(validOffsets))
    }
}

private struct ColorPaletteRow: View {
    let title: String
    @Binding var color: Color
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ColorPicker(title, selection: $color)
            .padding(.vertical, 4)
            .labeledContentStyle(.centered)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
            .contextMenu {
                Button(action: onDuplicate) {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
                .keyboardShortcut("d", modifiers: .command)

                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}

extension LabeledContentStyle where Self == CenteredLabelStyle {
    static var centered: CenteredLabelStyle { CenteredLabelStyle() }
}

struct CenteredLabelStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) {
            configuration.label

            Spacer()

            configuration
                .content
                .controlSize(.small)
        }
        .padding(.vertical, 2)
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
        .frame(width: 340, height: 800)
}
#endif
