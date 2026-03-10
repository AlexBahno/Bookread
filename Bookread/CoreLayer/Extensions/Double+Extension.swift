//
//  Double+Extension.swift
//

import Foundation
import SwiftUI

extension Double {
    
    func flexible(_ scale: Double = 1.5) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        if UIDevice.isIphone {
            if screenHeight > 800 {
                return CGFloat(self) * (screenHeight / 852)
            } else {
                return CGFloat(self) * (screenHeight / 736)
            }
        } else {
            let isPro = UIScreen.screenWidth / UIScreen.screenHeight > 0.72
            if isPro {
                return CGFloat(self) * scale * (screenHeight / 1194)
            } else {
                return CGFloat(self) * scale * (screenHeight / 1280)
            }
        }
    }
    
    func toString(withDecimals decimals: Int = 2) -> String {
        String(format: "%.\(decimals)f", self)
    }
}
