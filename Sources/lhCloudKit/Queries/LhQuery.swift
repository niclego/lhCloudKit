//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

enum LhQuery {
    case heard(HeardQuery)
    case user(UserQuery)

    var query: CloudKitQuery {
        switch self {
        case .heard(let heardQuery):
            heardQuery.query
        case .user(let userQuery):
            userQuery.query
        }
    }
}
