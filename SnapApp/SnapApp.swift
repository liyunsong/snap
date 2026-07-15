import SwiftUI
import KeyboardShortcuts

@main
struct SnapApp: App {
    @StateObject private var appState = AppState()
    @State private var editorWindow: NSWindow?
    
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
        .onChange(of: appState.isEditorVisible) { _, isVisible in
            if isVisible {
                openEditorWindow()
            }
        }
    }
    
    private func setupShortcuts() {
        ShortcutManager.shared.onCaptureArea = {
            Task { @MainActor in
                appState.startCapture()
                
                let overlayWindow = SelectionOverlayWindow()
                overlayWindow.onAreaSelected = { rect in
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
                        }
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
    
    private func openEditorWindow() {
        guard let image = appState.capturedImage else { return }
        
        DispatchQueue.main.async {
            if let existingWindow = NSApplication.shared.windows.first(where: { $0.title == "编辑截图" }) {
                existingWindow.makeKeyAndOrderFront(nil)
                return
            }
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            
            window.title = "编辑截图"
            window.center()
            window.setFrameAutosaveName("EditorWindow")
            window.isReleasedWhenClosed = false
            
            let editorView = EditorView()
                .environmentObject(appState)
                .frame(width: image.size.width, height: image.size.height)
            
            window.contentView = NSHostingView(rootView: editorView)
            window.makeKeyAndOrderFront(nil)
            
            editorWindow = window
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
