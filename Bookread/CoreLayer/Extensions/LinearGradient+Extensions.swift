import SwiftUI

extension LinearGradient {
    /// Converts a hexadecimal color string to a `Color`.
    /// - Parameter hex: A string representing a hexadecimal color code, optionally prefixed with `#`.
    /// - Returns: A `Color` instance representing the specified hexadecimal color.
    static private func hexColor(_ hex: String) -> Color {
        // Remove whitespace and `#` prefix if present.
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        
        // Parse the hex string into an RGB value.
        var rgb: UInt64 = 0
        Scanner(string: cleanHexCode).scanHexInt64(&rgb)
        
        // Extract red, green, and blue components and normalize to [0, 1] range.
        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0
        return Color(red: redValue, green: greenValue, blue: blueValue)
    }
    
    /// Creates a `LinearGradient` with specified colors and direction.
    /// - Parameters:
    ///   - colors: An array of `Color` instances defining the gradient.
    ///   - startPoint: The starting point of the gradient.
    ///   - endPoint: The ending point of the gradient.
    /// - Returns: A `LinearGradient` instance with the specified parameters.
    static private func make(colors: [Color], _ startPoint: UnitPoint, _ endPoint: UnitPoint) -> LinearGradient {
        LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
    
    /// Creates a customizable `LinearGradient` with `Color` instances.
    /// - Parameters:
    ///   - colors: An array of `Color` instances defining the gradient.
    ///   - startPoint: The starting point of the gradient. Default is `.top`.
    ///   - endPoint: The ending point of the gradient. Default is `.bottom`.
    /// - Returns: A `LinearGradient` instance with the specified parameters.
    static func custom(
        colors: [Color],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> LinearGradient {
        let colors = colors.map({ $0 })
        return make(colors: colors, startPoint, endPoint)
    }
    
    /// Creates a customizable `LinearGradient` with hexadecimal color codes.
    /// - Parameters:
    ///   - colors: An array of hexadecimal color strings defining the gradient.
    ///   - startPoint: The starting point of the gradient. Default is `.top`.
    ///   - endPoint: The ending point of the gradient. Default is `.bottom`.
    /// - Returns: A `LinearGradient` instance with the specified parameters.
    static func custom(
        hex colors: [String],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> LinearGradient {
        let colors = colors.map({ LinearGradient.hexColor($0) })
        return make(colors: colors, startPoint, endPoint)
    }
}

extension LinearGradient {
    static var appSecondaryGradient: Self {
        .init(
            gradient: Gradient(colors: [Color(hex: "#73A032"), Color(hex: "#C8ED79")]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
