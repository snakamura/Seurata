import Foundation

@MainActor
protocol Injector {
    var waypointsManager: WaypointsManager { get }
}

@MainActor
class FileInjector: Injector {
    init(baseDirectory: URL) {
        self.baseDirectory = baseDirectory
        self.waypointsManager =
            FileWaypointsManager(
                directory: URL(
                    fileURLWithPath: "waypoints",
                    isDirectory:true,
                    relativeTo: self.baseDirectory
                )
            )
    }

    // MARK: Injector

    let waypointsManager: WaypointsManager

    private let baseDirectory: URL

    static let `default` = FileInjector(baseDirectory: URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true))
}
