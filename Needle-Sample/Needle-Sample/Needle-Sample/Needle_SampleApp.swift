import SwiftUI
import DI

@main
struct Needle_SampleApp: App {
    private let composition = AppComposition()

    var body: some Scene {
        WindowGroup {
            composition.makeUserView()
        }
    }
}
