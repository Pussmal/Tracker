import CoreData

final class TrackerRecordStore: NSObject {
    var trackerRecordsCoreData: [TrackerRecordCoreData] {
        let fetchedRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchedRequest.returnsObjectsAsFaults = false
        guard let objects = try? context.fetch(fetchedRequest) else { return [] }
        return objects
    }
    
    private struct TrackerRecordStoreConstants {
        static let entityName = "TrackerCoreData"
        static let categorySectionNameKeyPath = "category"
    }
    
    private enum TrackerRecordStoreError: Error {
        case errorDecodingDate
    }
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveRecord(for trackerCoreData: TrackerCoreData, with date: Date) {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.tracker = trackerCoreData
        trackerRecordCoreData.date = date.getShortDate
        saveContext()
    }
    
    func removeRecord(for trackerCoreData: TrackerCoreData, with date: Date) {
        trackerRecordsCoreData.forEach { trackerRecordCoreData in
            guard trackerRecordCoreData.tracker == trackerCoreData,
                  trackerRecordCoreData.date == date.getShortDate else { return }
            context.delete(trackerRecordCoreData)
            saveContext()
        }
    }
    
    func countCompletedTrackersFor(date: Date) -> Int {
        let fetchedRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchedRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.date), date as NSDate)
        guard let objects = try? context.fetch(fetchedRequest) else { return 0 }
        return objects.count
    }
        
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


