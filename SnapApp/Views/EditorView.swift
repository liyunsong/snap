import SwiftUI

struct EditorView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentAnnotation: Annotation?
    @State private var dragStart: CGPoint?
    @State private var showToolPanel = true
    
    var body: some View {
        ZStack {
            if let image = appState.capturedImage {
                Canvas { context, size in
                    do {
                        let nsImage = image
                        let imageSize = nsImage.size
                        let rect = CGRect(origin: .zero, size: imageSize)
                        
                        if let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                            let resolvedImage = Image(decorative: cgImage, scale: 1.0)
                            context.draw(resolvedImage, in: rect)
                        }
                    }
                    
                    for annotation in appState.annotations {
                        drawAnnotation(context: context, annotation: annotation)
                    }
                    
                    if let current = currentAnnotation {
                        drawAnnotation(context: context, annotation: current)
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDragChanged(value)
                        }
                        .onEnded { value in
                            handleDragEnded(value)
                        }
                )
                .frame(width: image.size.width, height: image.size.height)
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    if showToolPanel {
                        ToolPanelView()
                            .environmentObject(appState)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .frame(
            width: appState.capturedImage?.size.width ?? 800,
            height: appState.capturedImage?.size.height ?? 600
        )
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        if dragStart == nil {
            dragStart = value.startLocation
        }
        
        if appState.currentTool == .pen {
            if currentAnnotation == nil {
                currentAnnotation = Annotation(
                    type: .pen,
                    points: [value.location],
                    color: appState.selectedColor,
                    lineWidth: appState.lineWidth
                )
            } else {
                currentAnnotation?.points.append(value.location)
            }
        } else {
            currentAnnotation = createAnnotation(from: dragStart ?? value.startLocation, to: value.location)
        }
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        if let annotation = currentAnnotation {
            appState.addAnnotation(annotation)
        }
        currentAnnotation = nil
        dragStart = nil
    }
    
    private func createAnnotation(from start: CGPoint, to end: CGPoint) -> Annotation {
        let tool = getTool(for: appState.currentTool)
        return tool.createAnnotation(from: start, to: end, color: appState.selectedColor, lineWidth: appState.lineWidth)
    }
    
    private func getTool(for type: AnnotationType) -> DrawingTool {
        switch type {
        case .rectangle: return RectangleTool()
        case .circle: return CircleTool()
        case .arrow: return ArrowTool()
        case .line: return LineTool()
        case .pen: return PenTool()
        case .text: return TextTool()
        case .mosaic: return MosaicTool()
        case .blur: return BlurTool()
        }
    }
    
    private func drawAnnotation(context: GraphicsContext, annotation: Annotation) {
        let tool = getTool(for: annotation.type)
        tool.draw(in: context, annotation: annotation)
    }
}

class EditorWindow: NSWindowController {
    init(appState: AppState) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "编辑截图"
        window.center()
        window.setFrameAutosaveName("EditorWindow")
        
        let editorView = EditorView()
            .environmentObject(appState)
        
        window.contentView = NSHostingView(rootView: editorView)
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
