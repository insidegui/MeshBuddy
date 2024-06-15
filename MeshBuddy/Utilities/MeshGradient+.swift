import SwiftUI

extension MeshGradient {
    init(_ gradient: MeshGradientDefinition) {
        self.init(
            width: gradient.width,
            height: gradient.height,
            points: gradient.simdPoints,
            colors: gradient.colors,
            background: gradient.backgroundColor,
            smoothsColors: gradient.smoothsColors,
            colorSpace: gradient.colorSpace
        )
    }
}
