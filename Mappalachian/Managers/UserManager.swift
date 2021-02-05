//
//  UserManager.swift
//  Mappalachian
//
//  Created by Wilson Styres on 2/5/21.
//

import Foundation

class UserManager: NSObject, URLSessionDelegate {
    
    var authenticationSession: URLSession?
    var protectionSpace: URLProtectionSpace?
    
    static let sharedInstance: UserManager = {
        return UserManager()
    }()
    
    override init() {
        super.init()
        
        authenticationSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        protectionSpace = URLProtectionSpace(host: "banmobprod.appstate.edu", port: 8443, protocol: "https", realm: nil, authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
    }
    
    func obtainUserCredentials() -> URLCredential? {
        if let space = protectionSpace {
            return URLCredentialStorage.shared.defaultCredential(for: space)
        }
        return nil
    }
    
    func login(username: String, password: String, completion: () -> Void) {
        if let authenticationURL = URL(string: "https://banmobprod.appstate.edu:8443/banner-mobileserver/api/2.0/security/getUserInfo") {
            let request = URLRequest(url: authenticationURL)
            let task = authenticationSession?.dataTask(with: request)
            task?.resume()
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("Received authentication challenge \(challenge)")
    }
}
