//
//  UserManager.swift
//  Mappalachian
//
//  Created by Wilson Styres on 2/5/21.
//

import Foundation

struct User : Codable {
    var username: String
    var roles: [String]
    var bannerID: String

    private enum CodingKeys : String, CodingKey {
        case username = "authId", roles, bannerID = "userId"
    }
}

class UserManager: NSObject, URLSessionDelegate {
    
    static let shared: UserManager = {
        return UserManager()
    }()
    
    let server = "banmobprod.appstate.edu"
    var authenticationSession: URLSession?
    var protectionSpace: URLProtectionSpace?

    private var userInfo: User? = nil
    
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
    
    // Authenticates a user with banner and stores their login information
    func authenticate(_ completion: @escaping (Bool, Error?) -> Void) {
        let authenticationURL = URL(string: "https://banmobprod.appstate.edu:8443/banner-mobileserver/api/2.0/security/getUserInfo".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        let request = URLRequest(url: authenticationURL!)
        let task = authenticationSession!.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode != 401, error == nil else {
                    self.deleteLoginInformation() // Delete login information if the information was incorrect
                    completion(false, error)
                    return
                }
                
                do {
                    self.userInfo = try JSONDecoder().decode(User.self, from: data!)
                    completion(true, nil)
                } catch {
                    print("unable to decode json")
                    completion(false, nil)
                }
            }
        })
        task.resume()
    }
    
    func fetchUserInfo(completion: @escaping (User?, Error?) -> Void) {
        if userInfo != nil {
            completion(userInfo, nil)
        } else {
            authenticate { (success, error) in
                completion(self.userInfo, error) // authenticate() sets userInfo when it is done so it'll either be nil or have a value
            }
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = retrieveLoginInformation()
        completionHandler(.useCredential, credential)
    }
    
}
