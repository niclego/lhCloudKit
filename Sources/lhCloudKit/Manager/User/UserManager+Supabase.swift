//
//  UserManager+Supabase.swift
//  lhCloudKit
//
//  Created by Nicolas Le Gorrec on 7/7/25.
//

import Supabase
import Foundation

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
        followeeId: UUID
    ) async throws -> SupabaseLhUserFollowerRequest? {
        let user = try await supabase.auth.session.user
        let followerId = user.id
        let requests: [SupabaseLhUserFollowerRequest] = try await supabase
            .from("lh_user_follower_requests")
            .select()
            .eq("follower", value: followerId)
            .eq("followee", value: followeeId)
            .range(from: 0, to: 0)
            .execute()
            .value
        return requests.first
    }

    internal func getAllFollowerRequests(
        supabase: SupabaseClient,
        limit: Int = 20,
        offset: Int = 0
    ) async throws -> [SupabaseLhUserFollowerRequest] {
        let user = try await supabase.auth.session.user
        let followeeId = user.id
        let requests: [SupabaseLhUserFollowerRequest] = try await supabase
            .from("lh_user_follower_requests")
            .select()
            .eq("followee", value: followeeId)
            .order("created_at", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value
        return requests.map { $0 }
    }

    internal func createUserFollowerRequest(
        supabase: SupabaseClient,
        followeeId: UUID
    ) async throws -> SupabaseLhUserFollowerRequest {
        let user = try await supabase.auth.session.user
        let followerId = user.id
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
        return request
    }

    internal func deleteUserFollowerRequest(
        supabase: SupabaseClient,
        requestId: UUID
    ) async throws {
        _ = try await supabase
            .from("lh_user_follower_requests")
            .delete()
            .eq("id", value: requestId)
            .execute()
    }

    internal func acceptUserFollowerRequest(
        supabase: SupabaseClient,
        request: SupabaseLhUserFollowerRequest
    ) async throws -> SupabaseLhUserFollower {
        try await deleteUserFollowerRequest(supabase: supabase, requestId: request.id)
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
        return follower
    }
}
