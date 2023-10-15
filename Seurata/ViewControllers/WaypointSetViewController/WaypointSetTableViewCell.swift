import UIKit

class WaypointSetTableViewCell: UITableViewCell {
    var waypoint: Waypoint? {
        didSet {
            var configuration = self.defaultContentConfiguration()
            configuration.text = self.waypoint?.name
            configuration.secondaryText = self.waypoint?.description
            self.contentConfiguration = configuration
        }
    }

    // MARK: UITableViewCell

    override func prepareForReuse() {
        super.prepareForReuse()

        self.waypoint = nil
    }
}
