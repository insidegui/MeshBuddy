import SwiftUI


struct SwiftCodeView: View {
    var gradient: MeshGradientDefinition
    private let generatedDate = Date()
    
    private var output: String {
        SwiftGenerator.generateOutput(gradient)
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                TextEditor(text: .constant(output))
                    .monospaced()
                    .contentMargins(15, for: .scrollContent)
                    .textEditorStyle(.plain)
                
                CopyButton(text: output)
                    .padding()
            }
            
            Text("Generated at \(generatedDate)")
        }
        .padding(.bottom, 9)
    }
    
    struct CopyButton: View {
        @State private var copySuccessful: Bool?
        private var buttonText: LocalizedStringKey {
            switch copySuccessful {
            case .some(true): "Copied"
            case .some(false): "Error copying to clipboard"
            case .none: "Copy to clipboard"
            }
        }
        var text: String

        var body: some View {
            Button {
                NSPasteboard.general.declareTypes([.string], owner: nil)
                copySuccessful = NSPasteboard.general.setString(text, forType: .string)
            } label: {
                Label(buttonText, systemImage: "document.on.document")
            }
            .help("Copy code to clipboard")
            .buttonStyle(.borderedProminent)
            
        }
    }
}


struct SwiftCodeWindow: Scene {
    var body: some Scene {
        WindowGroup(for: MeshGradientDefinition.self) { meshGradient in
            if let gradient = meshGradient.wrappedValue {
                SwiftCodeView(gradient: gradient)
            }
        }
        .commandsRemoved()
    }
}


struct ViewSwiftCodeButton: View {
    @Environment(\.openWindow) private var openWindow
    
    var gradient: MeshGradientDefinition
    
    var body: some View {
        Button {
            openWindow(value: gradient)
        } label: {
            Label("View Swift code", systemImage: "text.rectangle.page")
        }
        .help("View Swift code")
        .keyboardShortcut("c", modifiers: [.command, .option])
    }
}
