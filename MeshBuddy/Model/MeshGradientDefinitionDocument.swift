import SwiftUI
import UniformTypeIdentifiers

struct MeshGradientDefinitionDocument: FileDocument {
    var definition: MeshGradientDefinition
    var needsSetup: Bool

    init(definition: MeshGradientDefinition = .default, needsSetup: Bool = true) {
        self.definition = definition
        self.needsSetup = needsSetup
    }

    static var readableContentTypes: [UTType] { [.meshDefinition] }

    init(configuration: ReadConfiguration) throws {
        guard let contents = configuration.file.regularFileContents else {
            throw DocumentFileError.unableToLoadData
        }

        try self.init(data: contents)
    }

    init(data: Data) throws {
        let container = try PropertyListDecoder.meshDefinition.decode(DocumentFileContainer.self, from: data)

        self.init(definition: container.definition, needsSetup: false)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let container = DocumentFileContainer(definition: definition)
        let data = try PropertyListEncoder.meshDefinition.encode(container)
        return FileWrapper(regularFileWithContents: data)
    }

}
