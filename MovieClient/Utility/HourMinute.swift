//Copyright © 2024 Charles Kerr. All rights reserved.

import Foundation

class HourMinute : NSObject {
    
    
    @objc dynamic var hour = 0
    @objc dynamic var minute = 0
    
    // ===========================================================================================================
    override var description: String {
        return String(format:"%02i:%02i",hour,minute)
    }

    // ===========================================================================================================
    @objc dynamic var value:String {
        get{
            return self.description
        }
        set {
            try! load(newValue)
        }
    }
    // ===========================================================================================================
    var dateString:String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        let tnow = dateFormatter.string(from:self.date)
        let str = String(tnow)

        return str
    }
    // ===========================================================================================================
    @objc dynamic var date:Date {
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = .current
            dateFormatter.dateFormat = "MM/dd/yyyy-HH:mm"
            var tnow = dateFormatter.string(from:Date())
            let newsub = String(format: "-%02i:%02i",hour,minute)
            // Now, we need to change out the hour and minute
            let index = tnow.firstIndex(of: "-")!
            tnow.replaceSubrange(index..<tnow.endIndex, with: newsub)
            return dateFormatter.date(from: tnow)!

        }
        set {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = .current
            dateFormatter.dateFormat = "MM/dd/yyyy-HH:mm"
            let tnow = dateFormatter.string(from:newValue)
            let str = String(tnow[tnow.index(after: tnow.firstIndex(of: "-")!)..<tnow.endIndex])
            try! load(str)
        }
    }
    // ===========================================================================================================
    init(hour: Int = 0, minute: Int = 0) {
        self.hour = hour
        self.minute = minute
    }
    
    //===========================================================================================================
    convenience init(_ value:String) throws {
        self.init()
        try load(value)
    }

    //===========================================================================================================
    func load(_ value:String) throws {
        guard let colon = value.firstIndex(of: ":") else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"No colon was present in '\(value)'"])
        }
        guard let temp = Int(value[value.startIndex..<colon]) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"Hour is not an integer '\(value[value.startIndex..<colon])'"])
        }
        
        guard temp >= 0 && temp <= 23 else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"Hour was not in range of 0...23 '\(value[value.startIndex..<colon])'"])
        }
        hour = temp
        
        guard let mtemp = Int(value[value.index(after:colon)..<value.endIndex]) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"Minute is not an integer '\(value[value.index(after:colon)..<value.endIndex])'"])
        }
        
        guard mtemp >= 0 && temp <= 59 else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey:"Hour was not in range of 0...59 '\(value[value.index(after:colon)..<value.endIndex])'"])
        }

        minute = mtemp
        
    }
    
    // =============================================================================================
    func intervalFrom(date:Date) -> TimeInterval {
        return self.date.timeIntervalSince(date)
    }

    // =============================================================================================
    func loadFromPreferenceWithKey(key:String) {
        self.value = UserDefaults.standard.string(forKey: key) ?? "00:00"
    }
    // =============================================================================================
    func saveToPreferenceWithKey(key:String) {
        UserDefaults.standard.setValue(self.value, forKey: key)
    }
    // =============================================================================================
    static func == (lhs: HourMinute, rhs: HourMinute) -> Bool {
        return lhs.minute == rhs.minute && lhs.hour == rhs.hour
    }
    
    // =============================================================================================
    static func != (lhs: HourMinute, rhs: HourMinute) -> Bool {
        return !(lhs==rhs)
    }

    // =============================================================================================
    static func < (lhs: HourMinute, rhs: HourMinute) -> Bool {
        if (lhs.hour <= rhs.hour) {
            return lhs.minute < rhs.minute
        }
        return false
    }
    
    // =============================================================================================
    static func <= (lhs: HourMinute, rhs: HourMinute) -> Bool {
        return lhs < rhs || lhs == rhs
    }

    // =============================================================================================
    static func >= (lhs: HourMinute, rhs: HourMinute) -> Bool {
        return !(lhs < rhs)
    }
    // =============================================================================================
    static func > (lhs: HourMinute, rhs: HourMinute) -> Bool {
        return !(lhs <= rhs)
    }
}

// ==============================================================================================
class HourMinuteRange : NSObject {
    @objc dynamic var startTime = HourMinute()
    @objc dynamic var endTime = HourMinute()
    
    // ==============================================================================================
    override var description: String {
        return startTime.description + "," + endTime.description
    }
    
    // ==============================================================================================
    init(startTime: HourMinute = HourMinute(), endTime: HourMinute = HourMinute()) {
        self.startTime = startTime
        self.endTime = endTime
    }
    
    // ==============================================================================================
    convenience init(value:String) {
        self.init()
        let startstring = String(value[value.startIndex..<value.firstIndex(of: ":")!])
        let endstring = String (value[value.index(after: value.firstIndex(of: ":")!)..<value.endIndex])
        startTime = try! HourMinute(startstring)
        endTime = try! HourMinute(endstring)
    }
    
    // ==============================================================================================
    func inRange() -> Bool {
        return startTime.date <= Date.now && endTime.date > Date.now
    }
    
    // =============================================================================================
    func getStartInterval() -> TimeInterval {
        if (self.inRange()) {
            return TimeInterval(0)
        }
        var interval = startTime.intervalFrom(date: Date.now)
        if (interval < 0.0) {
            interval += 24.0 * 60.0 * 60.0
        }
        return interval
    }
    // =============================================================================================
    func getNextStart() -> String {
        if ( Date() < self.startTime.date ) {
            return self.startTime.dateString
        }
        else {
            var temp = self.startTime.date ;
            temp = temp.addingTimeInterval(24.0 * 60.0 * 60.0 )
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = .current
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            let tnow = dateFormatter.string(from:temp)
            let str = String(tnow)
            return str
        }
             

    }
    // =============================================================================================
    func getEndInterval() -> TimeInterval {
        var interval = endTime.intervalFrom(date: Date.now)
        if (interval < 0.0) {
            interval += 24.0 * 60.0 * 60.0
        }
        return interval
    }

}
