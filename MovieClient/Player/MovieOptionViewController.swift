//Copyright © 2024 Chales Kerr. All rights reserved.

import Cocoa

class MovieOptionViewController : NSViewController {
    override var nibName: NSNib.Name? {
        return "MovieOptionView"
    }
    
    @objc dynamic var movieLocation : URL?
    @objc dynamic var projectorSerial = ""
    @objc dynamic var isEnabled = true
    
    @IBOutlet var comboBox:NSComboBox!
    
    // =======================================================================================================
    @IBAction func selectMovieLocation(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.title = "Movie Location Selection"
        panel.prompt = "Set location"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.directoryURL = movieLocation
        panel.beginSheetModal(for: self.view.window!) { response in
            if (response == .OK ) {
                self.movieLocation = panel.url
            }
        }

    }
    
    // ======================================================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Lets populate our combo box!
        comboBox.removeAllItems()
        comboBox.addItems(withObjectValues: serialDevices())
    }

    // =======================================================================================================
    func loadFromPreference() -> Void {
        projectorSerial = UserDefaults.standard.string(forKey: "PROJECTORSERIAL") ?? ""

        let temp1 = UserDefaults.standard.data(forKey: "MOVIELOCATION")
        guard temp1 != nil else {
            if (movieLocation != nil) {
                movieLocation?.stopAccessingSecurityScopedResource()
            }
            let movies =  FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask)
            if !movies.isEmpty {
                self.movieLocation = movies[0]
            }
            return
        }
        movieLocation = temp1?.securityBookmark
        _ = movieLocation?.startAccessingSecurityScopedResource()

    }
    
    
    // =======================================================================================================
    func saveToPreference() -> Void {
        UserDefaults.standard.setValue(projectorSerial, forKey: "PROJECTORSERIAL")
        UserDefaults.standard.setValue(movieLocation?.securityData, forKey: "MOVIELOCATION")

    }
    
    // =======================================================================================================
    func cancelEditor() {
        for entry in self.view.subviews {
            (entry as? NSTextField)?.abortEditing()
        }
    }

}
