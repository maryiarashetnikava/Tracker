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
        record.date = Calendar.current.startOfDay(for: date)
        
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения записи: \(error)")
        }
    }
    
    func deleteRecord(trackerId: UUID, date: Date) {
        guard let records = fetchedResultsController.fetchedObjects else { return }
        
        let calendar = Calendar.current
        
        for record in records {
            if record.trackerId == trackerId,
               let recordDate = record.date,
               calendar.isDate(recordDate, inSameDayAs: date) {
                
                context.delete(record)
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Ошибка удаления записи: \(error)")
        }
    }
    
    func fetchRecords() -> [TrackerRecordCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    func isTrackerCompleted(trackerId: UUID, date: Date) -> Bool {
        guard let records = fetchedResultsController.fetchedObjects else { return false }
        
        let calendar = Calendar.current
        
        return records.contains { record in
            guard let recordDate = record.date else { return false }
            
            return record.trackerId == trackerId &&
                   calendar.isDate(recordDate, inSameDayAs: date)
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateRecords()
    }
}

