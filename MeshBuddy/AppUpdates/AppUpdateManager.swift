import SwiftUI
import Sparkle

@MainActor
@Observable
final class AppUpdateManager {
    private let controller = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    private var updater: SPUUpdater { controller.updater }

    func checkForUpdates() {
        updater.checkForUpdates()
    }
}

struct CheckForUpdatesButton: View {
    var manager: AppUpdateManager

    var body: some View {
        Button {
            manager.checkForUpdates()
        } label: {
            Label("Check for Updates…", systemImage: "app.badge")
        }
    }
}
