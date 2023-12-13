//
//  Persistence.swift
//  Scanner
//
//  Created by Jack on 29/3/2021.
//

import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    let bill = Bill()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Document(context: viewContext)
            newItem.address = String()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Scanner")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
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
    }
    
    func documentSave(organization: String, address: String, image: Data) {
        let document = Document(context: container.viewContext)
        document.organization = organization
        document.address = address
        document.image = image
        
        bill.addressCoordinate(address: address) { location in
            guard let location = location else { return }
            let lat: Float = Float(location.coordinate.latitude)
            let long: Float = Float(location.coordinate.longitude)
            document.lat = lat
            document.long = long
        }
        
        do {
            try container.viewContext.save()
        } catch {
            print("Failed to save movie \(error)")
        }
        
    }
    
    func documentUpdate() {
        do {
            try container.viewContext.save()
        } catch {
            container.viewContext.rollback()
        }
    }
    
//    func documentDelete(document: Document) {
//        withAnimation {
//            offsets.map { documents[$0] }.forEach(viewContext.delete)
//
//            do {
//                try container.viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
    
}
