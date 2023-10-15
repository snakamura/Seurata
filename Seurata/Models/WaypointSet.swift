struct WaypointSet: Encodable, Decodable {
    let name: String
    let waypoints: [Waypoint]
}
