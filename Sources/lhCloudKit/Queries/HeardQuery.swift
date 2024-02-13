//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation

public extension Query {
    enum HeardQuery {
        case getAllHeardModels

        var query: CloudKitQuery {
            switch self {
            case .getAllHeardModels:
                return getAllHeardModels()
            }
        }

        private func getAllHeardModels() -> CloudKitQuery {
            let type = Heard.HeardRecordKeys.type.rawValue
            let sortDescriptorKey = Heard.HeardRecordKeys.created.rawValue
            let predicate = NSPredicate(value: true)
            return .init(recordType: type, sortDescriptorKey: sortDescriptorKey, predicate: predicate, database: .pubDb)
        }
    }
}
