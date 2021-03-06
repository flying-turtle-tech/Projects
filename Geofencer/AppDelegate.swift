//
//  AppDelegate.swift
//  Geofencer
//
//  Created by Jonathan Kovach on 1/8/22.
//

import UIKit
import CoreData
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var fencer: Geofencer?
    var window: UIWindow?
    var navigationController: UINavigationController?
    let dataSource = GeoDataSource()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        fencer = Geofencer()
        do {
            try fencer?.start()
        } catch GeofencerError.monitoringNotAvailable {
            print("Device does not support monitoring")
            return false
        } catch {
            print("Some other error occurred")
            return false
        }
        let buildings = persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Building")
        do {
            let fences = try buildings.fetch(request)
            let vc = ViewController(fences: fences)
            vc.delegate = self
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = vc
            window?.makeKeyAndVisible()

        } catch {
            print("Failed to get saved locations")
            return false
        }
        return true
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Geofencer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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

extension AppDelegate: ViewControllerDelegate {
    func saveBuilding(_ address: String, region: CLCircularRegion) -> NSManagedObject? {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Building", in: context),
            let fencer = fencer else {
            return nil
        }
        fencer.addRegion(region: region)
        let building = NSManagedObject(entity: entity, insertInto: context)
        building.setValue(address, forKey: "address")
        do {
            try context.save()
            return building
        } catch {
            print("Failed to save context")
            return nil
        }
    }
}
