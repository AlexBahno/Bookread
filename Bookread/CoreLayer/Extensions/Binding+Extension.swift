//
//  Binding+Extension.swift
//  PennyPilot
//
//  Created by Cocadei Ludmila on 02.05.2025.
//

import SwiftUI

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(limit))
            }
        }
        
        return self
    }
}
