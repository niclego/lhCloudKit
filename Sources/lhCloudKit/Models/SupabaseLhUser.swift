//
//  SupabaseLhUser.swift
//  lhCloudKit
//
//  Created by Nicolas Le Gorrec on 7/7/25.
//

struct SupabaseLhUser: Decodable {
    let id: String
    let username: String
    let profileImageURL: String?
    let accountType: String?
    let isPublicAccount: Bool?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case profileImageURL = "profile_image_url"
        case accountType = "account_type"
        case isPublicAccount = "is_public_account"
        case createdAt = "created_at"
    }
}

