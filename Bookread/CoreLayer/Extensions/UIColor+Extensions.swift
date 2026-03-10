import UIKit
// MARK: - Hex Init
extension UIColor {
    /// Initializes a `UIColor` object with integer values for red, green, and blue components.
    /// - Parameters:
    ///   - red: The red component of the color, must be between 0 and 255.
    ///   - green: The green component of the color, must be between 0 and 255.
    ///   - blue: The blue component of the color, must be between 0 and 255.
    ///
    /// The values for the RGB components should be between 0 and 255, and are normalized to a range of 0 to 1 internally.
    /// The alpha value is set to 1.0 (fully opaque) by default.
    ///
    /// Example usage:
    /// ```swift
    /// let color = UIColor(red: 255, green: 100, blue: 50)
    /// ```
    convenience init(red: Int, green: Int, blue: Int) {
        // Ensure the color values are within the correct range
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        // Initialize UIColor using normalized RGB values (0 to 1)
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1.0
        )
    }

    /// Initializes a `UIColor` object with a hexadecimal color value.
    /// - Parameters:
    ///   - hex: The hexadecimal representation of the color. For example, `0xFF5733`.
    ///   - alpha: The alpha component of the color, with a default value of 1.0 (fully opaque).
    ///
    /// The hex value should be in the format `0xRRGGBB`, where RR, GG, and BB are the red, green, and blue components, respectively.
    ///
    /// Example usage:
    /// ```swift
    /// let color = UIColor(hex: 0x3498DB) // Initializes color with hex value and full opacity
    /// let semiTransparentColor = UIColor(hex: 0x3498DB, alpha: 0.5) // With 50% opacity
    /// ```
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        // Extract the red, green, and blue components from the hex value
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0

        // Initialize UIColor using the RGB components and the provided alpha value
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
