import CoreLocation
import MapKit
import UIKit

class WaypointViewController: UIViewController, MKMapViewDelegate {
    var waypoint: Waypoint?

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.waypoint?.name

        if let waypoint = self.waypoint {
            let coordinate = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(waypoint.latitude),
                longitude: CLLocationDegrees(waypoint.longitude)
            )

            let annotation = MKPointAnnotation()
            annotation.title = waypoint.name
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)

            self.mapView.centerCoordinate = coordinate
            self.mapView.region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 10 * 1000,
                longitudinalMeters: 10 * 1000
            )
        }
    }

    @IBOutlet private var mapView: MKMapView!
}
