import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct MosaicTool: DrawingTool {
    func draw(in context: GraphicsContext, annotation: Annotation) {
        guard annotation.points.count >= 2, let rect = annotation.rect else { return }
        var path = Path()
        path.addRect(rect)
        context.fill(path, with: .color(annotation.color.opacity(0.5)))
    }
    
    func createAnnotation(from startPoint: CGPoint, to endPoint: CGPoint, color: Color, lineWidth: CGFloat) -> Annotation {
        let rect = CGRect(x: min(startPoint.x, endPoint.x), y: min(startPoint.y, endPoint.y), 
                         width: abs(endPoint.x - startPoint.x), height: abs(endPoint.y - startPoint.y))
        return Annotation(type: .mosaic, points: [startPoint, endPoint], color: color, lineWidth: lineWidth, rect: rect)
    }
}

struct BlurTool: DrawingTool {
    func draw(in context: GraphicsContext, annotation: Annotation) {
        guard annotation.points.count >= 2, let rect = annotation.rect else { return }
        var path = Path()
        path.addRect(rect)
        context.fill(path, with: .color(.white.opacity(0.3)))
    }
    
    func createAnnotation(from startPoint: CGPoint, to endPoint: CGPoint, color: Color, lineWidth: CGFloat) -> Annotation {
        let rect = CGRect(x: min(startPoint.x, endPoint.x), y: min(startPoint.y, endPoint.y), 
                         width: abs(endPoint.x - startPoint.x), height: abs(endPoint.y - startPoint.y))
        return Annotation(type: .blur, points: [startPoint, endPoint], color: color, lineWidth: lineWidth, rect: rect)
    }
}

class ImageEffectProcessor {
    static let shared = ImageEffectProcessor()
    private let context = CIContext()
    
    func applyMosaic(to image: NSImage, in rect: CGRect, pixelSize: CGFloat = 20) -> NSImage? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let pixellateFilter = CIFilter.pixellate()
        pixellateFilter.inputImage = ciImage
        pixellateFilter.scale = Float(pixelSize)
        
        guard let outputImage = pixellateFilter.outputImage else { return nil }
        
        let croppedImage = outputImage.cropped(to: rect)
        
        guard let cgOutput = context.createCGImage(croppedImage, from: croppedImage.extent) else { return nil }
        
        return NSImage(cgImage: cgOutput, size: image.size)
    }
    
    func applyBlur(to image: NSImage, in rect: CGRect, radius: CGFloat = 10) -> NSImage? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = ciImage
        blurFilter.radius = Float(radius)
        
        guard let outputImage = blurFilter.outputImage else { return nil }
        
        let croppedImage = outputImage.cropped(to: rect)
        
        guard let cgOutput = context.createCGImage(croppedImage, from: croppedImage.extent) else { return nil }
        
        return NSImage(cgImage: cgOutput, size: image.size)
    }
}
