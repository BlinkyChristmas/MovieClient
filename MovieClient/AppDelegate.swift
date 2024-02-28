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
    
    @IBOutlet var networkHolder : MyView!
    @IBOutlet var movieHolder : MyView!
    
    
    @objc dynamic var mode = "Start"
    
    @objc dynamic var currentState:String {
        return "Stopped"
    }
    
    // ============================================================================================
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true ;
    }
    
    // ============================================================================================
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        networkOptions.loadFromPreference()
        networkOptions.view.frame = self.networkHolder.bounds
        self.networkHolder.addSubview(networkOptions.view)
        
        movieOptions.loadFromPreference()
        movieOptions.view.frame = self.movieHolder.bounds
        self.movieHolder.addSubview(movieOptions.view)
    
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
    @IBAction func changeAction(_ sender:NSButton) {
        // First, determine if we can even move on
        if self.window.makeFirstResponder(sender) {
            // Now, we determine what mode we are transistioning into?
            if (mode == "Start") {
                // We are going to start everything!
                // Save to our Preferences
                networkOptions.saveToPreference()
                movieOptions.saveToPreference()
                
                networkOptions.isEnabled = false
                movieOptions.isEnabled = false
                
                mode = "Stop"
            }
            
            else {
                // We want to stop any network stuff and timers
                
                networkOptions.isEnabled = true
                movieOptions.isEnabled = true
                
                mode = "Start"

            }
        }
    }
}

