//
//  CoreDataHelper.swift
//  My Google Library
//
//  Created by Elena Moga on 2021-12-21.
//  Copyright © 2021 Elena Narcisa Moga. All rights reserved.
//
import CoreData

struct CoreDataHelper {
    private let dataObjectModel: NSManagedObjectModel
    internal let storeCoordinator: NSPersistentStoreCoordinator
    private let dataObjectModelAddress: URL
    internal let databaseAddress: URL
    let objectContext: NSManagedObjectContext
    init?(dataModelName: String) {
        guard let address = Bundle.main.url(forResource: dataModelName, withExtension: "momd") else {
            print("Could not instantiate address \(dataModelName)")
            return nil
        }
        dataObjectModelAddress = address
        guard let objectModel = NSManagedObjectModel(contentsOf: address) else {
            print("Could not instantiate object model \(address)")
            return nil
        }
        dataObjectModel = objectModel
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: objectModel)
        objectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        objectContext.persistentStoreCoordinator = storeCoordinator
        objectContext.mergePolicy = NSMergePolicy(merge: .rollbackMergePolicyType)
        let fileManager = FileManager.default
        guard let documentAddress = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not instantiate the document")
            return nil
        }
        databaseAddress = documentAddress.appendingPathComponent("MyGoogleLibraryData.sqlite")
        do {
            try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseAddress, options: nil)
        } catch {
            print("Could not register store \(databaseAddress)")
        }
    }
   func objectContextSave()  {
        if objectContext.hasChanges {
            do {
                try objectContext.save()
            } catch {
                fatalError("Error while saving main context: \(error)")
            }
        }
    }
}
