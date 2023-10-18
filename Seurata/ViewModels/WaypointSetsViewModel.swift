import Combine

@MainActor
class WaypointSetsViewModel: WaypointsManagerDelegate {
    init(waypointsManager: WaypointsManager) {
        self.waypointsManager = waypointsManager
        self.waypointsManager.delegate = self

        self.reloadWaypointSets()
    }

    deinit {
        self.tasks.forEach { task in
            task.cancel()
        }
    }

    @Published var waypointSetNames: [String] = []
    @Published var error: Error?

    func removeWaypointSet(_ waypointSetName: String) {
        Task { @MainActor in
            do {
                try await self.waypointsManager.removeWaypointSet(waypointSetName)
            } catch (let e) {
                self.error = e
            }
        }

        // Since removing a waypoint set from WaypointsManager is asynchronous
        // we need to update waypointSetNames directly in synchronous way
        // so that UI can see the updated list.
        self.waypointSetNames.removeAll { $0 == waypointSetName }
    }

    private func reloadWaypointSets() {
        var taskToCancel: Task<Void, Never>?
        let task = Task { @MainActor in
            defer {
                if let taskToCancel = taskToCancel {
                    self.tasks.remove(taskToCancel)
                }
            }

            do {
                self.waypointSetNames = try await self.waypointsManager.listWaypointSetNames()
            } catch (let e) {
                self.error = e
            }
        }
        self.tasks.insert(task)
        taskToCancel = task
    }

    // MARK: WaypointsManagerDelegate

    func waypointsManager(
        _ waypointsManager: WaypointsManager,
        didAddWaypointSet name: String
    ) {
        // We reload all waypoint sets here instead of inserting this waypoint
        // set to waypointSetNames. This is because it's hard to guarantee that
        // waypointSetNames is updated after you've inserted this waypoint set.
        //
        // For example, imagine that you've called reloadWaypointSets() somewhere.
        // This delegate method was called before the async call of
        // WaypointsManager.listWaypointSetNames() returns waypoint sets.
        // There is no guarantee that WaypointsManager.listWaypointSetNames()
        // returns a list containing this waypoint set because it was called
        // before this delegate method is called.
        //
        // If we inserted this waypoint set into waypointSetNames here,
        // it can be lost when this happens.
        self.reloadWaypointSets()
    }

    func waypointsManager(
        _ waypointsManager: WaypointsManager,
        didRemoveWaypointSet name: String
    ) {
        // We ignore the case where there is no waypoint set name with this name
        // in waypointSetNames. This can happen when you remove a waypoint set
        // by removeWaypointSet(_:) because it removes the waypoint set name
        // directly.
        self.waypointSetNames.removeAll { $0 == name }
    }

    private let waypointsManager: WaypointsManager
    private var tasks: Set<Task<Void, Never>> = Set()
}
