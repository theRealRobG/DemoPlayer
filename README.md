# DemoPlayer
This app is just a basic app to demonstrate various functionalities of AVPlayer in a SwiftUI context.

All the SwiftUI views are included in the [Views](DemoPlayer/Views) folder.

The player integration code, including the view model used to update the views found in [Views](DemoPlayer/Views), and
the view representation, are included in the [Player](DemoPlayer/Player) folder. *As an aside, it probably makes more
sense to split the `PlayerViewControllerRepresentation` from the `Coordinator` and move the representation to the Views
folder, leaving the `Coordinator` in the Player folder.*

Some extensions on Apple frameworks (e.g. `String`, `View`) are found in the
[FrameworkExtensions](DemoPlayer/FrameworkExtensions) folder.
