import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    
    var trackerRecordsCoreData: [TrackerRecordCoreData] {
        let fetchedRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchedRequest.returnsObjectsAsFaults = false
        guard let objects = try? context.fetch(fetchedRequest) else { return [] }
        return objects
    }
    
    var countCompletedTrackersForDay: Int {
       return 0
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


