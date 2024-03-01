//Copyright © 2024 Chales Kerr. All rights reserved.

import Foundation

// ==============================================================================
let IDENTPACKET = Int32(1)
let IDENTPACKETSIZE = 38
let IDENTHANDLEOFFSET = 8
let IDENTHANDLESIZE = 30

// =================================================================================
let SYNCPACKET = Int32(2)
let SYNCFRAMEOFFSET = 8

// =================================================================================
let LOADPACKET = Int32(3)
let MUSICNAMEOFFSET = 8
let MUSICNAMESIZE = 30

// ===============================================================================
let NOPPACKET = Int32(4)
let NOPRESPONDOFFSET = 8
let NOPPACKETSIZE = 12

// ===============================================================================
let SHOWPACKET = Int32(5)
let SHOWSTATEOFFSET = 8

// ===============================================================================
let PLAYPACKET = Int32(6)
let PLAYSTATOFFSET = 8
let PLAYFRAMEOFFSET = 12


extension Data {
    // ===================================================================================================================================================
    // Get a packet ID
    var packetID: Int32 {
        get {
            return self.withUnsafeBytes { ptr in
                ptr.loadUnaligned(fromByteOffset: 0, as: Int32.self)
            }.byteSwapped
            
        }
        set {
            self[0..<4] = newValue.byteSwapped.data
        }
    }
    
    // ===================================================================================================================================================
    var packetLength: Int32 {
        get {
            return self.withUnsafeBytes { ptr in
                ptr.loadUnaligned(fromByteOffset: 4, as: Int32.self)
            }.byteSwapped
            
        }
        set {
            self[4..<8] = newValue.byteSwapped.data
        }
    }
    
    // ===================================================================================================================================================
    var identHandle:String {
        get {
            return self[IDENTHANDLEOFFSET..<IDENTHANDLEOFFSET + IDENTHANDLESIZE].nonNullAsciiString
        }
        set {
            var temp = newValue.data(using: .ascii)
            if (temp == nil) {
                temp = Data(count: IDENTHANDLESIZE)
            }
            let delta = IDENTHANDLESIZE - temp!.count
            if delta > 0 {
                temp!.append(Data(count: delta))
            }
            self[IDENTHANDLEOFFSET..<IDENTHANDLEOFFSET+IDENTHANDLESIZE] = temp!
        }
    }
    
    // ===================================================================================================================================================
    var syncFrame:Int32 {
        get {
            self.withUnsafeBytes { ptr in
                return self.withUnsafeBytes { ptr in
                    ptr.loadUnaligned(fromByteOffset: SYNCFRAMEOFFSET, as: Int32.self)
                }.byteSwapped
            }
        }
    }
    
    // ===================================================================================================================================================
    var playFrame:Int32 {
        get {
            self.withUnsafeBytes { ptr in
                return self.withUnsafeBytes { ptr in
                    ptr.loadUnaligned(fromByteOffset: PLAYFRAMEOFFSET, as: Int32.self)
                }.byteSwapped
            }
        }
    }
    
    
    // ===================================================================================================================================================
    var playState:Bool {
        get {
            (self.withUnsafeBytes { ptr in
                return self.withUnsafeBytes { ptr in
                    ptr.loadUnaligned(fromByteOffset: PLAYSTATOFFSET, as: Int32.self)
                }.byteSwapped
            }) != 0
        }
    }
    // ===================================================================================================================================================
    var showState:Bool {
        get {
            (self.withUnsafeBytes { ptr in
                return self.withUnsafeBytes { ptr in
                    ptr.loadUnaligned(fromByteOffset: SHOWSTATEOFFSET, as: Int32.self)
                }.byteSwapped
            }) != 0
        }
    }
    // ===================================================================================================================================================
    var nopRespond:Bool {
        get {
            (self.withUnsafeBytes { ptr in
                return self.withUnsafeBytes { ptr in
                    ptr.loadUnaligned(fromByteOffset: NOPRESPONDOFFSET, as: Int32.self)
                }.byteSwapped
            }) != 0
        }
    }
    // ===================================================================================================================================================
    var movieName:String {
        get {
            return self[MUSICNAMEOFFSET..<MUSICNAMEOFFSET+MUSICNAMESIZE].nonNullAsciiString
        }
    }
}
