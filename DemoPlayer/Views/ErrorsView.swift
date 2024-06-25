import AVFoundation
import SwiftUI

struct ErrorsView: View {
    @ObservedObject var events: PlayerEventsData

    var body: some View {
        let errors = events.errors
        List {
            if errors.assetLoadingError != nil || errors.playerItemFatalError != nil {
                Section("Fatal Error") {
                    if let error = errors.assetLoadingError {
                        let headline = "Asset Loading Error"
                        if #available(iOS 17, *) {
                            FocusableFatalErrorView(headline: headline, error: error)
                        } else {
                            FatalErrorView(headline: headline, error: error)
                        }
                    }
                    if let error = errors.playerItemFatalError {
                        let headline = "Player Item Fatal Error"
                        if #available(iOS 17, *) {
                            FocusableFatalErrorView(headline: headline, error: error)
                        } else {
                            FatalErrorView(headline: headline, error: error)
                        }
                    }
                }
            }
            if !errors.playerItemErrorLogs.isEmpty {
                Section("Non-Fatal Error Logs") {
                    ForEach(errors.playerItemErrorLogs, id: \.hashValue) { event in
                        if #available(iOS 17, *) {
                            FocusableErrorLogEventView(errorLogEvent: event)
                        } else {
                            ErrorLogEventView(errorLogEvent: event)
                        }
                    }
                }
            }
        }
    }
}

extension ErrorsView {
    @available(iOS 17, *)
    struct FocusableFatalErrorView: View {
        let headline: String
        let error: Error
        @FocusState var isFocused: Bool

        var body: some View {
            FatalErrorView(headline: headline, error: error)
                .focusableWithHighlight($isFocused)
        }
    }

    @available(iOS 17, *)
    struct FocusableErrorLogEventView: View {
        let errorLogEvent: AVPlayerItemErrorLogEvent
        @FocusState var isFocused: Bool

        var body: some View {
            ErrorLogEventView(errorLogEvent: errorLogEvent)
                .focusableWithHighlight($isFocused)
        }
    }

    struct FatalErrorView: View {
        let headline: String
        let error: Error

        var body: some View {
            VStack(alignment: .leading) {
                Text(headline)
                    .font(.headline)
                ErrorView(error: error)
            }
        }
    }

    struct ErrorView: View {
        let error: Error

        var body: some View {
            let error = error as NSError
            VStack(alignment: .leading) {
                Text("\(error.domain): \(String(error.code))")
                    .font(.caption)
                Text(error.localizedDescription)
                    .font(.caption)
                if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? Error {
                    Text("Underlying error")
                        .font(.subheadline)
                        .bold()
                        .padding(.top)
                    ErrorView(error: underlyingError)
                }
            }
        }
    }

    struct ErrorLogEventView: View {
        let errorLogEvent: AVPlayerItemErrorLogEvent

        var body: some View {
            let event = errorLogEvent
            VStack(alignment: .leading) {
                Text("\(event.errorDomain): \(String(event.errorStatusCode))")
                    .font(.caption)
                if let comment = event.errorComment {
                    Text(comment)
                        .font(.caption)
                }
                if let sessionID = event.playbackSessionID {
                    HStack {
                        Text("Session ID")
                            .bold()
                        Text(sessionID)
                    }
                    .font(.caption)
                }
                if let date = event.date {
                    HStack {
                        Text("Date")
                            .bold()
                        Text("\(date)")
                    }
                    .font(.caption)
                }
                if let uri = event.uri {
                    HStack {
                        Text("URI")
                            .bold()
                        Text(uri)
                    }
                    .font(.caption)
                }
                if let serverAddress = event.serverAddress {
                    HStack {
                        Text("Server Address")
                            .bold()
                        Text(serverAddress)
                    }
                    .font(.caption)
                }
            }
        }
    }
}

#Preview {
    let events = PlayerEventsData()
    let errors = PlayerEventsData.Errors()
    errors.assetLoadingError = NSError(
        domain: "TestErrorDomain",
        code: -1001,
        userInfo: [
            NSLocalizedDescriptionKey: "Test top-level problem. Lorem ipsum dolor sit amet, consectetur adipiscing.",
            NSUnderlyingErrorKey: NSError(
                domain: "TestErrorSubDomain",
                code: -8001,
                userInfo: [
                    NSLocalizedDescriptionKey: "Test bottom-level error. Lorem ipsum dolor sit amet, consectetur."
                ]
            )
        ]
    )
    errors.playerItemFatalError = NSError(
        domain: "TestErrorDomain",
        code: -1001,
        userInfo: [
            NSLocalizedDescriptionKey: "Test top-level problem. Lorem ipsum dolor sit amet, consectetur adipiscing.",
            NSUnderlyingErrorKey: NSError(
                domain: "TestErrorSubDomain",
                code: -8001,
                userInfo: [
                    NSLocalizedDescriptionKey: "Test bottom-level error. Lorem ipsum dolor sit amet, consectetur."
                ]
            )
        ]
    )
    events.errors = errors
    return ErrorsView(events: events)
}
