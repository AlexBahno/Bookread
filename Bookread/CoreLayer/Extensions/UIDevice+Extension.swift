//
//  UIDevice+Extension.swift
//

import Foundation
import UIKit

extension UIDevice {
    
    static let isIphone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    static let isSmallIphone: Bool = UIScreen.main.bounds.size.height <= 680
}
