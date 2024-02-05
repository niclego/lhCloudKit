//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import Foundation

protocol CloudKitable {
    init(containerId: String)
    func query<T: CloudKitRecordable>(_ query: LhQuery) async throws -> [T]
    func save<T: CloudKitRecordable>(model: T, db: LhDatabase) async throws -> T
    func fetchUserRecordIdString() async throws -> String
}

struct CloudKitQuery {
    let recordType: String
    let sortDescriptorKey: String?
    let predicate: NSPredicate?
    let database: LhDatabase
}
