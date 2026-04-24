import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdateRecords()
}

final class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        
        let request = TrackerRecordCoreData.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
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
}

extension TrackerRecordStore {
    
    func addRecord(trackerId: UUID, date: Date) {
        let record = TrackerRecordCoreData(context: context)
        
        record.trackerId = trackerId
        record.date = date
        
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения записи: \(error)")
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}

