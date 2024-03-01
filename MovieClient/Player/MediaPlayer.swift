//Copyright © 2024 Chales Kerr. All rights reserved.

import Foundation
import AVFoundation
class MediaPlayer : NSObject {
    @IBOutlet var movieOptions: MovieOptionViewController!
    var player: AVPlayer
    var playerLayer:AVPlayerLayer
    var currentFrame : Int32 {
        get {
            return Int32( player.currentTime().seconds / 0.037)
        }
    }
    
    // =====================================================================================
    override init() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.autoresizingMask = [.layerHeightSizable,.layerWidthSizable]
        
        super.init()
    }
    
    // =====================================================================================
    func setFrame(frame:Int32) {
        let rate = 0.037
        let seconds = Double(frame) * rate
        let time = CMTimeMake(value: Int64(seconds * 1000.0),timescale: 1000)
        self.player.seek(to: time, toleranceBefore: .indefinite, toleranceAfter: .indefinite)
    }
    
    // ===================================================================================
    func loadMovie(url:URL) {
        player.pause()
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: item)
    }
    
    // ===========================================================================================
    func play() {
        player.play()
    }
    
    // ===========================================================================================
    func stop() {
        player.pause()
    }
    func clear() {
        player.pause()
        let asset = AVAsset()
        let item = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: item)
    }
}
