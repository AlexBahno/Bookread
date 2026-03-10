//
//  Color+Extensions.swift
//  Stacklet-Time-Guard
//
//  Created by Andrei Secrieru on 17.12.2024.
//

import Foundation
import SwiftUI

extension Color {
    // Convert Color to Hex String
    func toHex() -> String {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components, components.count >= 3 else { return "#FFFFFF" }
        
        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)
        
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
    
    // Convert Hex String to Color
    static func fromHex(_ hex: String) -> Color {
        var cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanedHex = cleanedHex.replacingOccurrences(of: "#", with: "")
        
        if cleanedHex.count == 6 {
            let scanner = Scanner(string: cleanedHex)
            var rgbValue: UInt64 = 0
            scanner.scanHexInt64(&rgbValue)
            
            let red = Double((rgbValue >> 16) & 0xFF) / 255.0
            let green = Double((rgbValue >> 8) & 0xFF) / 255.0
            let blue = Double(rgbValue & 0xFF) / 255.0
            
            return Color(red: red, green: green, blue: blue)
        }
        return .white
    }
    
    /// Initializes a `Color` from a hexadecimal string with an optional opacity value.
    ///
    /// - Parameters:
    ///   - hex: A string representing the color in hexadecimal format. This can either include
    ///     or omit a leading "#" (e.g., `"#FF5733"` or `"FF5733"`). The string must be a valid
    ///     6-character hexadecimal code representing RGB.
    ///   - opacity: An optional value for the color's opacity, ranging from `0.0` (completely
    ///     transparent) to `1.0` (fully opaque). Defaults to `1.0`.
    /// - Example:
    ///   ```swift
    ///   Color(hex: "#FF5733", opacity: 0.8) // Creates a color with 80% opacity
    ///   ```
    init(hex: String, opacity: Double = 1.0) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        
        // Scan the hex code into a 64-bit unsigned integer
        Scanner(string: cleanHexCode).scanHexInt64(&rgb)
        
        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0
        
        // Initialize the Color with the extracted RGB values
        self.init(red: redValue, green: greenValue, blue: blueValue, opacity: opacity)
    }
    
    /// Creates a `Color` from a hexadecimal string with an optional opacity value.
    ///
    /// - Parameters:
    ///   - hex: A string representing the color in hexadecimal format. The format requirements
    ///     are the same as in `init(hex:)`.
    ///   - opacity: An optional value for the color's opacity, ranging from `0.0` (completely
    ///     transparent) to `1.0` (fully opaque). Defaults to `1.0`.
    /// - Returns: A `Color` object corresponding to the given hex code and opacity.
    /// - Example:
    ///   ```swift
    ///   Color.hex("#FF5733", opacity: 0.5) // Returns a color with 50% opacity
    ///   ```
    static func hex(_ hex: String, opacity: Double = 1.0) -> Color {
        Color(hex: hex, opacity: opacity)
    }
    
    /// Creates a `Color` from RGB values with an optional alpha (opacity) value.
    ///
    /// - Parameters:
    ///   - r: The red component of the color, between `0` and `255`.
    ///   - g: The green component of the color, between `0` and `255`.
    ///   - b: The blue component of the color, between `0` and `255`.
    ///   - a: An optional alpha (opacity) value for the color, between `0.0` (completely
    ///     transparent) and `1.0` (fully opaque). Defaults to `1.0`.
    /// - Returns: A `Color` object with the specified RGB and alpha values.
    /// - Example:
    ///   ```swift
    ///   Color.fromRGBA(255, 87, 51, 0.8) // Creates a color with 80% opacity
    ///   ```
    static func fromRGBA(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) -> Color {
        Color(red: red/255, green: green/255, blue: blue/255, opacity: alpha)
    }
}
