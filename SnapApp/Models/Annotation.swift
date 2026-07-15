import SwiftUI

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
    var color: Color
    var lineWidth: CGFloat
    var text: String?
    var rect: CGRect?
    
    init(id: UUID = UUID(), type: AnnotationType, points: [CGPoint], color: Color, lineWidth: CGFloat, text: String? = nil, rect: CGRect? = nil) {
        self.id = id
        self.type = type
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.text = text
        self.rect = rect
    }
}

extension CGPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        self.init(x: x, y: y)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, alpha
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let components = NSColor(self).cgColor.components else { return }
        try container.encode(components[0], forKey: .red)
        try container.encode(components[1], forKey: .green)
        try container.encode(components[2], forKey: .blue)
        try container.encode(components[3], forKey: .alpha)
    }
}
