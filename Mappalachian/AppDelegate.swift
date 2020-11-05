//
//  AppDelegate.swift
//  Mappalachian
//
//  Created by Wilson Styres on 10/20/20.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    class func delegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let moc = persistentContainer.viewContext

        do {
            let count = try moc.count(for: NSFetchRequest(entityName: "Building"))
            if count == 0 {
                let abh = NSEntityDescription.insertNewObject(forEntityName: "Building", into: moc) as! Building
                abh.name = "Anne Belk Hall"
                abh.prefix = "ABH"
                abh.address = "224 Joyce Lawrence Lane"
                
                let abhCoords: [[Double]] = [
                ]
                
                for location in abhCoords {
                    let poly = NSEntityDescription.insertNewObject(forEntityName: "Coordinate", into: moc) as! Coordinate
                    poly.lat = location[0]
                    poly.long = location[1]
                    abh.addToCoordinates(poly)
                }
                
                let swh = NSEntityDescription.insertNewObject(forEntityName: "Building", into: moc) as! Building
                swh.name = "Smith Wright Hall"
                swh.prefix = "SWH"
                swh.address = "224 Joyce Lawrence Lane"
                
                let swhCoords: [[Double]] = [[36.2146359514052, -81.68086597881214],
                                             [36.21498255637485, -81.68098131381036],
                                             [36.21503268953212, -81.68075109086244],
                                             [36.21485487896638, -81.68069387039138],
                                             [36.21486317440305, -81.68064916691053],
                                             [36.214806909722185, -81.6806299443972],
                                             [36.21479969629314, -81.68066347201295],
                                             [36.21468788814859, -81.68062770923643]
                ]
                
                for location in swhCoords {
                    let poly = NSEntityDescription.insertNewObject(forEntityName: "Coordinate", into: moc) as! Coordinate
                    poly.lat = location[0]
                    poly.long = location[1]
                    swh.addToCoordinates(poly)
                }
                
                let dddh = NSEntityDescription.insertNewObject(forEntityName: "Building", into: moc) as! Building
                dddh.name = "D.D. Dougherty Hall"
                dddh.prefix = "DDDH"
                dddh.address = "224 Joyce Lawrence Lane"
                
                let dddhCoords: [[Double]] = [[36.21489506169081, -81.68058057733526],
                                              [36.215044379240666, -81.68056001371728],
                                              [36.21502057501267, -81.68028911058194],
                                              [36.21495781837692, -81.68029358094431],
                                              [36.21493040740573, -81.68003161849286],
                                              [36.214822927517645, -81.68004413548306],
                                              [36.21480994335745, -81.6799574107306],
                                              [36.214725546263566, -81.67996545735836],
                                              [36.214732038350974, -81.68005397026397],
                                              [36.21462311545831, -81.68007274572882],
                                              [36.214637542348314, -81.680248877443],
                                              [36.21472193953713, -81.68024261896835],
                                              [36.214732038350974, -81.68035348360416],
                                              [36.21471689014625, -81.68035705991048],
                                              [36.214719775507774, -81.68041517441719],
                                              [36.2147392517697, -81.68041338630496],
                                              [36.21475223594166, -81.68050547547597],
                                              [36.21488640559221, -81.68048580595497],
                                              [36.21489506169081, -81.68058057733526]
                ]
                
                for location in dddhCoords {
                    let poly = NSEntityDescription.insertNewObject(forEntityName: "Coordinate", into: moc) as! Coordinate
                    poly.lat = location[0]
                    poly.long = location[1]
                    dddh.addToCoordinates(poly)
                }
                
                saveContext()
            }
        } catch {
            print("err")
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Mappalachian")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            #if DEBUG
            debugPrint(storeDescription.url?.absoluteString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: "\\ ") ?? "No database location")
            #endif
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

