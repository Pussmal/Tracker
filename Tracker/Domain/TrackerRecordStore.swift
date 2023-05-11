import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    
    var trackerRecordsCoreData: [TrackerRecordCoreData] {
        let fetchedRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
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
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    func saveRecord(for trackerCoreData: TrackerCoreData, with date: Date) {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.tracker = trackerCoreData
        trackerRecordCoreData.date = date
        saveContext()
    }
    
    func removeRecord(for trackerCoreData: TrackerCoreData, with date: Date) {
        trackerRecordsCoreData.forEach { trackerRecordCoreData in
            guard trackerRecordCoreData.tracker == trackerCoreData,
                  trackerRecordCoreData.date == date else { return }
            context.delete(trackerRecordCoreData)
            saveContext()
        }
    }
    
    func checkDate(from trackerCoreData: TrackerCoreData, with date: Date) -> Bool {
        var completed = false
        
        let fetchedRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchedRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.date), date as NSDate)
        guard let objects = try? context.fetch(fetchedRequest) else { return false }
        
        objects.forEach { trcd in
            if trcd.tracker == trackerCoreData {
                completed = true
            } else {
                completed = false
            }
        }
        return completed
    }
    
    func getRecord(from trackerRecordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let date = trackerRecordCoreData.date else { throw TrackerRecordStoreError.errorDecodingDate }
        return TrackerRecord(checkDate: date)
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


