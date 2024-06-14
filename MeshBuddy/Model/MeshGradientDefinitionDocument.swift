import SwiftUI
import UniformTypeIdentifiers

struct MeshGradientDefinitionDocument: FileDocument {
    var definition: MeshGradientDefinition

    init(definition: MeshGradientDefinition = .init(width: 0, height: 0, backgroundColor: .white)) {
        self.definition = definition
    }

    static var readableContentTypes: [UTType] { [.meshDefinition] }

    init(configuration: ReadConfiguration) throws {
        guard let contents = configuration.file.regularFileContents else {
            throw DocumentFileError.unableToLoadData
        }

        let container = try PropertyListDecoder.meshDefinition.decode(DocumentFileContainer.self, from: contents)

        self.init(definition: container.definition)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let container = DocumentFileContainer(definition: definition)
        let data = try PropertyListEncoder.meshDefinition.encode(container)
        return FileWrapper(regularFileWithContents: data)
    }

}
