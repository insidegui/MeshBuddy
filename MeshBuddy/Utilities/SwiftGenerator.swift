import SwiftUI


struct SwiftGenerator {
    /**
     Generates sample Swift code for the provided gradient definition.
     
     - parameter input: The mesh definition to create Swift code for
     
     - note: Due to color conversions and float point handling, the colors can come out unexpected. For instance, a background color of `.white` would be expected to have values of `red: 1, green: 1, blue: 1`, but may be generated as `red: 0.9999999403953552, green: 1.0, blue: 1.0`. If a workaround can be found to reliably round and keep these values intact, this can be refactored to support it.
     
     - returns: Swift code to generate the provided mesh gradient
     */
    static func generateOutput(_ input: MeshGradientDefinition) -> String {
        let padding = "\t\t\t"
        let points = input.simdPoints.map { "\(padding)SIMD2<Float>(\($0.x), \($0.y))" }.joined(separator: ",\n")
        
        let colors = input.colors
            .map { $0.nsColor }
            .map {
                "\(padding)\($0.swiftUIInitializer)"
        }
            .joined(separator: ",\n")
        
        let backgroundColor = input.backgroundColor.nsColor.swiftUIInitializer

        let output = """
struct GeneratedGradient: View {
    private let width: Int = \(input.width)
    private let height: Int = \(input.height)
    private let points: [SIMD2<Float>] = 
        [
\(points)
        ]
    private let colors: [Color] = 
        [
\(colors)
        ]
    private let background: Color = \(backgroundColor)
    private let smoothsColors: Bool = \(input.smoothsColors.asText)
    private let colorSpace: Gradient.ColorSpace = \(input.colorSpace.asText)

    var body: some View {
        MeshGradient(
            width: width,
            height: height,
            points: points,
            colors: colors,
            background: background,
            smoothsColors: smoothsColors,
            colorSpace: colorSpace
        )
    }
}
"""
        return output
    }
}
