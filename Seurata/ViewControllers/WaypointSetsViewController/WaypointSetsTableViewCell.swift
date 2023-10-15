import UIKit

class WaypointSetsTableViewCell: UITableViewCell {
    var waypointSetName: String? {
        didSet {
            var configuration = self.defaultContentConfiguration()
            configuration.text = self.waypointSetName
            self.contentConfiguration = configuration
        }
    }

    // MARK: UITableViewCell

    override func prepareForReuse() {
        super.prepareForReuse()

        self.waypointSetName = nil
    }
}
