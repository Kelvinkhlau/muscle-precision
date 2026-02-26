import SwiftUI

@main
struct MusclePrecisionApp: App {
    @StateObject private var store = LibraryStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
        }
    }
}
