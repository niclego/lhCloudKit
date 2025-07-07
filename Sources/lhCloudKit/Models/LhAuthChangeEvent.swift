//
//  LhAuthChangeEvent.swift
//
//
//  Created by Nicolas Le Gorrec on 2/4/24 (approx.).
//

import Foundation

public enum LhAuthChangeEvent: String, Sendable {
    case initialSession = "INITIAL_SESSION"
    case passwordRecovery = "PASSWORD_RECOVERY"
    case signedIn = "SIGNED_IN"
    case signedOut = "SIGNED_OUT"
    case tokenRefreshed = "TOKEN_REFRESHED"
    case userUpdated = "USER_UPDATED"
    case userDeleted = "USER_DELETED"
    case mfaChallengeVerified = "MFA_CHALLENGE_VERIFIED"
}
