//
//  File.swift
//  
//
//  Created by Nicolas Le Gorrec on 2/4/24.
//

import CloudKit

public protocol CloudKitRecordable {
    init?(record: CKRecord)
    var record: CKRecord { get }
    static var mock: Self { get }
}
