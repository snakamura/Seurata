import Combine

@MainActor
class WaypointSetsViewModel {
    init(waypointsManager: WaypointsManager) {
        self.waypointsManager = waypointsManager

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

    deinit {
        self.tasks.forEach { task in
            task.cancel()
        }
    }

    @Published var waypointSetNames: [String] = []
    @Published var error: Error?

    private let waypointsManager: WaypointsManager
    private var tasks: Set<Task<Void, Never>> = Set()
}
