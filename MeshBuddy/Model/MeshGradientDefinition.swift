import SwiftUI
import GameKit

struct MeshGradientPoint: Identifiable, Hashable, CustomStringConvertible, Codable, Sendable {
    var id: UUID = UUID()
    var simd: SIMD2<Float>
    var color: Color

    var x: Float {
        get { simd.x }
        set { simd.x = newValue }
    }
    var y: Float {
        get { simd.y }
        set { simd.y = newValue }
    }

    init(simd: SIMD2<Float>, color: Color) {
        self.simd = simd
        self.color = color
    }

    init(x: Float, y: Float, color: Color) {
        self.simd = .init(x: x, y: y)
        self.color = color
    }

    var description: String {
        String(format: "<%.02fx%.02f>", x, y)
    }

    var position: CGPoint {
        get { CGPoint(x: Double(x), y: Double(y)) }
        set {
            simd = .init(x: Float(newValue.x), y: Float(newValue.y))
        }
    }
}

struct MeshGradientDefinition: Codable, Sendable, Hashable {
    var id: UUID
    var viewPortWidth: Int
    var viewPortHeight: Int
    var width: Int
    var height: Int
    var points: [MeshGradientPoint] {
        didSet {
            guard points != oldValue else { return }

            let newPoints = MeshGradientDefinition.simdPoints(from: points)
            simdPoints = newPoints

            let newColors = MeshGradientDefinition.colors(from: points)
            colors = newColors
        }
    }

    var smoothsColors: Bool
    var backgroundColor: Color
    var colorSpace: Gradient.ColorSpace
    var colorPalette: [Color]
    var colorDistribution: ColorDistributionStyle

    private(set) var simdPoints: [SIMD2<Float>]
    private(set) var colors: [Color]

    private static func simdPoints(from points: [MeshGradientPoint]) -> [SIMD2<Float>] { points.map(\.simd) }
    private static func colors(from points: [MeshGradientPoint]) -> [Color] { points.map(\.color) }

    init(id: UUID = UUID(), viewPortWidth: Int, viewPortHeight: Int, width: Int, height: Int, colorPalette: [Color]?, colorDistribution: ColorDistributionStyle, smoothsColors: Bool = true, backgroundColor: Color = .clear, colorSpace: Gradient.ColorSpace = .device) {
        self.id = id
        self.viewPortWidth = viewPortWidth
        self.viewPortHeight = viewPortHeight
        self.width = width
        self.height = height
        self.smoothsColors = smoothsColors
        self.backgroundColor = backgroundColor
        self.colorSpace = colorSpace
        self.points = []
        self.colorPalette = colorPalette ?? Color.meshColorPalette(width: width, height: height)
        self.colorDistribution = colorDistribution

        precondition(self.colorPalette.count >= 2, "Color palette must have at least two colors")

        for i in 0..<height {
            var row: [MeshGradientPoint] = []
            for j in 0..<width {
                let x = Float(j) / Float(width - 1)
                let y = Float(i) / Float(height - 1)
                let point = MeshGradientPoint(x: x, y: y, color: .black)
                row.append(point)
            }
            self.points.append(contentsOf: row)
        }

        self.simdPoints = MeshGradientDefinition.simdPoints(from: self.points)
        self.colors = MeshGradientDefinition.colors(from: self.points)

        /// Do initial color distribution.
        distribute(palette: self.colorPalette, using: colorDistribution)
    }

    func indexForPoint(with id: MeshGradientPoint.ID) -> Int {
        guard let idx = points.firstIndex(where: { $0.id == id }) else {
            preconditionFailure("Invalid point ID: \(id)")
        }
        return idx
    }

    mutating func nudgePoint(id: MeshGradientPoint.ID, by amount: CGSize) {
        var position = self[id].position
        position.x += amount.width
        position.y += amount.height

        if position.x < 0 { position.x = 0 }
        if position.x > 1 { position.x = 1 }
        if position.y < 0 { position.y = 0 }
        if position.y > 1 { position.y = 1 }

        self[id].position = position
    }

    @discardableResult
    mutating func addPoint(at position: CGPoint, color: Color) -> MeshGradientPoint {
        let point = MeshGradientPoint(x: Float(position.x), y: Float(position.y), color: color)
        points.append(point)
        return point
    }

    subscript(pointID: MeshGradientPoint.ID) -> MeshGradientPoint {
        get { points[indexForPoint(with: pointID)] }
        set { points[indexForPoint(with: pointID)] = newValue }
    }

    subscript(point: MeshGradientPoint) -> MeshGradientPoint {
        get { self[point.id] }
        set { self[point.id] = newValue }
    }
}

extension MeshGradientPoint {
    func position(in viewPort: CGRect, handleSize: CGFloat = MeshGradientPointHandle.size) -> CGPoint {
        var pos = CGPoint(
            x: viewPort.origin.x * Double(x) + viewPort.size.width * Double(x),
            y: viewPort.origin.y * Double(y) + viewPort.size.height * Double(y)
        )

        /// Make handles at the very edge easier to reach by moving them into the hit area.
        if pos.x == 0 {
            pos.x += handleSize * 0.5
        } else if pos.x >= 1 {
            pos.x -= handleSize * 0.5
        }
        if pos.y == 0 {
            pos.y += handleSize * 0.5
        } else if pos.y >= 1 {
            pos.y -= handleSize * 0.5
        }

        return pos
    }

    func handleFrame(in viewPort: CGRect, handleSize: CGFloat = MeshGradientPointHandle.size) -> CGRect {
        let pos = position(in: viewPort, handleSize: handleSize)
        return CGRect(
            x: pos.x - handleSize * 0.5,
            y: pos.y - handleSize * 0.5,
            width: handleSize,
            height: handleSize
        )
    }
}

extension MeshGradientDefinition {
    func point(at location: CGPoint, in viewPort: CGRect, handleSize: CGFloat = MeshGradientPointHandle.size) -> MeshGradientPoint? {
        self.points.first { $0.handleFrame(in: viewPort, handleSize: handleSize).contains(location) }
    }
}

// MARK: - Editing Utilities

extension MeshGradientPoint {
    /// `true` if point is flush against the edge of the gradient in the x axis.
    var isHorizontalEdge: Bool { x >= 1 || x == 0 }
    /// `true` if point is flush against the edge of the gradient in the y axis.
    var isVerticalEdge: Bool { y >= 1 || y == 0 }
}

extension MeshGradientDefinition {
    func indexForPoint(atRow row: Int, column: Int) -> Int { row * width + column }

    /// Frequency range: 0.5...5.0
    /// Amplitude range: 0.05...0.01
    mutating func distortPoints(frequency: Double = 1.0, amplitude: Double = 0.07) {

        mutatePoints { point, index, row, column, _, _ in
            let noiseSource = GKPerlinNoiseSource(frequency: frequency, octaveCount: 6, persistence: 0.5, lacunarity: 2.0, seed: Int32.random(in: 0...Int32.max))
            let noise = GKNoise(noiseSource)
            let noiseMap = GKNoiseMap(noise)

            let noiseValueX = noiseMap.value(at: vector_int2(Int32(column), Int32(row)))
            let noiseValueY = noiseMap.value(at: vector_int2(Int32(row), Int32(column)))
            if !point.isHorizontalEdge {
                point.x += noiseValueX * Float(amplitude)
            }
            if !point.isVerticalEdge {
                point.y += noiseValueY * Float(amplitude)
            }
        }
    }

    mutating func mutatePoints(using closure: (_ point: inout MeshGradientPoint) -> Void) {
        mutatePoints { point, _, _, _, _, _ in
            closure(&point)
        }
    }

    mutating func mutatePoints(using closure: (_ point: inout MeshGradientPoint, _ index: Int, _ row: Int, _ column: Int, _ width: Int, _ height: Int) -> Void) {
        var snapshot = points

        for row in 0..<height {
            for column in 0..<width {
                let index = indexForPoint(atRow: row, column: column)
                var mutablePoint = snapshot[index]
                closure(&mutablePoint, index, row, column, width, height)
                snapshot[index] = mutablePoint
            }
        }

        self.points = snapshot
    }

    mutating func randomizeMesh(magnitude: Float = 0.2) {
        resetPointPositions()

        var seed = SystemRandomNumberGenerator()

        mutatePoints { point in
            if point.x > 0 && point.x < 1 {
                let rangeX: ClosedRange<Float> = (point.x - magnitude)...(point.x + magnitude)
                point.x = max(0, min(1, Float.random(in: rangeX, using: &seed)))
            }
            if point.y > 0 && point.y < 1 {
                let rangeY: ClosedRange<Float> = (point.y - magnitude)...(point.y + magnitude)
                point.y = max(0, min(1, Float.random(in: rangeY, using: &seed)))
            }
        }
    }

    mutating func resetPointPositions() {
        mutatePoints { point, index, row, column, width, height in
            let x = Float(column) / Float(width - 1)
            let y = Float(row) / Float(height - 1)
            point.x = x
            point.y = y
        }
    }
}

// MARK: - Color Distribution

enum ColorDistributionStyle: String, CaseIterable, Identifiable, Codable {
    var id: RawValue { rawValue }

    case uniform
    case random

    var localizedTitle: LocalizedStringKey {
        switch self {
        case .uniform:
            return "Uniform"
        case .random:
            return "Random"
        }
    }
}

extension MeshGradientDefinition {
    mutating func distribute(palette: [Color], using style: ColorDistributionStyle) {
        self.colorDistribution = style

        var currentColorIndex = 0

        mutatePoints { point, index, row, column, width, height in
            switch style {
            case .uniform:
                point.color = palette[currentColorIndex]
                if currentColorIndex < palette.count - 1 {
                    currentColorIndex += 1
                } else {
                    currentColorIndex = 0
                }
            case .random:
                point.color = palette.randomElement()!
            }
        }
    }
}

// MARK: - Templates

extension MeshGradientDefinition {
    static let `default` = MeshGradientDefinition(
        id: UUID(),
        viewPortWidth: 512,
        viewPortHeight: 512,
        width: 5,
        height: 5,
        colorPalette: nil,
        colorDistribution: .uniform,
        smoothsColors: true,
        backgroundColor: .white,
        colorSpace: .device
    )
}

extension MeshGradientDefinition {
    init(from template: Self) {
        self.init(
            viewPortWidth: template.viewPortWidth,
            viewPortHeight: template.viewPortHeight,
            width: template.width,
            height: template.height,
            colorPalette: template.colorPalette,
            colorDistribution: template.colorDistribution,
            smoothsColors: template.smoothsColors,
            backgroundColor: template.backgroundColor,
            colorSpace: template.colorSpace
        )
    }
}

extension Color {
    static let systemColors: [Color] = [
        .red,
        .green,
        .blue,
        .orange,
        .yellow,
        .pink,
        .purple,
        .indigo,
        .cyan,
        .mint,
        .teal
    ]
}

extension Color {
    static func randomSystemColors(count: Int) -> [Color] {
        (0..<count).map { _ in systemColors.randomElement()! }
    }

    static func randomSystemColor() -> Color { randomSystemColors(count: 1)[0] }

    static func meshColorPalette(width: Int, height: Int) -> [Color] {
        let colorCount = min(6, max(width, height))

        return randomSystemColors(count: colorCount)
    }
}
