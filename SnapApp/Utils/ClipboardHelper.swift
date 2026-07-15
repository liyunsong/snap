import AppKit
import SwiftUI

class ClipboardHelper {
    static let shared = ClipboardHelper()
    
    private init() {}
    
    func copyImageToClipboard(_ image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }
    
    func saveImageToFile(_ image: NSImage, filename: String? = nil) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
        
        let fileName = filename ?? "Screenshot-\(dateString).png"
        let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let fileURL = desktopURL.appendingPathComponent(fileName)
        
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            return nil
        }
        
        do {
            try pngData.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }
    
    func renderAnnotatedImage(baseImage: NSImage, annotations: [Annotation]) -> NSImage {
        let size = baseImage.size
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        baseImage.draw(at: .zero, from: NSRect(origin: .zero, size: size), operation: .copy, fraction: 1.0)
        
        let context = NSGraphicsContext.current!.cgContext
        
        for annotation in annotations {
            context.saveGState()
            
            let nsColor = NSColor(annotation.color)
            nsColor.setStroke()
            nsColor.setFill()
            
            context.setLineWidth(annotation.lineWidth)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            
            switch annotation.type {
            case .rectangle:
                if annotation.points.count >= 2 {
                    let rect = rectFromPoints(annotation.points[0], annotation.points[1])
                    context.stroke(rect)
                }
                
            case .circle:
                if annotation.points.count >= 2 {
                    let rect = rectFromPoints(annotation.points[0], annotation.points[1])
                    context.strokeEllipse(in: rect)
                }
                
            case .line:
                if annotation.points.count >= 2 {
                    context.move(to: annotation.points[0])
                    context.addLine(to: annotation.points[1])
                    context.strokePath()
                }
                
            case .arrow:
                if annotation.points.count >= 2 {
                    drawArrow(context: context, from: annotation.points[0], to: annotation.points[1], lineWidth: annotation.lineWidth)
                }
                
            case .pen:
                if annotation.points.count > 1 {
                    context.move(to: annotation.points[0])
                    for point in annotation.points.dropFirst() {
                        context.addLine(to: point)
                    }
                    context.strokePath()
                }
                
            case .text:
                if let text = annotation.text, let rect = annotation.rect {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: NSFont.systemFont(ofSize: 16),
                        .foregroundColor: nsColor
                    ]
                    let attributedString = NSAttributedString(string: text, attributes: attributes)
                    attributedString.draw(in: rect)
                }
                
            case .mosaic, .blur:
                break
            }
            
            context.restoreGState()
        }
        
        image.unlockFocus()
        
        return image
    }
    
    private func rectFromPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGRect {
        let x = min(p1.x, p2.x)
        let y = min(p1.y, p2.y)
        let width = abs(p2.x - p1.x)
        let height = abs(p2.y - p1.y)
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func drawArrow(context: CGContext, from: CGPoint, to: CGPoint, lineWidth: CGFloat) {
        context.move(to: from)
        context.addLine(to: to)
        context.strokePath()
        
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength = lineWidth * 3
        let arrowAngle = CGFloat.pi / 6
        
        let point1 = CGPoint(
            x: to.x - arrowLength * cos(angle - arrowAngle),
            y: to.y - arrowLength * sin(angle - arrowAngle)
        )
        let point2 = CGPoint(
            x: to.x - arrowLength * cos(angle + arrowAngle),
            y: to.y - arrowLength * sin(angle + arrowAngle)
        )
        
        context.move(to: to)
        context.addLine(to: point1)
        context.move(to: to)
        context.addLine(to: point2)
        context.strokePath()
    }
}
