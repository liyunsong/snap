import SwiftUI

struct ToolPanelView: View {
    @EnvironmentObject var appState: AppState
    @State private var showColorPicker = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text("工具")
                .font(.headline)
                .padding(.bottom, 4)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 8) {
                ToolButton(icon: "rectangle", tool: .rectangle, appState: appState)
                ToolButton(icon: "circle", tool: .circle, appState: appState)
                ToolButton(icon: "arrow.up.right", tool: .arrow, appState: appState)
                ToolButton(icon: "line.diagonal", tool: .line, appState: appState)
                ToolButton(icon: "pencil.tip", tool: .pen, appState: appState)
                ToolButton(icon: "character", tool: .text, appState: appState)
                ToolButton(icon: "square.grid.3x3.fill", tool: .mosaic, appState: appState)
                ToolButton(icon: "eye.slash.fill", tool: .blur, appState: appState)
            }
            
            Divider()
            
            HStack {
                Text("颜色")
                Spacer()
                ColorPickerButton(selectedColor: $appState.selectedColor)
            }
            
            HStack {
                Text("粗细")
                Spacer()
                Text("\(Int(appState.lineWidth))")
                    .frame(width: 30)
            }
            
            Slider(value: $appState.lineWidth, in: 1...20, step: 1)
            
            Divider()
            
            HStack(spacing: 8) {
                Button(action: {
                    appState.undo()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .frame(maxWidth: .infinity)
                }
                .disabled(!appState.canUndo)
                
                Button(action: {
                    appState.redo()
                }) {
                    Image(systemName: "arrow.uturn.forward")
                        .frame(maxWidth: .infinity)
                }
                .disabled(!appState.canRedo)
            }
            
            Divider()
            
            Button(action: copyToClipboard) {
                HStack {
                    Image(systemName: "doc.on.clipboard")
                    Text("复制")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Button(action: saveToFile) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("保存")
                }
                .frame(maxWidth: .infinity)
            }
            
            Button(action: close) {
                HStack {
                    Image(systemName: "xmark")
                    Text("关闭")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor).opacity(0.95))
        .cornerRadius(12)
        .shadow(radius: 10)
        .frame(width: 200)
    }
    
    private func copyToClipboard() {
        guard let image = appState.capturedImage else { return }
        let annotatedImage = ClipboardHelper.shared.renderAnnotatedImage(baseImage: image, annotations: appState.annotations)
        ClipboardHelper.shared.copyImageToClipboard(annotatedImage)
    }
    
    private func saveToFile() {
        guard let image = appState.capturedImage else { return }
        let annotatedImage = ClipboardHelper.shared.renderAnnotatedImage(baseImage: image, annotations: appState.annotations)
        _ = ClipboardHelper.shared.saveImageToFile(annotatedImage)
    }
    
    private func close() {
        appState.reset()
        NSApplication.shared.keyWindow?.close()
    }
}

struct ToolButton: View {
    let icon: String
    let tool: AnnotationType
    let appState: AppState
    
    var body: some View {
        Button(action: {
            appState.currentTool = tool
        }) {
            Image(systemName: icon)
                .frame(width: 40, height: 40)
                .background(appState.currentTool == tool ? Color.accentColor : Color.clear)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct ColorPickerButton: View {
    @Binding var selectedColor: Color
    @State private var showPicker = false
    
    let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple,
        .pink, .gray, .black, .white
    ]
    
    var body: some View {
        Button(action: {
            showPicker.toggle()
        }) {
            Circle()
                .fill(selectedColor)
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
        .popover(isPresented: $showPicker) {
            VStack {
                Text("选择颜色")
                    .font(.headline)
                    .padding()
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 30))], spacing: 8) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                selectedColor = color
                                showPicker = false
                            }
                    }
                }
                .padding()
            }
            .frame(width: 200)
        }
    }
}
