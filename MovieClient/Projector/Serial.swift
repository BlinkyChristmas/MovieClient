//Copyright © 2024 Chales Kerr. All rights reserved.

import Foundation
import IOKit
import IOKit.serial

func serialDevices() -> [String] {
    var rvalue = [String]()
    let masterPort: mach_port_t = kIOMainPortDefault
    let classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue)

    var matchingServices: io_iterator_t = 0

    #if true
    
    var classesToMatchDict = (classesToMatch! as NSDictionary) as! Dictionary<String, AnyObject>
    classesToMatchDict[kIOSerialBSDTypeKey] = kIOSerialBSDRS232Type as AnyObject
    let classesToMatchCFDictRef = (classesToMatchDict as NSDictionary) as CFDictionary

    
    let kernResult = IOServiceGetMatchingServices(masterPort, classesToMatchCFDictRef, &matchingServices)
     
    #else
    let kernResult = IOServiceGetMatchingServices(masterPort, classesToMatch, &matchingServices)
    #endif
    if (kernResult == KERN_SUCCESS) {
        
        var modemService = IOIteratorNext(matchingServices)
        while ( modemService != 0){
            var device:String? = nil
            modemService = IOIteratorNext(matchingServices)
            let udevice = IORegistryEntryCreateCFProperty(modemService,kIOCalloutDeviceKey as CFString,kCFAllocatorDefault,0);
            if (udevice != nil) {
                device = udevice!.takeUnretainedValue() as? String
                udevice?.release()
            }
            if (device != nil) {
                device?.removeFirst(8)
                rvalue.append(device!)
            }
            
        }
    }
    return rvalue
}
