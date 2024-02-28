//Copyright © 2024 Charles Kerr. All rights reserved.

import Foundation
// Base Exension we need
extension Data {
    public var securityBookmark:URL? {
        var isStale = false
        return try? URL(resolvingBookmarkData: self, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
    }

    public  var nonNullAsciiString:String {
        var name =  String(data: self, encoding: .ascii)!
        // We need to strip off the nulls
        let nullstart = name.firstIndex { value in
            return (value.asciiValue ?? 0) == 0
        }
        if  nullstart != nil {
            // So there was some null characters
            name.removeSubrange(nullstart!..<name.endIndex)
        }
        return name
    }
}
