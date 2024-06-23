import AVFoundation
import SwiftUI

struct ErrorsView: View {
    let errors: PlayerEventsData.Errors

    var body: some View {
        List {
            if errors.assetLoadingError != nil || errors.playerItemFatalError != nil {
                Section("Fatal Error") {
                    if let error = errors.assetLoadingError {
                        VStack(alignment: .leading) {
                            Text("Asset Loading Error")
                                .font(.headline)
                            ErrorView(error: error)
                        }
                    }
                    if let error = errors.playerItemFatalError {
                        VStack(alignment: .leading) {
                            Text("Player Item Fatal Error")
                                .font(.headline)
                            ErrorView(error: error)
                        }
                    }
                }
            }
        }
    }
}

extension ErrorsView {
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
}

#Preview {
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
    return ErrorsView(errors: errors)
}
