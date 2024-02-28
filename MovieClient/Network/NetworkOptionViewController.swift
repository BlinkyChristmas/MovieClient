//Copyright © 2024 Chales Kerr. All rights reserved.

import Cocoa

class NetworkOptionViewController : NSViewController {
    
    @objc dynamic var isEnabled = true
    @objc dynamic var connectTime = HourMinuteRange()
    
    @objc dynamic var serverPort = 50000
    @objc dynamic var serverAddress = ""
    @objc dynamic var handle = "MovieClient"
    
    override var nibName: NSNib.Name? {
        return "NetworkOptionView"
    }
    
    // =======================================================================================================
    func loadFromPreference() -> Void {
        connectTime.startTime.loadFromPreferenceWithKey(key: "BEGINTIME")
        connectTime.endTime.loadFromPreferenceWithKey(key: "ENDTIME")
        handle = UserDefaults.standard.string(forKey: "CLIENTHANDLE") ?? "Media Client"
        serverPort = UserDefaults.standard.integer(forKey: "SERVERPORT")
        if serverPort == 0 {
            serverPort = 50000
        }
        serverAddress = UserDefaults.standard.string(forKey: "SERVERIP") ?? ""
    }
    
    // =======================================================================================================
    func saveToPreference() -> Void {
        UserDefaults.standard.setValue(serverPort, forKey: "SERVERPORT")
        UserDefaults.standard.setValue(serverAddress, forKey: "SERVERIP")
        UserDefaults.standard.setValue(handle, forKey: "CLIENTHANDLE")
        connectTime.startTime.saveToPreferenceWithKey(key: "STARTTIME")
        connectTime.endTime.saveToPreferenceWithKey(key: "ENDTIME")
    }
    
    // =======================================================================================================
    func cancelEditor() {
        for entry in self.view.subviews {
            (entry as? NSTextField)?.abortEditing()
        }
    }
}
