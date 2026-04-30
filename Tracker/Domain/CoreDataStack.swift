import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        
        UIColorTransformer.register()
        DaysValueTransformer.register()
        
        persistentContainer = NSPersistentContainer(name: "TrackerModel")
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Ошибка загрузки Core Data: \(error), \(error.userInfo)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                print("Ошибка сохранения: \(error), \(error.userInfo)")
            }
        }
    }
}
