import AppKit
import SwiftUI

class SelectionOverlayWindow: NSWindow {
    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?
    private var selectionView: SelectionView?
    var onAreaSelected: ((CGRect) -> Void)?
    
    init() {
        let screenFrame = NSScreen.main?.frame ?? .zero
        
        super.init(
            contentRect: screenFrame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.level = .screenSaver
        self.backgroundColor = NSColor.black.withAlphaComponent(0.3)
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        let selectionView = SelectionView(frame: screenFrame)
        selectionView.overlayWindow = self
        self.contentView = selectionView
        self.selectionView = selectionView
        
        self.makeKeyAndOrderFront(nil)
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            close()
        }
    }
    
    func updateSelection(start: CGPoint, current: CGPoint) {
        selectionView?.startPoint = start
        selectionView?.currentPoint = current
        selectionView?.needsDisplay = true
    }
    
    func finishSelection(rect: CGRect) {
        onAreaSelected?(rect)
        close()
    }
}

class SelectionView: NSView {
    weak var overlayWindow: SelectionOverlayWindow?
    var startPoint: CGPoint?
    var currentPoint: CGPoint?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        NSColor.black.withAlphaComponent(0.3).setFill()
        dirtyRect.fill()
        
        if let start = startPoint, let current = currentPoint {
            let selectionRect = CGRect(
                x: min(start.x, current.x),
                y: min(start.y, current.y),
                width: abs(current.x - start.x),
                height: abs(current.y - start.y)
            )
            
            NSColor.clear.setFill()
            selectionRect.fill(using: .copy)
            
            NSColor.white.setStroke()
            let path = NSBezierPath(rect: selectionRect)
            path.lineWidth = 2
            path.stroke()
            
            let shadowPath = NSBezierPath(rect: bounds)
            shadowPath.append(NSBezierPath(rect: selectionRect).reversed)
            NSColor.black.withAlphaComponent(0.5).setFill()
            shadowPath.fill()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        startPoint = event.locationInWindow
        currentPoint = startPoint
        needsDisplay = true
    }
    
    override func mouseDragged(with event: NSEvent) {
        currentPoint = event.locationInWindow
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        guard let start = startPoint, let current = currentPoint else { return }
        
        let rect = CGRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(current.x - start.x),
            height: abs(current.y - start.y)
        )
        
        if rect.width > 10 && rect.height > 10 {
            overlayWindow?.finishSelection(rect: rect)
        } else {
            overlayWindow?.close()
        }
    }
}
