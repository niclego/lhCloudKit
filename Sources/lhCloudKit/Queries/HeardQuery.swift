//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation
import CloudKit

public extension Query {
    enum HeardQuery {
        case getHeardActivityFeed([String])
        case getNearbyActivityFeed

        var query: CloudKitQuery {
            switch self {
            case .getHeardActivityFeed(let followingRecordNames):
                return getAllHeardModels(for: followingRecordNames)
            case .getNearbyActivityFeed:
                return getNearbyActivityFeed()
            }
        }

        private func getAllHeardModels(for followingRecordNames: [String]) -> CloudKitQuery {
            let type = Heard.HeardRecordKeys.type.rawValue
            let sortDescriptorKey = Heard.HeardRecordKeys.created.rawValue
            let predicate = NSPredicate(format: "authorRecordName IN %@", followingRecordNames)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }

        private func getNearbyActivityFeed() -> CloudKitQuery {
            let type = Heard.HeardRecordKeys.type.rawValue
            let sortDescriptorKey = Heard.HeardRecordKeys.created.rawValue
            let radius: CGFloat = 10000; // meters
            let location = CLLocation(latitude: 40.689320, longitude: -73.912060)
            let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(location, %@) < %f", location, radius)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }
    }
}
