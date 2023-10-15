import Combine
import UIKit

class WaypointSetViewController: UITableViewController {
    var waypointSetName: String?

    deinit {
        self.subscriptions.forEach { $0.cancel() }
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.$waypointSet
            .receive(on: RunLoop.main)
            .sink { _ in self.tableView.reloadData() }
            .store(in: &subscriptions)
        self.viewModel.waypointSetName = self.waypointSetName
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.waypointSet?.waypoints.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let waypoints = viewModel.waypointSet?.waypoints else {
            preconditionFailure()
        }

        let waypoint = waypoints[indexPath.row]

        let cell = self.tableView.dequeueReusableCell(withIdentifier: "waypoint") as! WaypointSetTableViewCell
        cell.waypoint = waypoint
        return cell
    }


    private let viewModel = WaypointSetViewModel(waypointsManager: FileInjector.default.waypointsManager)
    private var subscriptions: [AnyCancellable] = []
}
