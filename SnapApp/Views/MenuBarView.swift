import SwiftUI
import KeyboardShortcuts

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingPreferences = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                Task {
                    await handleCaptureArea()
                }
            }) {
                HStack {
                    Image(systemName: "viewfinder")
                    Text("区域截图")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .captureArea)
                        .frame(width: 120)
                }
            }
            .buttonStyle(.plain)
            .padding(8)
            
            Divider()
            
            Button(action: {
                Task {
                    await handleCaptureFullScreen()
                }
            }) {
                HStack {
                    Image(systemName: "rectangle.on.rectangle")
                    Text("全屏截图")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .captureFullScreen)
                        .frame(width: 120)
                }
            }
            .buttonStyle(.plain)
            .padding(8)
            
            Divider()
            
            Button(action: {
                showingPreferences.toggle()
            }) {
                HStack {
                    Image(systemName: "gear")
                    Text("设置")
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .padding(8)
            
            Divider()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                    Text("退出")
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .padding(8)
        }
        .frame(width: 280)
        .sheet(isPresented: $showingPreferences) {
            PreferencesView()
        }
    }
    
    private func handleCaptureArea() async {
        appState.startCapture()
        
        await MainActor.run {
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
    
    private func handleCaptureFullScreen() async {
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

struct PreferencesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("快捷键设置")
                .font(.title)
            
            Form {
                KeyboardShortcuts.Recorder("区域截图:", name: .captureArea)
                KeyboardShortcuts.Recorder("全屏截图:", name: .captureFullScreen)
            }
            .padding()
            
            Spacer()
        }
        .frame(width: 400, height: 200)
        .padding()
    }
}
