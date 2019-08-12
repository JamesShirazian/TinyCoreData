import CoreData

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)

public class MyNSManagedObject: NSManagedObject, Identifiable {}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public class CoreDataManager: NSObject {
    public static let shared = CoreDataManager()

    /// Set Name of the model
    public var modelName: String = ""

    // MARK: - Core Data Fetching entity

    /// <#Description#>
    /// - Parameter entityName: <#entityName description#>
    /// - Parameter predicate: <#predicate description#>
    /// - Parameter sort: <#sort description#>
    public func fetchObjects<T>(for entityName: String, predicate: NSPredicate? = nil, sort: [NSSortDescriptor]? = nil) -> [T] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.sortDescriptors = sort
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        let result = try! persistentContainer.viewContext.fetch(request) as! [T]
        return result.isEmpty ? [] : result
    }

    /// <#Description#>
    /// - Parameter entityName: <#entityName description#>
    /// - Parameter completionHandler: <#completionHandler description#>
    public func addObject(for entityName: String, completionHandler: (_ object: NSManagedObject, _ viewContext: NSManagedObjectContext) -> Void) {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: persistentContainer.viewContext)
        let newObject = NSManagedObject(entity: entity!, insertInto: persistentContainer.viewContext)
        completionHandler(newObject, persistentContainer.viewContext)
    }

    /// <#Description#>
    /// - Parameter object: <#object description#>
    public func deleteObject(object: NSManagedObject) {
        persistentContainer.viewContext.delete(object)
        saveContext()
    }

    /// <#Description#>
    /// - Parameter entityName: <#entityName description#>
    public func deleteAllObjects(for entityName: String) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        try persistentContainer.viewContext.execute(request)
        saveContext()
    }

    // MARK: - Core Data Saving support

    func saveContext() {
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

    // MARK: - Core Data stack

    private lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentCloudKitContainer(name: modelName)

        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        description.shouldAddStoreAsynchronously = true
        //  container.persistentStoreDescriptions = [description]

        container.loadPersistentStores(completionHandler: { _, error in
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
}
