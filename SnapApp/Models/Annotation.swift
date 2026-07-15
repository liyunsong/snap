import SwiftUI
import AppKit

enum AnnotationType: Codable, Equatable {
    case rectangle
    case circle
    case arrow
    case line
    case pen
    case text
    case mosaic
    case blur
}

struct Annotation: Identifiable, Codable, Equatable {
    let id: UUID
    var type: AnnotationType
    var points: [CGPoint]
    var color: CodableColor
    var lineWidth: CGFloat
    var text: String?
    var rect: CGRect?
    
    init(id: UUID = UUID(), type: AnnotationType, points: [CGPoint], color: Color, lineWidth: CGFloat, text: String? = nil, rect: CGRect? = nil) {
        self.id = id
        self.type = type
        self.points = points
        self.color = CodableColor(color)
        self.lineWidth = lineWidth
        self.text = text
        self.rect = rect
    }
    
    var swiftUIColor: Color {
        color.color
    }
}

/// Codable wrapper for SwiftUI Color (SwiftUI.Color is not Codable).
struct CodableColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    init(_ color: Color) {
        let nsColor = NSColor(color)
        let converted = nsColor.usingColorSpace(.sRGB) ?? nsColor
        red = Double(converted.redComponent)
        green = Double(converted.greenComponent)
        blue = Double(converted.blueComponent)
        opacity = Double(converted.alphaComponent)
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
}
