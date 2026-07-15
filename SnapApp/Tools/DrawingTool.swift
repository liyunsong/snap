import SwiftUI

protocol DrawingTool {
    func draw(in context: GraphicsContext, annotation: Annotation)
    func createAnnotation(from startPoint: CGPoint, to endPoint: CGPoint, color: Color, lineWidth: CGFloat) -> Annotation
}

struct RectangleTool: DrawingTool {
    func draw(in context: GraphicsContext, annotation: Annotation) {
        guard annotation.points.count >= 2 else { return }
        let rect = rectFromPoints(annotation.points[0], annotation.points[1])
        let path = Path(rect)
        context.stroke(path, with: .color(annotation.swiftUIColor), lineWidth: annotation.lineWidth)
    }
    
    func createAnnotation(from startPoint: CGPoint, to endPoint: CGPoint, color: Color, lineWidth: CGFloat) -> Annotation {
        Annotation(type: .rectangle, points: [startPoint, endPoint], color: color, lineWidth: lineWidth)
    }
    
    private func rectFromPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGRect {
        CGRect(x: min(p1.x, p2.x), y: min(p1.y, p2.y), width: abs(p2.x - p1.x), height: abs(p2.y - p1.y))
    }
}

struct CircleTool: DrawingTool {
    func draw(in context: GraphicsContext, annotation: Annotation) {
        guard annotation.points.count >= 2 else { return }
        let rect = rectFromPoints(annotation.points[0], annotation.points[1])
        let path = Path(ellipseIn: rect)
        context.stroke(path, with: .color(annotation.swiftUIColor), lineWidth: annotation.lineWidth)
    }
    
    func createAnnotation(from startPoint: CGPoint, to endPoint: CGPoint, color: Color, lineWidth: CGFloat) -> Annotation {
        Annotation(type: .circle, points: [startPoint, endPoint], color: color, lineWidth: lineWidth)
    }
    
    private func rectFromPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGRect {
        CGRect(x: min(p1.x, p2.x), y: min(p1.y, p2.y), width: abs(p2.x - p1.x), height: abs(p2.y - p1.y))
    }
}

struct LineTool: DrawingTool {
    func draw(in context: GraphicsContext, annotation: Annotation) {
        guard annotation.points.count >= 2 else { return }
        var path = Path()
        path.move(to: annotation.points[0])
        path.addLine(to: annotation.points[1])
        context.stroke(path, with: .color(annotation.swiftUIColor), style: StrokeStyle(lineWidth: annotation.lineWidth, lineCap: .round))
    }
    
    func createAnnotation(from startPoint: CGPoint, to endPoint: CGPoint, color: Color, lineWidth: CGFloat) -> Annotation {
        Annotation(type: .line, points: [startPoint, endPoint], color: color, lineWidth: lineWidth)
    }
}

struct ArrowTool: DrawingTool {
    func draw(in context: GraphicsContext, annotation: Annotation) {
        guard annotation.points.count >= 2 else { return }
        let from = annotation.points[0]
        let to = annotation.points[1]
        
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        
        let angle = atan2(to.y - from.y, to.x - from.x)
        let arrowLength = annotation.lineWidth * 3
        let arrowAngle = CGFloat.pi / 6
        
        let point1 = CGPoint(
            x: to.x - arrowLength * cos(angle - arrowAngle),
            y: to.y - arrowLength * sin(angle - arrowAngle)
        )
        let point2 = CGPoint(
            x: to.x - arrowLength * cos(angle + arrowAngle),
            y: to.y - arrowLength * sin(angle + arrowAngle)
        )
        
        path.move(to: to)
        path.addLine(to: point1)
        path.move(to: to)
        path.addLine(to: point2)
        
        context.stroke(path, with: .color(annotation.swiftUIColor), style: StrokeStyle(lineWidth: annotation.lineWidth, lineCap: .round))
    }
    
    func createAnnotation(from startPoint: CGPoint, to endPoint: CGPoint, color: Color, lineWidth: CGFloat) -> Annotation {
        Annotation(type: .arrow, points: [startPoint, endPoint], color: color, lineWidth: lineWidth)
    }
}

struct PenTool: DrawingTool {
    func draw(in context: GraphicsContext, annotation: Annotation) {
        guard annotation.points.count > 1 else { return }
        var path = Path()
        path.move(to: annotation.points[0])
        for point in annotation.points.dropFirst() {
            path.addLine(to: point)
        }
        context.stroke(path, with: .color(annotation.swiftUIColor), style: StrokeStyle(lineWidth: annotation.lineWidth, lineCap: .round, lineJoin: .round))
    }
    
    func createAnnotation(from startPoint: CGPoint, to endPoint: CGPoint, color: Color, lineWidth: CGFloat) -> Annotation {
        Annotation(type: .pen, points: [startPoint, endPoint], color: color, lineWidth: lineWidth)
    }
}

struct TextTool: DrawingTool {
    func draw(in context: GraphicsContext, annotation: Annotation) {
        guard let text = annotation.text, let rect = annotation.rect else { return }
        context.draw(Text(text).foregroundColor(annotation.swiftUIColor).font(.system(size: 16)), at: CGPoint(x: rect.midX, y: rect.midY))
    }
    
    func createAnnotation(from startPoint: CGPoint, to endPoint: CGPoint, color: Color, lineWidth: CGFloat) -> Annotation {
        let rect = CGRect(x: startPoint.x, y: startPoint.y, width: 200, height: 30)
        return Annotation(type: .text, points: [startPoint], color: color, lineWidth: lineWidth, text: "Text", rect: rect)
    }
}
