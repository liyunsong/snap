import SwiftUI
import KeyboardShortcuts

@main
struct SnapApp: App {
    @StateObject private var appState = AppState()
    @State private var overlayWindow: SelectionOverlayWindow?
    
    init() {
        setupShortcuts()
    }
    
    var body: some Scene {
        MenuBarExtra("Snap", systemImage: "camera.viewfinder") {
            MenuBarView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup(id: "editor") {
            if appState.isEditorVisible, let image = appState.capturedImage {
                EditorView()
                    .environmentObject(appState)
                    .frame(width: image.size.width, height: image.size.height)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
    
    private func setupShortcuts() {
        ShortcutManager.shared.onCaptureArea = {
            Task { @MainActor in
                guard self.overlayWindow == nil else { return }
                
                appState.startCapture()
                
                let overlay = SelectionOverlayWindow()
                self.overlayWindow = overlay
                overlay.onAreaSelected = { rect in
                    Task {
                        do {
                            let image = try await ScreenshotCapture.shared.captureArea(rect)
                            await MainActor.run {
                                if let image = image {
                                    appState.setCapturedImage(image)
                                }
                            }
                        } catch {
                            print("Failed to capture area: \(error)")
                            await MainActor.run {
                                appState.isSelectingArea = false
                            }
                        }
                        await MainActor.run {
                            self.overlayWindow = nil
                        }
                    }
                }
                overlay.onCancel = {
                    Task { @MainActor in
                        appState.isSelectingArea = false
                        self.overlayWindow = nil
                    }
                }
            }
        }
        
        ShortcutManager.shared.onCaptureFullScreen = {
            Task { @MainActor in
                do {
                    let image = try await ScreenshotCapture.shared.captureFullScreen()
                    await MainActor.run {
                        if let image = image {
                            appState.setCapturedImage(image)
                        }
                    }
                } catch {
                    print("Failed to capture full screen: \(error)")
                }
            }
        }
    }
}

extension NSApplication {
    @objc func handleCaptureArea() {
        ShortcutManager.shared.onCaptureArea?()
    }
    
    @objc func handleCaptureFullScreen() {
        ShortcutManager.shared.onCaptureFullScreen?()
    }
}
