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
        didAdd waypointSet: WaypointSet
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

    private let waypointsManager: WaypointsManager
    private var tasks: Set<Task<Void, Never>> = Set()
}
