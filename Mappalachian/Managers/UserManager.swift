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
    
    static let server = "banmobprod.appstate.edu"
    
    static let shared: UserManager = {
        return UserManager()
    }()
    
    func retrieveLoginInformation() {
        
    }
    
    func storeLoginInformation(_ credentials: BannerCredentials) throws {
        let account = credentials.username
        let password = credentials.password.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrServer as String: UserManager.server,
                                    kSecValueData as String: password]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    
    func login(_ credentials: BannerCredentials, completion: () -> Void) {
        do {
            try storeLoginInformation(credentials)
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
