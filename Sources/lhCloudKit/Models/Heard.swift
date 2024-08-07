//
//  Heard.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

public struct Heard {
    public let recordId: CKRecord.ID?
    public let authorRecordName: String
    public let musicItemId: String
    public let musicItemTypeId: String
    public let created: Int
    public let description: String?
    public let venueRecordName: String?
    public let location: CLLocation?

    public init(
        recordId: CKRecord.ID? = nil,
        authorRecordName: String,
        musicItemId: String,
        musicItemTypeId: String,
        created: Int,
        description: String?,
        venueRecordName: String?,
        location: CLLocation?
    ) {
        self.recordId = recordId
        self.authorRecordName = authorRecordName
        self.musicItemId = musicItemId
        self.musicItemTypeId = musicItemTypeId
        self.created = created
        self.description = description
        self.venueRecordName = venueRecordName
        self.location = location
    }
}

extension Heard: Sendable {}

extension Heard: CloudKitRecordable {
    public init?(record: CKRecord) {
        guard 
            let authorRecordName = record[HeardRecordKeys.authorRecordName.rawValue] as? String,
            let musicItemId = record[HeardRecordKeys.musicItemId.rawValue] as? String,
            let musicItemTypeId = record[HeardRecordKeys.musicItemTypeId.rawValue] as? String,
            let created = record[HeardRecordKeys.created.rawValue] as? Int
        else { return nil }

        let description = record[HeardRecordKeys.description.rawValue] as? String
        let venueRecordName = record[HeardRecordKeys.venueRecordName.rawValue] as? String
        let location = record[HeardRecordKeys.location.rawValue] as? CLLocation

        self.init(
            recordId: record.recordID,
            authorRecordName: authorRecordName,
            musicItemId: musicItemId,
            musicItemTypeId: musicItemTypeId,
            created: created,
            description: description,
            venueRecordName: venueRecordName,
            location: location
        )
    }

    public var record: CKRecord {
        let record = CKRecord(recordType: HeardRecordKeys.type.rawValue)
        record[HeardRecordKeys.authorRecordName.rawValue] = authorRecordName
        record[HeardRecordKeys.musicItemId.rawValue] = musicItemId
        record[HeardRecordKeys.musicItemTypeId.rawValue] = musicItemTypeId
        record[HeardRecordKeys.created.rawValue] = created
        record[HeardRecordKeys.description.rawValue] = description
        record[HeardRecordKeys.venueRecordName.rawValue] = venueRecordName
        record[HeardRecordKeys.location.rawValue] = location
        return record
    }
}

extension Heard {
    public static let mock: Heard = .init(
        authorRecordName: "testId",
        musicItemId: "testMusicItemId",
        musicItemTypeId: "song",
        created: 1234567890,
        description: "test description",
        venueRecordName: "testVenueRecordName",
        location: CLLocation(latitude: 0, longitude: 0)
    )
}

extension Heard {
    enum HeardRecordKeys: String {
        case type = "Heard"
        case authorRecordName
        case musicItemId
        case created
        case description
        case venueRecordName
        case location
        case musicItemTypeId
    }
}

extension Heard: Identifiable {
    public var id: String {
        authorRecordName + musicItemId + String(created)
    }
}
