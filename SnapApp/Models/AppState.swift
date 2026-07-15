import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var currentTool: AnnotationType = .rectangle
    @Published var annotations: [Annotation] = []
    @Published var selectedColor: Color = .red
    @Published var lineWidth: CGFloat = 3.0
    @Published var capturedImage: NSImage?
    @Published var isEditorVisible: Bool = false
    @Published var isSelectingArea: Bool = false
    
    private var undoStack: [[Annotation]] = []
    private var redoStack: [[Annotation]] = []
    
    func addAnnotation(_ annotation: Annotation) {
        saveStateForUndo()
        annotations.append(annotation)
        redoStack.removeAll()
    }
    
    func removeAnnotation(_ annotation: Annotation) {
        saveStateForUndo()
        annotations.removeAll { $0.id == annotation.id }
        redoStack.removeAll()
    }
    
    func undo() {
        guard !undoStack.isEmpty else { return }
        redoStack.append(annotations)
        annotations = undoStack.removeLast()
    }
    
    func redo() {
        guard !redoStack.isEmpty else { return }
        undoStack.append(annotations)
        annotations = redoStack.removeLast()
    }
    
    var canUndo: Bool {
        !undoStack.isEmpty
    }
    
    var canRedo: Bool {
        !redoStack.isEmpty
    }
    
    private func saveStateForUndo() {
        undoStack.append(annotations)
        if undoStack.count > 50 {
            undoStack.removeFirst()
        }
    }
    
    func reset() {
        annotations.removeAll()
        undoStack.removeAll()
        redoStack.removeAll()
        capturedImage = nil
        isEditorVisible = false
        isSelectingArea = false
    }
    
    func startCapture() {
        isSelectingArea = true
    }
    
    func setCapturedImage(_ image: NSImage) {
        self.capturedImage = image
        self.isEditorVisible = true
        self.isSelectingArea = false
        self.annotations.removeAll()
        self.undoStack.removeAll()
        self.redoStack.removeAll()
    }
}
