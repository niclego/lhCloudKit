//
//  Venue.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/23/24.
//

import CloudKit

public protocol Venueable {
    var name: String { get }
    var location: CLLocation { get }
    var thoroughfare: String { get }
    var locality: String { get }
    var administrativeArea: String { get }
    var countryCode: String { get }
    var category: String { get }
}

public struct Venue {
    public let recordId: CKRecord.ID?
    public let mapKitLocationId: String
    public let name: String
    public let location: CLLocation
    public let thoroughfare: String // Street
    public let locality: String // City
    public let administrativeArea: String // State
    public let countryCode: String // Country
    public let category: String

    public init(
        recordId: CKRecord.ID? = nil,
        mapKitLocationId: String,
        name: String,
        location: CLLocation,
        thoroughfare: String,
        locality: String,
        administrativeArea: String,
        countryCode: String,
        category: String
    ) {
        self.recordId = recordId
        self.mapKitLocationId = mapKitLocationId
        self.name = name
        self.location = location
        self.thoroughfare = thoroughfare
        self.locality = locality
        self.administrativeArea = administrativeArea
        self.countryCode = countryCode
        self.category = category
    }
}

extension Venue: Sendable {}

extension Venue: CloudKitRecordable {
    public init?(record: CKRecord) {
        guard
            let mapKitLocationId = record[VenueRecordKeys.mapKitLocationId.rawValue] as? String,
            let location = record[VenueRecordKeys.location.rawValue] as? CLLocation,
            let name = record[VenueRecordKeys.name.rawValue] as? String
        else { return nil }

        let thoroughfare = record[VenueRecordKeys.thoroughfare.rawValue] as? String
        let locality = record[VenueRecordKeys.locality.rawValue] as? String
        let administrativeArea = record[VenueRecordKeys.administrativeArea.rawValue] as? String
        let countryCode = record[VenueRecordKeys.countryCode.rawValue] as? String
        let category = record[VenueRecordKeys.category.rawValue] as? String

        self.init(
            recordId: record.recordID,
            mapKitLocationId: mapKitLocationId,
            name: name,
            location: location,
            thoroughfare: thoroughfare ?? "",
            locality: locality ?? "",
            administrativeArea: administrativeArea ?? "",
            countryCode: countryCode ?? "",
            category: category ?? ""
        )
    }
    
    public var record: CKRecord {
        let record = CKRecord(recordType: VenueRecordKeys.type.rawValue)
        record[VenueRecordKeys.mapKitLocationId.rawValue] = mapKitLocationId
        record[VenueRecordKeys.name.rawValue] = name
        record[VenueRecordKeys.location.rawValue] = location
        record[VenueRecordKeys.thoroughfare.rawValue] = thoroughfare
        record[VenueRecordKeys.locality.rawValue] = locality
        record[VenueRecordKeys.administrativeArea.rawValue] = administrativeArea
        record[VenueRecordKeys.countryCode.rawValue] = countryCode
        record[VenueRecordKeys.category.rawValue] = category
        return record
    }
    
    public static var mock: Venue {
        .init(
            recordId: .init(recordName: "test"),
            mapKitLocationId: "test",
            name:  "PF Changs",
            location: .init(latitude: 10, longitude: 10),
            thoroughfare: "1 Street",
            locality: "Brooklyn",
            administrativeArea: "NY",
            countryCode: "US",
            category: "Nightlife"
        )
    }
}

extension Venue {
    enum VenueRecordKeys: String {
        case type = "Venue"
        case mapKitLocationId
        case name
        case location
        case thoroughfare
        case locality
        case administrativeArea
        case countryCode
        case category
    }
}

extension Venue: Identifiable {
    public var id: String {
        name + mapKitLocationId + location.description
    }
}

extension Venue: Equatable {}

extension Venue: Venueable {}
