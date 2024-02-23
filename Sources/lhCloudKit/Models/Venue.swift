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

    public init(
        recordId: CKRecord.ID? = nil,
        mapKitLocationId: String,
        name: String
    ) {
        self.recordId = recordId
        self.mapKitLocationId = mapKitLocationId
        self.name = name
    }
}

extension Venue: CloudKitRecordable {
    public init?(record: CKRecord) {
        guard
            let mapKitLocationId = record[VenueRecordKeys.mapKitLocationId.rawValue] as? String,
            let name = record[VenueRecordKeys.name.rawValue] as? String
        else { return nil }

        self.init(
            recordId: record.recordID,
            mapKitLocationId: mapKitLocationId,
            name: name
        )
    }
    
    public var record: CKRecord {
        let record = CKRecord(recordType: VenueRecordKeys.type.rawValue)
        record[VenueRecordKeys.mapKitLocationId.rawValue] = mapKitLocationId
        record[VenueRecordKeys.name.rawValue] = name
        return record
    }
    
    public static var mock: Venue {
        .init(mapKitLocationId: "test", name: "PF Changs")
    }
    
    
}

extension Venue {
    enum VenueRecordKeys: String {
        case type = "Venue"
        case mapKitLocationId
        case name
    }
}
