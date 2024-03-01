//Copyright © 2024 Chales Kerr. All rights reserved.

import Cocoa
extension NSWindow {
    var isFullscreen : Bool {
        //return (([self styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask);
        //self.styleMask
        return (self.styleMask.rawValue & NSWindow.StyleMask.fullScreen.rawValue) != 0
    }
    
}
