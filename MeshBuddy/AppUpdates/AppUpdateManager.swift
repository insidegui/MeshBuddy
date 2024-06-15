import SwiftUI
import Combine
import Sparkle

@MainActor
final class AppUpdateManager: ObservableObject {
    @Published private(set) var canCheckForUpdates = false

    private let controller = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    private var updater: SPUUpdater { controller.updater }

    init() {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }

    func checkForUpdates() {
        updater.checkForUpdates()
    }
}

struct CheckForUpdatesButton: View {
    @ObservedObject var manager: AppUpdateManager

    var body: some View {
        Button("Check for Updates…", action: manager.checkForUpdates)
            .disabled(!manager.canCheckForUpdates)
    }
}
