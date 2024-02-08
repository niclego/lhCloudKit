//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation

public extension Query {
    enum UserQuery {
        case allLhUsers

        var query: CloudKitQuery {
            switch self {
            case .allLhUsers:
                return queryAllLhUsers()
            }
        }

        private func queryAllLhUsers() -> CloudKitQuery {
            return .init(recordType: LhUser.LhUserRecordKeys.type.rawValue, sortDescriptorKey: nil, predicate: nil, database: .pubDb)
        }
    }
}
