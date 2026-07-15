import Foundation
import AppKit
@preconcurrency import ScreenCaptureKit

@MainActor
final class ScreenshotCapture {
    static let shared = ScreenshotCapture()
    
    private init() {}
    
    func requestPermission() async -> Bool {
        do {
            _ = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            return true
        } catch {
            print("Failed to request screen capture permission: \(error)")
            return false
        }
    }
    
    func captureFullScreen() async throws -> NSImage? {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        
        guard let display = content.displays.first,
              let screen = NSScreen.main else {
            throw ScreenshotError.noDisplayFound
        }
        
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let configuration = SCStreamConfiguration()
        
        let scale = screen.backingScaleFactor
        configuration.width = Int(display.width * Int(scale))
        configuration.height = Int(display.height * Int(scale))
        configuration.showsCursor = false
        configuration.captureResolution = .best
        
        let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
        
        return NSImage(cgImage: image, size: NSSize(width: display.width, height: display.height))
    }
    
    func captureArea(_ rect: CGRect) async throws -> NSImage? {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        
        guard let display = content.displays.first,
              let screen = NSScreen.main else {
            throw ScreenshotError.noDisplayFound
        }
        
        let screenFrame = screen.frame
        let convertedRect = CGRect(
            x: rect.origin.x,
            y: screenFrame.height - rect.origin.y - rect.height,
            width: rect.width,
            height: rect.height
        )
        
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let configuration = SCStreamConfiguration()
        
        let scale = screen.backingScaleFactor
        configuration.width = Int(rect.width * scale)
        configuration.height = Int(rect.height * scale)
        configuration.showsCursor = false
        configuration.sourceRect = convertedRect
        configuration.captureResolution = .best
        
        let image = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
        
        return NSImage(cgImage: image, size: NSSize(width: rect.width, height: rect.height))
    }
}

enum ScreenshotError: Error {
    case noDisplayFound
    case captureFailure
    case permissionDenied
}
