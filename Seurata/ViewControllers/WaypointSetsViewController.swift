import Combine
import UIKit

class WaypointSetsViewController: UITableViewController {
    deinit {
        self.subscriptions.forEach { $0.cancel() }
    }

    @IBAction private func dismiss(segue: UIStoryboardSegue) {
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.$waypointSetNames
            // Even though self.viewModel publishes changes in the main thread,
            // We need this receive explicitly. This is because it publishes
            // changes before self.viewModel.waypointSetNames is set.
            // As we refer self.viewModel.waypointSetNames in UITablewViewDataSource
            // we need to reload the table view asynchronously so that
            // the data source methods can see an updated value.
            .receive(on: RunLoop.main)
            .sink { _ in self.tableView.reloadData() }
            .store(in: &subscriptions)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show" {
            let cell = sender as! WaypointSetsTableViewCell
            let waypointSetViewController = segue.destination as! WaypointSetViewController
            waypointSetViewController.waypointSetName = cell.waypointSetName
        }
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.waypointSetNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let waypointSetName = self.viewModel.waypointSetNames[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "waypointSet", for: indexPath) as! WaypointSetsTableViewCell
        cell.waypointSetName = waypointSetName
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let waypointSetName = self.viewModel.waypointSetNames[indexPath.row]

            self.viewModel.removeWaypointSet(waypointSetName)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    private let viewModel = WaypointSetsViewModel(waypointsManager: FileInjector.default.waypointsManager)
    private var subscriptions: [AnyCancellable] = []
}
