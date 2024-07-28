//
//  ColorPickerButton.swift
//  MeshBuddy
//
//  Created by LiYanan2004 on 2024/7/28.
//

import SwiftUI

struct ColorPickerButton<Content: View>: View {
    @Binding var selection: Color
    var supportsOpacity: Bool = true
    @ViewBuilder var content: () -> Content
    
    @State private var colorHandler: ColorHandler?
    
    var body: some View {
        content()
            .simultaneousGesture(tapGesture)
    }
    
    private var tapGesture: some Gesture {
        TapGesture()
            .onEnded { _ in
                let handler = ColorHandler(color: $selection)
                self.colorHandler = handler
                
                let colorPanel = NSColorPanel.shared
                colorPanel.setTarget(handler)
                colorPanel.setAction(#selector(handler.handle))
                colorPanel.isContinuous = true
                colorPanel.color = NSColor(selection)
                colorPanel.showsAlpha = supportsOpacity
                colorPanel.orderFront(nil)
            }
    }
    
    @MainActor
    class ColorHandler {
        @Binding var color: Color
        
        init(color: Binding<Color>) {
            _color = color
        }
        
        @objc func handle(_ sender: NSColorPanel) {
            color = Color(nsColor: sender.color)
        }
    }
}

#Preview {
    ColorPickerButton(selection: .constant(.red)) {
        
    }
}
