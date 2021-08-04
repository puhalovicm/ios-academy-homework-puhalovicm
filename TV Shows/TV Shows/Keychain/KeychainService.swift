//
//  KeychainService.swift
//  TV Shows
//
//  Created by Mateo Puhalović on 01.08.2021..
//

import Foundation
import KeychainAccess

class KeychainService {

    static let sharedInstance = KeychainService()

    private let keychain = Keychain(service: Constants.keychainServiceName)

    private init() { }

    func fetchAuthInfo() -> AuthInfo? {
        do {
            let accessToken = try keychain.get("access-token")
            let client = try keychain.get("client")
            let tokenType = try keychain.get("token-type")
            let uid = try keychain.get("uid")

            guard
                let accessToken = accessToken,
                let client = client,
                let tokenType = tokenType,
                let uid = uid
            else {
                return nil
            }

            let authInfo = AuthInfo(
                headers: [
                    "access-token": accessToken,
                    "client": client,
                    "token-type": tokenType,
                    "uid": uid
                ]
            )

            return authInfo
        } catch let error {
            print("error: \(error)")
            return nil
        }
    }

    func saveAuthInfo(authInfo: AuthInfo) {
        keychain["access-token"] = authInfo.headers["access-token"]
        keychain["client"] = authInfo.headers["client"]
        keychain["token-type"] = authInfo.headers["token-type"]
        keychain["uid"] = authInfo.headers["uid"]
    }

    func removeAuthInfo() {
        try? keychain.remove("access-token")
        try? keychain.remove("client")
        try? keychain.remove("token-type")
        try? keychain.remove("uid")
    }
}
