//
//  UserManager.swift
//  Mappalachian
//
//  Created by Wilson Styres on 2/5/21.
//

import Foundation

struct BannerCredentials {
    var username: String
    var password: String
}

enum BannerError: Error {
    case incorrectLogin
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

class UserManager {
    
    static let shared: UserManager = {
        return UserManager()
    }()
    
    let server = "banmobprod.appstate.edu"
    
    func deleteLoginInformation() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    func retrieveLoginInformation() throws -> BannerCredentials {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: server,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItem = item as? [String : Any],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8),
            let username = existingItem[kSecAttrAccount as String] as? String
        else {
            throw KeychainError.unexpectedPasswordData
        }
        return BannerCredentials(username: username, password: password)
    }
    
    func storeLoginInformation(_ credentials: BannerCredentials) throws {
        do {
            try deleteLoginInformation() // Delete old login information before storing new one
            let username = credentials.username
            let password = credentials.password.data(using: String.Encoding.utf8)!
            let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                        kSecAttrAccount as String: username,
                                        kSecAttrServer as String: server,
                                        kSecValueData as String: password]
            
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    func login(_ credentials: BannerCredentials, completion: () -> Void) {
        do {
//            try storeLoginInformation(credentials)
            let credentials = try retrieveLoginInformation()
            print("got credentials: \(credentials.username) \(credentials.password)")
        } catch {
            fatalError("oh no!")
        }
        
        let loginData = String(format: "%@:%@", credentials.username, credentials.password).data(using: .utf8)!
        let base64LoginData = loginData.base64EncodedString()

        if let authenticationURL = URL(string: "https://banmobprod.appstate.edu:8443/banner-mobileserver/api/2.0/security/getUserInfo") {
            var request = URLRequest(url: authenticationURL)
            request.httpMethod = "GET"
            request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                do {
                    let string = String(data: data!, encoding: .utf8)
                    print("finished! \(string)")
                } catch {
                    print("oh no!")
                }
            })
            task.resume()
        }
    }
    
}
