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

        var query: CloudKitQuery {
            switch self {
            case .getHeardActivityFeed(let followingRecordNames):
                return getAllHeardModels(for: followingRecordNames)
            }
        }

        private func getAllHeardModels(for followingRecordNames: [String]) -> CloudKitQuery {
            let type = Heard.HeardRecordKeys.type.rawValue
            let sortDescriptorKey = Heard.HeardRecordKeys.created.rawValue
            let predicate = NSPredicate(format: "authorRecordName IN %@", followingRecordNames)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }
    }
}
