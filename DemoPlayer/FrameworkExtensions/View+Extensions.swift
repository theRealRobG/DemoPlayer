import SwiftUI

extension View {
    @available(iOS 17, *)
    func focusableWithHighlight(_ condition: FocusState<Bool>.Binding) -> some View {
        self
            .focusable(true)
            .focused(condition)
            .padding(condition.wrappedValue ? .all : [])
            .background(Color.accentColor.opacity(condition.wrappedValue ? 0.2 : 0))
            .cornerRadius(10)
            .animation(.easeIn(duration: 0.2), value: condition.wrappedValue)
    }
}
