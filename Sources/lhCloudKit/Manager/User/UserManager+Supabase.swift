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

extension UserManager {
    internal func isFollowRequestPending(
        supabase: SupabaseClient,
        followeeId: String
    ) async throws -> LhUserFollowerRequest? {
        let user = try await supabase.auth.session.user
        let followerId = user.id.uuidString
        let requests: [SupabaseLhUserFollowerRequest] = try await supabase
            .from("lh_user_follower_requests")
            .select()
            .eq("follower", value: followerId)
            .eq("followee", value: followeeId)
            .range(from: 0, to: 0)
            .execute()
            .value
        return requests.first?.model
    }

    internal func getAllFollowerRequests(
        supabase: SupabaseClient,
        limit: Int = 20,
        offset: Int = 0
    ) async throws -> [LhUserFollowerRequest] {
        let user = try await supabase.auth.session.user
        let followeeId = user.id.uuidString
        let requests: [SupabaseLhUserFollowerRequest] = try await supabase
            .from("lh_user_follower_requests")
            .select()
            .eq("followee", value: followeeId)
            .order("created_at", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value
        return requests.map { $0.model }
    }

    internal func createUserFollowerRequest(
        supabase: SupabaseClient,
        followeeId: String
    ) async throws -> LhUserFollowerRequest {
        let user = try await supabase.auth.session.user
        let followerId = user.id.uuidString
        let values = [
            "follower": followerId,
            "followee": followeeId,
        ]
        let request: SupabaseLhUserFollowerRequest = try await supabase
            .from("lh_user_follower_requests")
            .insert(values, returning: .representation)
            .single()
            .execute()
            .value
        return request.model
    }

    internal func deleteUserFollowerRequest(
        supabase: SupabaseClient,
        requestId: String
    ) async throws {
        _ = try await supabase
            .from("lh_user_follower_requests")
            .delete()
            .eq("id", value: requestId)
            .execute()
    }

    internal func acceptUserFollowerRequest(
        supabase: SupabaseClient,
        request: LhUserFollowerRequest
    ) async throws -> LhUserFollower {
        guard let requestId = request.recordId?.recordName else {
            throw UserManagerError.noRecordIdFoundForUser
        }
        try await deleteUserFollowerRequest(supabase: supabase, requestId: requestId)
        let values = [
            "follower": request.follower,
            "followee": request.followee,
        ]
        let follower: SupabaseLhUserFollower = try await supabase
            .from("lh_user_followers")
            .insert(values, returning: .representation)
            .single()
            .execute()
            .value
        return follower.model
    }
}
