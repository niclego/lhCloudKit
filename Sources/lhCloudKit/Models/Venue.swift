//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/23/24.
//

import CloudKit

public struct Venue {
    public let recordId: CKRecord.ID?
    public let mapKitLocationId: String
    public let name: String
    public let location: CLLocation

    public init(
        recordId: CKRecord.ID? = nil,
        mapKitLocationId: String,
        name: String,
        location: CLLocation
    ) {
        self.recordId = recordId
        self.mapKitLocationId = mapKitLocationId
        self.name = name
        self.location = location
    }
}

extension Venue: CloudKitRecordable {
    public init?(record: CKRecord) {
        guard
            let mapKitLocationId = record[VenueRecordKeys.mapKitLocationId.rawValue] as? String,
            let location = record[VenueRecordKeys.location.rawValue] as? CLLocation,
            let name = record[VenueRecordKeys.name.rawValue] as? String
        else { return nil }

        self.init(
            recordId: record.recordID,
            mapKitLocationId: mapKitLocationId,
            name: name,
            location: location
        )
    }
    
    public var record: CKRecord {
        let record = CKRecord(recordType: VenueRecordKeys.type.rawValue)
        record[VenueRecordKeys.mapKitLocationId.rawValue] = mapKitLocationId
        record[VenueRecordKeys.name.rawValue] = name
        record[VenueRecordKeys.location.rawValue] = location
        return record
    }
    
    public static var mock: Venue {
        .init(mapKitLocationId: "test", name: "PF Changs", location: .init(latitude: 10, longitude: 10))
    }
}

extension Venue {
    enum VenueRecordKeys: String {
        case type = "Venue"
        case mapKitLocationId
        case name
        case location
    }
}
