import Foundation

class WPTParser {
    func parse(_ data: Data) throws -> [Waypoint] {
        guard let string = String(data: data, encoding: .utf8) else {
            throw WPTParserError.encoding
        }

        let lines = string.split(separator: "\r\n")
        guard let header = lines.first else {
            throw WPTParserError.empty
        }
        if header != "$FormatGEO" {
            throw WPTParserError.header
        }

        return try lines.dropFirst().map { try self.parse(line: $0) }
    }

    private func parse<S: StringProtocol>(line: S) throws -> Waypoint {
        let regex = /^(?<name>\w+)\s+(?<northSouth>[NS])\s(?<latitudeDegrees>\d{2})\s(?<latitudeMinutes>\d{2})\s(?<latitudeSeconds>\d{2}\.\d{2})\s+(?<eastWest>[EW])\s(?<longitudeDegrees>\d{3})\s(?<longitudeMinutes>\d{2})\s(?<longitudeSeconds>\d{2}\.\d{2})\s+(?<altitude>\d+)\s+(?<description>.*)$/
        guard let match = String(line).wholeMatch(of: regex) else {
            throw WPTParserError.line(String(line))
        }
        let latitude = (match.northSouth == "N" ? 1 : -1) * (Float(String(match.latitudeDegrees))! + Float(String(match.latitudeMinutes))! / 60 + Float(String(match.latitudeSeconds))! / 60 / 60)
        let longitude = (match.eastWest == "E" ? 1 : -1) * (Float(String(match.longitudeDegrees))! + Float(String(match.longitudeMinutes))! / 60 + Float(String(match.longitudeSeconds))! / 60 / 60)
        return Waypoint(
            name: String(match.name),
            latitude: latitude,
            longitude: longitude,
            altitude: Float(String(match.altitude))!,
            description: String(match.description)
        )
    }
}

enum WPTParserError: Error {
    case encoding
    case empty
    case header
    case line(String)
    case unknown
}
