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
        case getByUsername(String)

        var query: CloudKitQuery {
            switch self {
            case .allLhUsers:
                return queryAllLhUsers()
            case .getByUsername(let username):
                return getBy(username: username)
            }
        }

        private func queryAllLhUsers() -> CloudKitQuery {
            return .init(
                recordType: LhUser.LhUserRecordKeys.type.rawValue,
                sortDescriptorKey: LhUser.LhUserRecordKeys.username.rawValue,
                predicate: nil,
                database: .pubDb
            )
        }

        private func getBy(username: String) -> CloudKitQuery {
            return .init(
                recordType: LhUser.LhUserRecordKeys.type.rawValue,
                sortDescriptorKey: LhUser.LhUserRecordKeys.username.rawValue,
                predicate: NSPredicate(format: "username == %@", username),
                database: .pubDb
            )
        }
    }
}
