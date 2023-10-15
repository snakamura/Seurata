import Foundation

protocol WaypointsManager {
    func listWaypointSetNames() async throws -> [String]
    func waypointSet(by name: String) async throws -> WaypointSet
}

class FileWaypointsManager: WaypointsManager {
    init(directory: URL) {
        precondition(directory.hasDirectoryPath)

        self.directory = directory
    }

    // MARK: WaypointsManager

    func listWaypointSetNames() async throws -> [String] {
        return try await Task {
            return try FileManager.default.contentsOfDirectory(
                at: self.directory,
                includingPropertiesForKeys: nil
            ).map { ($0.lastPathComponent as NSString).deletingPathExtension }
        }.value
    }

    func waypointSet(by name: String) async throws -> WaypointSet {
        let path = URL(string: "\(name).json", relativeTo: self.directory)!
        return try await Task {
            let data = try Data(contentsOf: path)
            return try JSONDecoder().decode(WaypointSet.self, from: data)
        }.value
    }

    private let directory: URL
}
