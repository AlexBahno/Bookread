import SwiftUI

extension View {
    func interRegular(size: Double) -> some View {
        self
            .font(.custom("Inter", size: size))
    }
    func manropeRegular(size: Double) -> some View {
        self
            .font(.custom("Manrope", size: size))
    }
    func dmSansRegular(size: Double) -> some View {
        self
            .font(.custom("DMSans", size: size))
    }
}
