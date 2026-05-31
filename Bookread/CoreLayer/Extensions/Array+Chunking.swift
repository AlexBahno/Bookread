//
//  Array+Chunking.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29/05/2026.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
