import SwiftUI

// expands a small icon-only control's tappable area to Apple's 44x44pt minimum
// without changing its visual size
extension View {
    func minimumTapTarget(_ size: CGFloat = 44) -> some View {
        self
            .frame(minWidth: size, minHeight: size)
            .contentShape(Rectangle())
    }
}
