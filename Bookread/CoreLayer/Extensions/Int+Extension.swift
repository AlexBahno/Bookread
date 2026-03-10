//
//  Int+Extension.swift
//

import Foundation
import SwiftUI

extension Int {
    
    func flexible(_ scale: Double = 1.5) -> CGFloat {
        Double(self).flexible(scale)
    }
    
    func toString() -> String {
        String(format: "%d", self)
    }
}
