import SwiftUI


struct SwiftGenerator {
    /**
     Generates sample Swift code for the provided gradient definition.
     
     - parameter input: The mesh definition to create Swift code for
     - parameter environmentValue: The environment in which colors will be resolved
     - returns: Swift code to generate the provided mesh gradient
     */
    static func generateOutput(_ input: MeshGradientDefinition, in environmentValues: EnvironmentValues) -> String {
        let padding = "\t\t\t"
        let points = input.simdPoints.map { "\(padding)SIMD2<Float>(\($0.x), \($0.y))" }.joined(separator: ",\n")
        
        let colors = input.colors
            .map {
                "\(padding)\($0.swiftUIInitializer(in: environmentValues))"
            }
            .joined(separator: ",\n")
        
        let backgroundColor = input.backgroundColor.swiftUIInitializer(in: environmentValues)

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
