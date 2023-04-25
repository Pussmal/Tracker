import UIKit
import CoreData

final class TrackerStore: NSObject {
    
    private struct TrackerStoreConstants {
        static let entityName = "TrackerCoreData"
        static let categorySectionNameKeyPath = "category"
    }
    
    private enum TrackerStoreError: Error {
        case errorDecodingId
        case errorDecodingName
        case errorDecodingColorHex
        case errorDecodingEmoji
        case errorDecodingScheduleString
        case errorDecodingCreatedAt
    }
    
    private let context: NSManagedObjectContext
    private let colorMarshaling = UIColorMarshalling()
    private let scheduleMarshaling = ScheduleMarshalling()
    
    private var tracers: [Tracker] {
        guard let objects = fetchedResultController.fetchedObjects,
              let trackers = try? objects.map({ try self.creatTracker(from: $0) })
        else { return [] }
        return trackers
    }

    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: TrackerStoreConstants.entityName)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.categoryId, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.createdAt, ascending: true)
        ]
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: TrackerStoreConstants.categorySectionNameKeyPath,
            cacheName: nil)
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        return fetchedResultController
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    func addNewTracker(_ tracker: Tracker) {
       creatTrackerCoreData(from: tracker)
       saveContext()
    }
    
    private func creatTrackerCoreData(from tracker: Tracker) {
        let colorHex = colorMarshaling.hexStringFromColor(color: tracker.color ?? UIColor())
        let sheduleString = scheduleMarshaling.stringFromArray(array: tracker.schedule ?? [String]())
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.colorHex = colorHex
        trackerCoreData.createdAt = Date()
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = sheduleString
    }
    
    private func creatTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else { throw TrackerStoreError.errorDecodingId }
        guard let name = trackerCoreData.name else { throw TrackerStoreError.errorDecodingName }
        guard let colorHex = trackerCoreData.colorHex else { throw TrackerStoreError.errorDecodingColorHex }
        guard let emoji = trackerCoreData.emoji else { throw TrackerStoreError.errorDecodingEmoji }
        guard let scheduleString = trackerCoreData.schedule else { throw TrackerStoreError.errorDecodingScheduleString }
        guard let createdAt = trackerCoreData.createdAt else { throw TrackerStoreError.errorDecodingCreatedAt }
   
        return Tracker(
            id: id,
            name: name,
            color: colorMarshaling.colorWithHexString(hexString: colorHex),
            emoji: emoji,
            schedule: scheduleMarshaling.arrayFromString(string: scheduleString),
            createdAt: createdAt
        )
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

extension TrackerStore: NSFetchedResultsControllerDelegate {}
