import SwiftUI

struct MeshGradientEditor: View {
    @Binding var gradient: MeshGradientDefinition
    @State private var selectedPoints = Set<MeshGradientPoint.ID>()
    
    @AppStorage("controlsVisible")
    private var controlsVisible = true

    var body: some View {
        MeshGradientCanvas(gradient: $gradient, selectedPoints: $selectedPoints, controlsVisible: $controlsVisible)
            .inspector(isPresented: .constant(true)) {
                MeshGradientInspector(gradient: $gradient, selectedPoints: $selectedPoints)
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    let visibilityHelp: LocalizedStringKey = controlsVisible ? "Hide Controls" : "Show Controls"
                    Toggle(
                        visibilityHelp,
                        systemImage: "square.on.square.squareshape.controlhandles",
                        isOn: $controlsVisible
                    )
                    .help(visibilityHelp)

                    Button {
                        withAnimation(.smooth) {
                            gradient.distortPoints(frequency: 4, amplitude: 0.3)
                        }
                    } label: {
                        Image(systemName: "wand.and.sparkles.inverse")
                    }
                    .help("Apply perlin noise")

                    Button {
                        withAnimation(.smooth) {
                            gradient.randomize()
                        }
                    } label: {
                        Image(systemName: "dice")
                    }
                    .help("Randomize points")
                }
            }
    }
}

// MARK: - Inspector

struct MeshGradientInspector: View {
    @Binding var gradient: MeshGradientDefinition
    @Binding var selectedPoints: Set<MeshGradientPoint.ID>
    var documentConfiguration = false

    var body: some View {
        Form {
            Section {
                TextField("Rows", value: $gradient.height, format: .number)
                    .disabled(!documentConfiguration)

                TextField("Columns", value: $gradient.width, format: .number)
                    .disabled(!documentConfiguration)

                if !documentConfiguration {
                    Toggle("Smooth Colors", isOn: $gradient.smoothsColors)
                }

                ColorPicker("Background", selection: $gradient.backgroundColor)
            } header: {
                Text("Gradient")
            }

            if !documentConfiguration {
                Section {
                    ColorPicker("Color", selection: $gradient.colorBinding(for: selectedPoints))
                        .disabled(selectedPoints.isEmpty)
                } header: {
                    Text("Selection")
                }
            }
        }
        .formStyle(.grouped)
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

// MARK: - Canvas

struct MeshGradientCanvas: View {

    @Binding var gradient: MeshGradientDefinition
    @Binding var selectedPoints: Set<MeshGradientPoint.ID>
    @Binding var controlsVisible: Bool

    @Environment(\.colorScheme)
    private var colorScheme

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                let viewPort = proxy.frame(in: .local)
                ZStack {
                    if gradient.width > 0 && gradient.height > 0 {
                        MeshGradient(
                            width: gradient.width,
                            height: gradient.height,
                            points: gradient.simdPoints,
                            colors: gradient.colors,
                            background: gradient.backgroundColor,
                            smoothsColors: gradient.smoothsColors,
                            colorSpace: gradient.colorSpace
                        )
                    }

                    ForEach(gradient.points) { point in
                        MeshGradientPointHandle(
                            point: point,
                            viewPort: viewPort,
                            gradient: gradient,
                            isSelected: selectedPoints.contains(point.id),
                            isVisible: controlsVisible
                        )
                    }
                }
                .contentShape(Rectangle())
                .gesture(dragGesture(with: viewPort))
            }
            .animation(.snappy, value: controlsVisible)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(minWidth: 400)
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorScheme == .dark ? Color.black : Color.white)
    }

    @State private var dragReferenceTranslation = CGSize.zero
    @State private var dragGestureCanModifySelection = true

    private func dragGesture(with viewPort: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                guard controlsVisible else { return }

                if dragGestureCanModifySelection {
                    if let targetPoint = gradient.point(at: value.location, in: viewPort) {
                        let commandPressed = NSEvent.modifierFlags.contains(.command)
                        let optionPressed = NSEvent.modifierFlags.contains(.command)

                        if commandPressed {
                            selectedPoints.insert(targetPoint.id)
                        } else if optionPressed {
                            selectedPoints.remove(targetPoint.id)
                        } else {
                            if !selectedPoints.contains(targetPoint.id) {
                                selectedPoints = [targetPoint.id]
                            }
                        }
                        print(targetPoint)
                    } else {
                        selectedPoints.removeAll()
                        /// Adding points not currently supported because adding arbitrary points doesn't work,
                        /// it would have to be a feature where an entire column/row can be added at a certain point.
                        return
//                        print("New \(Int(Date.now.timeIntervalSinceReferenceDate))")
//
//                        let relativePosition = CGPoint(
//                            x: value.location.x / viewPort.size.width,
//                            y: value.location.y / viewPort.size.height
//                        )
//
//                        let newPoint = gradient.addPoint(at: relativePosition, color: .indigo)
//                        selectedPoints.insert(newPoint.id)
                    }

                    dragGestureCanModifySelection = false
                }

                let relativeTranslation = CGSize(
                    width: (value.translation.width - dragReferenceTranslation.width) / viewPort.width,
                    height: (value.translation.height - dragReferenceTranslation.height) / viewPort.height
                )

                dragReferenceTranslation = value.translation

                for pointID in selectedPoints {
                    gradient.nudgePoint(id: pointID, by: relativeTranslation)
                }
            }
            .onEnded { _ in
                guard controlsVisible else { return }

                dragReferenceTranslation = .zero
                dragGestureCanModifySelection = true
            }
    }
}

struct MeshGradientPointHandle: View {
    nonisolated static var size: CGFloat { 12 }

    var point: MeshGradientPoint
    var viewPort: CGRect
    var gradient: MeshGradientDefinition
    var isSelected: Bool
    var isVisible: Bool

    var body: some View {
        let pos = point.position(in: viewPort)

        Circle()
            .fill(point.color)
            .stroke(Color.white, lineWidth: isSelected ? 2 : 1)
            .shadow(radius: 2)
            .frame(width: Self.size, height: Self.size)
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.4)
            .position(pos)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var definition = MeshGradientDefinition(width: 12, height: 12, backgroundColor: .indigo)
    MeshGradientEditor(gradient: $definition)
}
#endif
