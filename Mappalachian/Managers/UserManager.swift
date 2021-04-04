//
//  UserManager.swift
//  Mappalachian
//
//  Created by Wilson Styres on 2/5/21.
//

import Foundation

struct User: Codable {
    var username: String
    var roles: [String]
    var bannerID: String
    var name: String?

    private enum CodingKeys: String, CodingKey {
        case username = "authId", roles, bannerID = "userId", name
    }
}

struct Schedule: Codable {
    var person: Person
    var terms: [Term]
    
    private enum CodingKeys: String, CodingKey {
        case person, terms
    }
}

struct Person: Codable {
    var bannerID: String
    var name: String
    
    private enum CodingKeys: String, CodingKey {
        case bannerID = "id", name
    }
}

struct Term: Codable {
    var identifier: String
    var name: String
    var startDate: String
    var endDate: String
    var courses: [Course]
    
    private enum CodingKeys: String, CodingKey {
        case identifier = "id", name, startDate, endDate, courses = "sections"
    }
}

struct Course: Codable {
    var identifier: String
    var title: String
    var isInstructor: Bool
    var name: String
    var description: String?
    var section: String
    var firstMeetingDate: String?
    var lastMeetingDate: String?
    var credits: Double?
    var instructors: [Instructor]?
    var meetingPatterns: [MeetingPattern]?
    var location: String?
    var academicLevels: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case identifier = "sectionId", title = "sectionTitle", isInstructor, name = "courseName", description = "courseDescription", section = "courseSectionNumber", firstMeetingDate, lastMeetingDate, credits, instructors, meetingPatterns, location, academicLevels
    }
}

struct Instructor: Codable {
    var firstName: String
    var lastName: String
    var middleInitial: String?
    var bannerID: String
    var primary: String
    var formattedName: String
    
    private enum CodingKeys: String, CodingKey {
        case firstName, lastName, middleInitial, bannerID = "instructorId", primary, formattedName
    }
}

struct MeetingPattern: Codable {
    var instructionalMethodCode: String
    var startDate: String
    var endDate: String
    var startTime: String
    var endTime: String
    var daysOfWeek: [Int]
    var room: String
    var building: String
    var buildingID: String
    var campus: String
    var campusID: String
    
    private enum CodingKeys: String, CodingKey {
        case instructionalMethodCode, startDate, endDate, startTime, endTime, daysOfWeek, room, building, buildingID = "buildingId", campus, campusID = "campusId"
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
    private var schedule: Schedule? = nil
    
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
        let authenticationURL = URL(string: "https://banmobprod.appstate.edu:8443/banner-mobileserver/api/2.0/security/getUserInfo")
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
    
    func signOut() {
        userInfo = nil
        schedule = nil
        
        deleteLoginInformation()
        if let cookie = HTTPCookieStorage.shared.cookies?.first(where: { $0.name == "JSESSIONID" && $0.domain == "banmobprod.appstate.edu" }) {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
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
    
    func fetchSchedule(for user: User, completion: @escaping(Schedule?, Error?) -> Void) {
        if schedule != nil {
            completion(schedule, nil)
        } else {
            let scheduleURL = URL(string: "https://banmobprod.appstate.edu:8443/banner-mobileserver/api/2.0/courses/overview/\(user.bannerID)")
            let request = URLRequest(url: scheduleURL!)
            let task = authenticationSession!.dataTask(with: request, completionHandler: { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    guard httpResponse.statusCode != 401, error == nil else {
                        self.deleteLoginInformation() // Delete login information if the information was incorrect
                        completion(nil, error)
                        return
                    }
                     
                    do {
                        self.schedule = try JSONDecoder().decode(Schedule.self, from: data!)
                        
                        for term in self.schedule!.terms {
                            for var course in term.courses {
                                course.term = term
                            }
                        }
                        
                        completion(self.schedule, nil)
                    } catch {
                        print("unable to decode json \(error)")
                        completion(nil, nil)
                    }
                }
            })
            task.resume()
        }
    }
    
//    func fetchCourseInformation(for user: User, course: Course, completion: @escaping(Course?, Error?) -> Void) {
//        let scheduleURL = URL(string: "https://banmobprod.appstate.edu:8443/banner-mobileserver/api/2.0/courses/overview/\(user.bannerID)")
//        var request = URLRequest(url: scheduleURL!)
//        request.setValue(course.identifier, forHTTPHeaderField: "section")
//
//        let task = authenticationSession!.dataTask(with: request, completionHandler: { (data, response, error) in
//            if let httpResponse = response as? HTTPURLResponse {
//                guard httpResponse.statusCode != 401, error == nil else {
//                    self.deleteLoginInformation() // Delete login information if the information was incorrect
//                    completion(nil, error)
//                    return
//                }
//
//                do {
//                    let filledSchedule = try JSONDecoder().decode(Schedule.self, from: data!)
//                    let filledCourse = filledSchedule.terms.first?.courses.first
//
//                    completion(filledCourse, nil)
//                } catch {
//                    print("unable to decode json \(error)")
//                    completion(nil, nil)
//                }
//            }
//        })
//        task.resume()
//    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = retrieveLoginInformation()
        completionHandler(.useCredential, credential)
    }
    
}
