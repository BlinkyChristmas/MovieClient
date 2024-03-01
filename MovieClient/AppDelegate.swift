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
    
    var stateTimer:Timer? = nil
    var connectTimer:Timer? = nil

    
    // ============================================================================================
    deinit {
        observation?.invalidate()
        observation = nil
    }


    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true ;
    }
    
    // ============================================================================================
    func scheduleReconnectTimer() {
        self.connectTimer = Timer.scheduledTimer(withTimeInterval: 90.0, repeats: false, block: { _ in
            self.connectTimer?.invalidate()
            self.connectTimer = nil
            // We should connect
            DispatchQueue.main.async {
                Swift.print("Attempting connect")
                self.scheduleReconnectTimer()
                _ = self.connection.connect(serverIP: self.networkOptions.serverAddress, serverPort: String(self.networkOptions.serverPort))
            }
            
        })

    }
    
    // ===========================================================================================
    func scheduleStateOnTimer() {
        stateTimer = Timer.scheduledTimer(withTimeInterval: networkOptions.connectTime.getStartInterval(), repeats: false, block: { _ in
            // We need to a few things
            self.scheduleStateOffTimer()
            // We should connect
            self.scheduleReconnectTimer()
            _ = self.connection.connect(serverIP: self.networkOptions.serverAddress, serverPort: String(self.networkOptions.serverPort))
        })
        
    }
    // ===========================================================================================
    func scheduleStateOffTimer() {
        stateTimer = Timer.scheduledTimer(withTimeInterval: networkOptions.connectTime.getEndInterval(), repeats: false, block: { _ in
            // We need to a few things
            self.mediaWindowController.setShow(state: false)
            self.connection.stop(error:nil)
            self.connectTimer?.invalidate()
            self.connectTimer = nil
            self.scheduleStateOnTimer()
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
            Swift.print("Network state changed!")
            self.updateCurrentState()
            if (self.connection.connected){
                self.connectTimer?.invalidate() ;
                self.connectTimer = nil
            }
            if (!self.connection.connected   && self.networkOptions.connectTime.inRange() && self.connectTimer == nil) {
                DispatchQueue.main.async {
                    self.scheduleReconnectTimer()
                }
            }
            
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
                       self.currentState = "Waiting for connect time"
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
                
                if networkOptions.connectTime.inRange() {
                    // We should connect
                    self.scheduleReconnectTimer()
                    _ = connection.connect(serverIP: networkOptions.serverAddress, serverPort: String(networkOptions.serverPort))
                }
                else {
                    scheduleStateOnTimer()
                }
            }
            
            else {
                // We want to stop any network stuff and timers
                
                networkOptions.isEnabled = true
                movieOptions.isEnabled = true
                connection.stop(error: nil)
                connectTimer?.invalidate()
                connectTimer = nil
                stateTimer?.invalidate()
                stateTimer = nil
                mode = "Start"
            }
            updateCurrentState()

        }
    }
}

