//
//  String+Extensions.swift

import Foundation

extension String {
    
    /// This method allows to search in a string if it constains another string ( helps for searching )
    func containsCharactersInOrder(of searchString: String) -> Bool {
        let lowercasedSelf = self.lowercased()
        let lowercasedSearch = searchString.lowercased()
        
        guard !lowercasedSearch.isEmpty else { return true }
        
        var searchIndex = lowercasedSearch.startIndex
        
        for char in lowercasedSelf where char == lowercasedSearch[searchIndex] {
            searchIndex = lowercasedSearch.index(after: searchIndex)
            
            if searchIndex == lowercasedSearch.endIndex {
                return true
            }
        }
        
        return false
    }
}

extension String {
    func trimIsEmpty() -> Bool {
        self.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func trim() -> String {
        self.trimmingCharacters(in: .whitespaces)
    }
    
    var isNumeric: Bool {
        !isEmpty && allSatisfy { $0.isNumber }
    }
}
