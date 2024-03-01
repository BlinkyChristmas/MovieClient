//Copyright © 2024 Chales Kerr. All rights reserved.

import Cocoa

class MediaWindowController : NSWindowController {
    
    @IBOutlet weak var mediaPlayer:MediaPlayer!
    @IBOutlet weak var movieOptions:MovieOptionViewController!
    
    override var windowNibName: NSNib.Name? {
        return "MediaWindow"
    }
    // =======================================================================================================================
    func setShow(state:Bool) {
        if (state) {
            Swift.print("Bring up Show Window")
            self.showWindow(nil)
            if (!self.window!.isFullscreen) {
                self.window?.toggleFullScreen(nil)
            }
        }
        else {
            Swift.print("Close Show Window")

            if (self.window!.isFullscreen) {
                self.window?.toggleFullScreen(nil)
            }
            self.window?.close()
            mediaPlayer.clear()
            
        }
    }
    
    // ======================================================================================================================
    override func windowDidLoad() {
        super.windowDidLoad()
        Swift.print("Window loaded")
        mediaPlayer.playerLayer.frame = self.window!.contentView!.layer!.bounds
        self.window!.contentView!.layer?.addSublayer(mediaPlayer.playerLayer)

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
