//
//  UserManager+Supabase.swift
//  lhCloudKit
//
//  Created by Nicolas Le Gorrec on 7/7/25.
//

import Supabase

extension UserManager {
    internal func getSupabaseUser(supabase: SupabaseClient) async throws -> SupabaseLhUser {
        let user = try await supabase.auth.session.user

        let userID = user.id.uuidString

        return try await supabase
            .from("lh_users")
            .select()
            .eq("id", value: userID)
            .single()
            .execute()
            .value
    }
}
