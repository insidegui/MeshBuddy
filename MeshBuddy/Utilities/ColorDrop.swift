import SwiftUI
import UniformTypeIdentifiers

extension View {
    func onColorPaletteDrop(perform action: @escaping ([Color]) -> Void) -> some View {
        modifier(ColorDropModifier(onDrop: action))
    }
}

private struct ColorDropModifier: ViewModifier {
    var onDrop: ([Color]) -> Void

    @State private var isTargeted = false

    func body(content: Content) -> some View {
        content
            .onDrop(of: [.plainText], isTargeted: $isTargeted) { providers in
                Task { await readColors(from: providers) }
                return true
            }
            .overlay {
                if isTargeted {
                    Color.white.opacity(0.1)
                        .blendMode(.plusLighter)
                }
            }
    }

    private func readColors(from providers: [NSItemProvider]) async {
        guard let validProvider = providers.first(where: { $0.canLoadObject(ofClass: NSString.self) }) else { return }

        let colorCodes = await validProvider.readColorCodes()

        let colors = colorCodes.map { Color(hex: $0) }

        onDrop(colors)
    }
}

@MainActor
private extension NSItemProvider {
    private static let hexColorRegex = /^#(?:[0-9a-fA-F]{3}){1,2}$/

    func readColorCodes() async -> [String] {
        let hexList = try? await withCheckedThrowingContinuation { continuation in
            _ = self.loadTransferable(type: String.self) { result in
                continuation.resume(with: result)
            }
        }
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")

        guard let components = hexList.flatMap({ $0.components(separatedBy: ",") }) else { return [] }

        let mapped = components
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .compactMap { (try? Self.hexColorRegex.firstMatch(in: $0))?.0 }

        return mapped.map(String.init)
    }
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#if DEBUG
#Preview {
    @Previewable @State var palette = [Color]()

    Rectangle()
        .foregroundStyle(.secondary)
        .frame(width: 300, height: 300)
        .overlay {
            HStack {
                ForEach(palette.indices, id: \.self) { i in
                    let color = palette[i]
                    Rectangle()
                        .fill(color)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .onColorPaletteDrop { colors in
            palette = colors
        }
}
#endif
