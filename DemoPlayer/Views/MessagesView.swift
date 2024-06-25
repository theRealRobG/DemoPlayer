import SwiftUI

struct MessagesView: View {
    @ObservedObject var events: PlayerEventsData

    var body: some View {
        List(events.messages) {
            if #available(iOS 17, *) {
                FocusableText($0.message)
            } else {
                Text($0.message)
            }
        }
    }
}

extension MessagesView {
    @available(iOS 17, *)
    struct FocusableText<S: StringProtocol>: View {
        let message: S
        @FocusState var isFocused: Bool

        init(_ message: S) {
            self.message = message
        }

        var body: some View {
            Text(message)
                .focusableWithHighlight($isFocused)
        }
    }
}

#Preview {
    let events = PlayerEventsData()
    events.messages = [
        PlayerEventsData.Message(message: "One"),
        PlayerEventsData.Message(message: "Two"),
        PlayerEventsData.Message(message: "Three"),
        PlayerEventsData.Message(message: "Four")
    ]
    return MessagesView(events: events)
}
