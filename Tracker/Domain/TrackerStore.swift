import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    weak var delegate: TrackerStoreDelegate?
    
    var trackers: [TrackerCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var numberOfItems: Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCoreData {
        fetchedResultsController.object(at: indexPath)
    }
}

extension TrackerStore {
    
    func add(_ tracker: Tracker) {
        let trackerCD = TrackerCoreData(context: context)
        
        trackerCD.id = tracker.id
        trackerCD.name = tracker.name
        trackerCD.emoji = tracker.emoji
        trackerCD.color = tracker.color
        trackerCD.schedule = tracker.schedule as NSObject
        trackerCD.category = tracker.category

        
        do {
            try context.save()
            
        } catch {
            print("Ошибка сохранения: \(error)")
        }
        
    }
    
    func delete(_ trackerCD: TrackerCoreData) {
        context.delete(trackerCD)

        do {
            try context.save()
        } catch {
            print("Ошибка удаления: \(error)")
        }
    }
    
    func update(_ tracker: Tracker) {

        guard let trackerCD = trackers.first(where: {
            $0.id == tracker.id
        }) else {
            return
        }

        trackerCD.name = tracker.name
        trackerCD.emoji = tracker.emoji
        trackerCD.color = tracker.color
        trackerCD.schedule = tracker.schedule as NSObject
        trackerCD.category = tracker.category

        do {
            try context.save()
        } catch {
            print("Ошибка обновления: \(error)")
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
