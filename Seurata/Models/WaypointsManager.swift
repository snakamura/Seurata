import Foundation

@MainActor
protocol WaypointsManager: AnyObject {
    var delegate: WaypointsManagerDelegate? { get set }

    func listWaypointSetNames() async throws -> [String]
    func waypointSet(by name: String) async throws -> WaypointSet
    func addWaypointSet(_ waypointSet: WaypointSet) async throws
}

@MainActor
protocol WaypointsManagerDelegate: AnyObject {
    func waypointsManager(
        _ waypointsManager: WaypointsManager,
        didAdd waypointSet: WaypointSet
    )
}

@MainActor
class FileWaypointsManager: WaypointsManager {
    init(directory: URL) {
        precondition(directory.hasDirectoryPath)

        self.directory = directory
    }

    weak var delegate: WaypointsManagerDelegate?

    // MARK: WaypointsManager

    func listWaypointSetNames() async throws -> [String] {
        return try await Task {
            return try FileManager.default.contentsOfDirectory(
                at: self.directory,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ).map {
                ($0.lastPathComponent as NSString).deletingPathExtension
            }.sorted()
        }.value
    }

    func waypointSet(by name: String) async throws -> WaypointSet {
        let path = self.path(for: name)
        return try await Task {
            let data = try Data(contentsOf: path)
            return try JSONDecoder().decode(WaypointSet.self, from: data)
        }.value
    }

    func addWaypointSet(_ waypointSet: WaypointSet) async throws {
        let path = self.path(for: waypointSet.name)
        try await Task {
            let data = try JSONEncoder().encode(waypointSet)
            try data.write(to: path, options: [.withoutOverwriting])
        }.value

        self.delegate?.waypointsManager(self, didAdd: waypointSet)
    }

    private func path(for waypointSetName: String) -> URL {
        return URL(string: "\(waypointSetName).json", relativeTo: self.directory)!
    }

    private let directory: URL
}
