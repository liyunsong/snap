import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let captureArea = Self("captureArea", default: .init(.a, modifiers: [.command, .shift]))
    static let captureFullScreen = Self("captureFullScreen", default: .init(.s, modifiers: [.command, .shift]))
}

@MainActor
class ShortcutManager: ObservableObject {
    static let shared = ShortcutManager()
    
    var onCaptureArea: (() -> Void)?
    var onCaptureFullScreen: (() -> Void)?
    
    private init() {
        setupShortcuts()
    }
    
    private func setupShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .captureArea) { [weak self] in
            Task { @MainActor in
                self?.onCaptureArea?()
            }
        }
        
        KeyboardShortcuts.onKeyUp(for: .captureFullScreen) { [weak self] in
            Task { @MainActor in
                self?.onCaptureFullScreen?()
            }
        }
    }
}
