import SwiftUI

struct MessagesView: View {
    let messages: [PlayerEventsData.Message]

    var body: some View {
        List(messages) {
            Text($0.message)
        }
    }
}

#Preview {
    MessagesView(
        messages: [
            PlayerEventsData.Message(message: "One"),
            PlayerEventsData.Message(message: "Two"),
            PlayerEventsData.Message(message: "Three"),
            PlayerEventsData.Message(message: "Four")
        ]
    )
}
