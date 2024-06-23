import SwiftUI

@MainActor
class PlayerEventsData: ObservableObject {
    @Published var messages = [Message]()
    @Published var variants = [PlayerItemEventsListener.AssetVariantInfo]()
    @Published var errors = Errors()

    func append(message: String) {
        messages.append(Message(message: message))
    }
}

extension PlayerEventsData {
    // Using an `Identifiable` struct for messages helps with using the strings in lists. The idea was taken from this
    // Stack Overflow answer:
    // > https://stackoverflow.com/a/67977144/7039100
    struct Message: Identifiable {
        let id: UUID
        let message: String

        init(message: String) {
            self.id = UUID()
            self.message = message
        }
    }

    class Errors {
        @Published var assetLoadingError: Error?
        @Published var playerItemFatalError: Error?
    }
}
