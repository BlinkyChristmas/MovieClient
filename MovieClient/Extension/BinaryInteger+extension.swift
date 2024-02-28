//Copyright © 2024 Charles Kerr. All rights reserved.

import Foundation
// Base Exension we need
extension BinaryInteger  {
    /// Obtain the data representation of the value
    public var data: Data {
        return withUnsafeBytes(of: self) { Data($0) }
    }
}
