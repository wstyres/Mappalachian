//
//  UserManager.swift
//  Mappalachian
//
//  Created by Wilson Styres on 2/5/21.
//

import Foundation

class UserManager: NSObject, URLSessionDelegate {
    
    static let shared: UserManager = {
        return UserManager()
    }()
    
    let server = "banmobprod.appstate.edu"
    var authenticationSession: URLSession?
    var protectionSpace: URLProtectionSpace?
    
    override init() {
        super.init()
        
        authenticationSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        protectionSpace = URLProtectionSpace(host: server, port: 8443, protocol: "https", realm: "Mobile Integration Server banner-mobileserver", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
    }
    
    func deleteLoginInformation() {
        if let credential = retrieveLoginInformation() {
            URLCredentialStorage.shared.remove(credential, for: protectionSpace!)
        }
    }
    
    func retrieveLoginInformation() -> URLCredential? {
        return URLCredentialStorage.shared.defaultCredential(for: protectionSpace!)
    }
    
    func storeLoginInformation(username: String, password: String) {
        deleteLoginInformation() // Delete old login information before storing new one
        
        let credential = URLCredential(user: username, password: password, persistence: .permanent)
        URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace!)
    }
    
    func authenticate(username: String, password: String, completion: @escaping (Error?) -> Void) {
        storeLoginInformation(username: username, password: password)
        
        let authenticationURL = URL(string: "https://banmobprod.appstate.edu:8443/banner-mobileserver/api/2.0/security/getUserInfo".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        let request = URLRequest(url: authenticationURL!)
        let task = authenticationSession!.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode != 401, error == nil else {
                    print("error: \(error?.localizedDescription)")
                    self.deleteLoginInformation()
                    completion(error)
                    return
                }
                
                for cookie in HTTPCookieStorage.shared.cookies! {
                    print("EXTRACTED COOKIE: \(cookie)")
                }
                
                do {
                    let userInfo = try JSONSerialization.jsonObject(with: data!, options: [])
                    print("userInfo: \(userInfo)")
                } catch {
                    print("unable to decode json")
                }
            }
        })
        task.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = retrieveLoginInformation()
        completionHandler(.useCredential, credential)
    }
    
}
