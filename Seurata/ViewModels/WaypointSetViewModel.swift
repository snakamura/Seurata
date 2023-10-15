import Combine

@MainActor
class WaypointSetViewModel {
    init(waypointsManager: WaypointsManager) {
        self.waypointsManager = waypointsManager
    }

    deinit {
        self.tasks.forEach { task in
            task.cancel()
        }
    }

    var waypointSetName: String? {
        didSet {
            self.waypointSet = nil
            self.error = nil

            guard let waypointSetName = self.waypointSetName else {
                return
            }

            var taskToCancel: Task<Void, Never>?
            let task = Task { @MainActor in
                defer {
                    if let taskToCancel = taskToCancel {
                        self.tasks.remove(taskToCancel)
                    }
                }

                do {
                    self.waypointSet = try await self.waypointsManager.waypointSet(
                        by: waypointSetName
                    )
                } catch (let e) {
                    self.error = e
                }
            }
            self.tasks.insert(task)
            taskToCancel = task
        }
    }

    @Published var waypointSet: WaypointSet?
    @Published var error: Error?

    private let waypointsManager: WaypointsManager
    private var tasks: Set<Task<Void, Never>> = Set()
}
