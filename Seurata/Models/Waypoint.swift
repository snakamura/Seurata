struct Waypoint: Encodable, Decodable {
    let name: String
    let latitude: Float
    let longitude: Float
    let altitude: Float
    let description: String?
}
