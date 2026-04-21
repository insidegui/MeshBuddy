import SwiftUI
import ObjectiveC

/**
 This swizzles `acceptsFirstMouse(for:)` on `NSView` so that all views accept first mouse as long as the app is currently active.
 It improves UX in the canvas when editing colors in the color panel. If the color panel is the key window, clicking a point
 in the canvas will first focus the canvas then select the point on a second click. With this swizzle, a single click
 immediately selects the point, even if the color panel is the key window.
 */
@objc final class AcceptsFirstMouseSwizzle: NSView {
    static func install() {
        guard !UserDefaults.standard.bool(forKey: "MBDisableAcceptsFirstMouseSwizzle") else { return }

        guard let original = class_getInstanceMethod(NSView.self, #selector(NSView.acceptsFirstMouse(for:))) else {
            assertionFailure("Couldn't get acceptsFirstMouse(for:) method on NSView")
            return
        }

        guard let replacement = class_getInstanceMethod(AcceptsFirstMouseSwizzle.self, #selector(AcceptsFirstMouseSwizzle.override_acceptsFirstMouse(for:))) else {
            assertionFailure("Couldn't get override_acceptsFirstMouse(for:) method on AcceptsFirstMouseSwizzle")
            return
        }

        method_exchangeImplementations(original, replacement)
    }

    @objc func override_acceptsFirstMouse(for event: NSEvent?) -> Bool {
        NSApp.isActive
    }
}
