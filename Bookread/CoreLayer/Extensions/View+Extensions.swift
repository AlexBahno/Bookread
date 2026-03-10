import SwiftUI
// MARK: - Read View Rect and Size
extension View {
    /// Reads the size of the view and provides it via a callback whenever the size changes.
    /// - Parameter onChange: Closure that receives the updated size of the view.
    /// - Returns: A modified view that tracks its size.
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    /// Reads the frame (rect) of the view in the specified coordinate space and provides it via a callback whenever the frame changes.
    /// - Parameters:
    ///   - space: The coordinate space in which to measure the frame (`.global`, `.local`, or a custom coordinate space).
    ///   - onChange: Closure that receives the updated frame of the view.
    /// - Returns: A modified view that tracks its frame.
    func readRect(in space: CoordinateSpace, onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: RectPreferenceKey.self, value: geometryProxy.frame(in: space))
            }
        )
        .onPreferenceChange(RectPreferenceKey.self, perform: onChange)
    }
}

// PreferenceKey for tracking size changes
private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

// PreferenceKey for tracking frame (rect) changes
private struct RectPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}


// MARK: - Cutom placeholder
extension View {
    /// Cutom placeholder for TextField and TextEditor
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        vPadding: CGFloat = 0,
        hPadding: CGFloat = 0,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
                .padding(.vertical, vPadding)
                .padding(.horizontal, hPadding)
            self
                .scrollContentBackground(.hidden)
        }
    }
}


// MARK: - Conditionally Transform
extension View {
    /// Conditionally transform the view
    @ViewBuilder
    func conditionally<Transform: View>(_ condition: Bool, apply transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    @ViewBuilder func measure(
        in coordinateSpace: CoordinateSpace = .global,
        _ block: @escaping (CGRect) -> Void
    ) -> some View {
        MeasuredView(
            coordinateSpace: coordinateSpace,
            onMeasure: block,
            content: self
        )
    }
}

struct MeasuredView<Content: View>: View {
    let coordinateSpace: CoordinateSpace
    let onMeasure: (CGRect) -> Void
    let content: Content
    
    var body: some View {
        content
            .overlay {
                GeometryReader { proxy in
                    Rectangle().fill(.clear)
                        .onAppear {
                            let rect = proxy.frame(in: coordinateSpace)
                            onMeasure(rect)
                        }
                        .onChange(of: proxy.frame(in: coordinateSpace)) { _ in
                            let rect = proxy.frame(in: coordinateSpace)
                            onMeasure(rect)
                        }
                }
            }
    }
}

extension View {
    func hideKeyboardOnTap() -> some View {
        modifier(ClosableKeyboard())
    }
}

struct ClosableKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                Color.black.opacity(0.001)
                    .onTapGesture {
                        withAnimation {
                            closeKeyboard()
                        }
                    }
            }
    }
}

func closeKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

extension View {
    func hapticOnTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred()
            }
        )
    }
}

extension View {
    func ignoreKeyboard() -> some View {
        ScrollView([]) {
            self
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

extension View {
    func shake(_ animatableData: CGFloat) -> some View {
        self
            .modifier(ShakeEffect(animatableData: animatableData))
    }
}
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = sin(animatableData * .pi * 6) * 10
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}


extension View {
    func roundedBorder(
        cornerRadius: CGFloat,
        borderColor: Color,
        lineWidth: CGFloat = 1
    ) -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: lineWidth)
            }
    }
}
