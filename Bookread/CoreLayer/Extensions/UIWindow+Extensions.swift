import SwiftUI
/// This extension adds two useful static properties to UIWindow: `current` and `screenSize`.
extension UIWindow {

    /// Retrieves the current active `UIWindow` that is the key window in the app.
    ///
    /// It checks all connected scenes and windows to find the key window (the window that receives user events).
    ///
    /// - Returns: The current active key `UIWindow` or `nil` if no active key window is found.
    static var current: UIWindow? {
        // Iterate through connected scenes and find the key window
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows where window.isKeyWindow {
                return window
            }
        }
        return nil
    }
    
    /// Retrieves the size of the current screen (bounds of the active `UIWindow`).
    ///
    /// If a key window is found, it returns its bounds. Otherwise, it defaults to the bounds of the main screen.
    ///
    /// - Returns: The bounds of the current active `UIWindow`, or `UIScreen.main.bounds` if no key window exists.
    static var screenSize: CGRect {
        // Return the bounds of the active window or fallback to the main screen
        current?.bounds ?? UIScreen.main.bounds
    }
}
