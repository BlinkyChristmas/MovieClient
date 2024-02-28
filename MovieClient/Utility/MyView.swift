//Copyright © 2024 Charles Kerr. All rights reserved.

import Cocoa

class MyView : NSView {
    
    // ===============================================================================
    override var isOpaque: Bool {
        return true
    }
    
    // ===============================================================================
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.isOpaque = true
        self.layer!.autoresizingMask = [.layerHeightSizable,.layerWidthSizable]
        self.autoresizesSubviews = true
        self.autoresizingMask = [.height,.width]
        
    }
    
    
    // ===============================================================================
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer?.isOpaque = true
        
        self.autoresizesSubviews = true
        self.autoresizingMask = [.height,.width]
    }

}
