//
//  AppDelegate.swift
//  MovieClient
//
//  Created by Charles Kerr on 2/28/24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!
    @IBOutlet var networkOptions: NetworkOptionViewController!
    @IBOutlet var movieOptions : MovieOptionViewController!
    @IBOutlet var mediaWindowController : MediaWindowController!
    @IBOutlet var mediaPlayer : MediaPlayer!

    @IBOutlet var networkHolder : MyView!
    @IBOutlet var movieHolder : MyView!
    @IBOutlet var connection: Connection!
    
    @objc dynamic var mode = "Start"
    
    @objc dynamic var currentState: String = "Stopped"
    
    var observation: NSKeyValueObservation?
    
    var stateOnTimer:Timer? = nil
    var stateOffTimer:Timer? = nil

    
    // ============================================================================================
    deinit {
        observation?.invalidate()
        observation = nil
    }


    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true ;
    }
    
    
    // ===========================================================================================
    func scheduleStateOnTimer() {
        stateOnTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true, block: { _ in
            // We need to a few things
            // We should connect
            DispatchQueue.main.async {
                if self.networkOptions.connectTime.inRange(), !self.connection.connected {
                    
                    _ = self.connection.connect(serverIP: self.networkOptions.serverAddress, serverPort: String(self.networkOptions.serverPort))
                }
            }
         })
        
    }
    // ===========================================================================================
    func scheduleStateOffTimer() {
        stateOffTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true, block: { _ in
            // We need to a few things
            DispatchQueue.main.async {
                if !self.networkOptions.connectTime.inRange(), self.connection.connected {
                    self.mediaWindowController.setShow(state: false)
                    
                    self.connection.stop(error:nil)
                }
            }
        })
    }
    // ============================================================================================
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        networkOptions.loadFromPreference()
        networkOptions.view.frame = self.networkHolder.bounds
        self.networkHolder.addSubview(networkOptions.view)
        
        movieOptions.loadFromPreference()
        movieOptions.view.frame = self.movieHolder.bounds
        self.movieHolder.addSubview(movieOptions.view)
        
        
        observation = observe(\.connection?.connected, options: .new, changeHandler: { [self] object, change in
            //Swift.print("Network state changed!")
            if (!self.connection.connected) {
                mediaPlayer.clear()
            }
            self.updateCurrentState() 
         })
            

    }
    // ============================================================================================
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // ============================================================================================
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // ============================================================================================
   func updateCurrentState() {
       DispatchQueue.main.async{
           if (self.connection.connected) {
               self.currentState = "Connected"
           }
           else {
               if self.mode == "Start" {
                   self.currentState = "Stopped"
               }
               else {
                   // We are either waiting to connect, or connecting
                   if (self.networkOptions.connectTime.inRange()) {
                       self.currentState = "Connecting"
                   }
                   else {
                       self.currentState = "Waiting for connect time: " + self.networkOptions.connectTime.getNextStart()
                   }
               }
           }
       }
    }


    // ============================================================================================
    @IBAction func changeAction(_ sender:NSButton) {
        // First, determine if we can even move on
        if self.window.makeFirstResponder(sender) {
            // Now, we determine what mode we are transistioning into?
            if (mode == "Start") {
                // We are going to start everything!
                // Save to our Preferences
                networkOptions.saveToPreference()
                movieOptions.saveToPreference()
                connection.myHandle = networkOptions.handle
                networkOptions.isEnabled = false
                movieOptions.isEnabled = false
                
                mode = "Stop"
                scheduleStateOffTimer()
                scheduleStateOnTimer()
                if networkOptions.connectTime.inRange() {
                    // We should connect
                    _ = connection.connect(serverIP: networkOptions.serverAddress, serverPort: String(networkOptions.serverPort))
                }
            }
            
            else {
                // We want to stop any network stuff and timers
                self.mediaPlayer.clear()
                mediaWindowController.close()
                networkOptions.isEnabled = true
                movieOptions.isEnabled = true
                connection.stop(error: nil)
                stateOnTimer?.invalidate()
                stateOnTimer = nil
                stateOffTimer?.invalidate()
                stateOffTimer = nil
                mode = "Start"
            }
            updateCurrentState()

        }
    }
}

