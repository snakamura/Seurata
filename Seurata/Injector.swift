import Foundation

protocol Injector {
    var waypointsManager: WaypointsManager { get }
}

class FileInjector: Injector {
    init(baseDirectory: URL) {
        self.baseDirectory = baseDirectory
    }

    // MARK: Injector

    var waypointsManager: WaypointsManager {
        return FileWaypointsManager(
            directory: URL(
                fileURLWithPath: "waypoints",
                isDirectory:true,
                relativeTo: self.baseDirectory
            )
        )
    }

    private let baseDirectory: URL

    static let `default` = FileInjector(baseDirectory: URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true))
}
