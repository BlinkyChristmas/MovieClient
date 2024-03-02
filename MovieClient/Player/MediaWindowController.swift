//Copyright © 2024 Chales Kerr. All rights reserved.

import Cocoa

class MediaWindowController : NSWindowController {
    
    @IBOutlet weak var mediaPlayer:MediaPlayer!
    @IBOutlet weak var movieOptions:MovieOptionViewController!
    
    //var screenObserver: Void = NotificationCenter.default.addObserver( MediaWindowController.self, selector: #selector(handleDisplayConnection), object: nil)


    
    override var windowNibName: NSNib.Name? {
        return "MediaWindow"
    }
    
    // =======================================================================================================================
    func setShow(state:Bool) {
        if (state) {
            Swift.print("Bring up Show Window")
            self.showWindow(nil)
            if (!self.window!.isFullscreen) {
                //self.window?.toggleFullScreen(nil)
            }
        }
        else {
            Swift.print("Close Show Window")

            if (self.window!.isFullscreen) {
                //self.window?.toggleFullScreen(nil)
            }
            self.window?.close()
            mediaPlayer.clear()
            
        }
    }
    
    // =======================================================================================================================
    deinit {
        //NotificationCenter.default.removeObserver(screenObserver)
    }
    
    // ======================================================================================================================
    override func windowDidLoad() {
        super.windowDidLoad()
        
        mediaPlayer.playerLayer.frame = self.window!.contentView!.layer!.bounds
        self.window!.contentView!.layer?.addSublayer(mediaPlayer.playerLayer)
    }

    // ======================================================================================================================
    @objc func handleDisplayConnection(notification: Notification) {
        
        if (NSScreen.screens.count > 1) {
            // We have more then one screen, we should be on the second screen
            if (self.window!.screen == NSScreen.main) {
                // We need to move this window to the second window
                    // It is!, we need to move it
                    let size = NSScreen.screens[1].visibleFrame.size
                    let origin = NSScreen.screens[1].visibleFrame.origin
                    self.window!.setFrame(NSRect(origin: origin, size: size), display: self.window!.isVisible )
            }
           
        }
        else if ( NSScreen.screens.count < 2) {
            if (self.window!.screen != NSScreen.main) {
                // We need to move this window to the main window
                let size = NSScreen.screens[0].visibleFrame.size
                let origin = NSScreen.screens[0].visibleFrame.origin
                self.window!.setFrame(NSRect(origin: origin, size: size), display: self.window!.isVisible )
            }

        }
    }

    // =======================================================================================================================
    func loadMovie(moviename:String) {

        let completename = moviename + ".mov"
        guard let url = movieOptions.movieLocation?.appendingPathComponent(completename) else {
            return
        }
        Swift.print("Load movie: \(url.path())")

        mediaPlayer.loadMovie(url: url)
    }
    
    // =======================================================================================================================
    func sync(frame:Int32) {
        let delta = mediaPlayer.currentFrame - frame
        if  abs(delta) > 6 {
            Swift.print("Sync movie to frame: \(frame)")

            mediaPlayer.setFrame(frame: frame)
        }
    }
    
    // =======================================================================================================================
    func playMovie(state:Bool,frame:Int32 = 0) {
        if (state) {
            Swift.print("Play movie at frame: \(frame)")
            mediaPlayer.setFrame(frame: frame)
            mediaPlayer.play()
        }
        else {
            Swift.print("Stop movie ")
            mediaPlayer.stop()
        }
    }
    

}
