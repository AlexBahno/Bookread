import SwiftUI
import UIKit

extension UIApplication {
    /// Function to open a URL safely, compl
    /// - Parameters:
    ///   - urlString: The URL string to be validated and opened.
    ///   - completion: An optional closure that is called with a `Bool` indicating whether the URL was successfully opened.
    ///                 `true` if the URL was opened successfully, `false` otherwise.
    static func openURLSafely(_ urlString: String, completion: ((_ isSucces: Bool) -> Void)? = nil) {
        guard let url = URL(string: urlString) else {
            completion?(false)
            return
        }
        
        guard self.shared.canOpenURL(url) else {
            completion?(false)
            return
        }
        
        self.shared.open(url) { isSucces in
            completion?(isSucces)
        }
    }
    
    /// Function to open a URL safely, compl
    /// - Parameters:
    ///   - url: The `URL` to be opened. If `nil` or invalid, the operation will fail.
    ///   - completion: An optional closure that is called with a `Bool` indicating whether the URL was successfully opened.
    ///                 `true` if the URL was opened successfully, `false` otherwise.
    static func openURLSafely(_ url: URL?, completion: ((_ isSucces: Bool) -> Void)? = nil) {
        guard let url = url else {
            completion?(false)
            return
        }
        
        guard self.shared.canOpenURL(url) else {
            completion?(false)
            return
        }
        
        self.shared.open(url) { isSucces in
            completion?(isSucces)
        }
    }
}


// MARK: - Resign First Responder
extension UIApplication {
    static func resignFirstResponder() {
        UIApplication
            .shared
            .sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


// MARK: - Open Safari Extensions
extension UIApplication {
    static func openSafariExtensions() {
        guard let url = URL(string: "App-Prefs:SAFARI&path=WEB_EXTENSIONS") else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

extension UIApplication {
    // Finds the top-most view controller in your app's hierarchy
    func getTopViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
        .first?.windows
        .filter { $0.isKeyWindow }.first?.rootViewController) -> UIViewController? {
            
            if let nav = base as? UINavigationController {
                return getTopViewController(base: nav.visibleViewController)
            }
            if let tab = base as? UITabBarController {
                if let selected = tab.selectedViewController {
                    return getTopViewController(base: selected)
                }
            }
            if let presented = base?.presentedViewController {
                return getTopViewController(base: presented)
            }
            return base
        }
}
