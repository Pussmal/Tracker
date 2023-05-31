import UIKit
import CoreData

protocol DataProviderDelegate: AnyObject {
    func didUpdate()
}

protocol DataProviderProtocol {
    var delegate: DataProviderDelegate? { get set }
    var numberOfSections: Int { get }
    var isTrackersForSelectedDate: Bool { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func getTracker(at indexPath: IndexPath) -> Tracker?
    func getTrackersCategory(atTrackerIndexPath indexPath: IndexPath) -> TrackerCategoryCoreData?
    func getSectionTitle(at section: Int) -> String?
    
    func loadTrackers(from date: Date, with filterString: String?) throws
    
    func getCompletedDayCount(from trackerId: String) -> Int
    func getCompletedDay(from trackerId: String, currentDay: Date) -> Bool
    
    func checkTracker(trackerId: String?, completed: Bool, with date: Date)
    
    func saveTracker(_ tracker: Tracker, in categoryCoreData: TrackerCategoryCoreData) throws
    func resaveTracker(at indexPath: IndexPath, newTracker: Tracker, category: TrackerCategoryCoreData?) throws
    func deleteTracker(at indexPath: IndexPath) throws
    
    func setPinnedCategory(tracker: PinnedTracker)
    func unpinnedTracker(unpinned newTracker: PinnedTracker, deleteTrackerAt deleteIndexPath: IndexPath)
}

final class DataProvider: NSObject {
    
    weak var delegate: DataProviderDelegate?
    
    private struct DataProviderConstants {
        static let entityName = "TrackerCoreData"
        static let sectionNameKeyPath = "category"
    }
    
    private let context: NSManagedObjectContext
  
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: DataProviderConstants.entityName)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category, ascending: true)
        ]
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: DataProviderConstants.sectionNameKeyPath,
            cacheName: nil)
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
}

extension DataProvider: DataProviderProtocol {
    var isTrackersForSelectedDate: Bool {
        guard let objects = fetchedResultsController.fetchedObjects else { return false }
        return objects.isEmpty ? false : true
    }
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func getSectionTitle(at section: Int) -> String? {
        let section = fetchedResultsController.sections?[section]
        let trackerCoreData = section?.objects?.first as? TrackerCoreData
        let categoryTitle = trackerCoreData?.category?.title
        return categoryTitle
    }
    
    func getTracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        do {
            let tracker = try trackerStore.creatTracker(from: trackerCoreData)
            return tracker
        } catch {
            assertionFailure("Error decoding tracker from core data")
        }
        return nil
    }
    
    func getTrackersCategory(atTrackerIndexPath indexPath: IndexPath) -> TrackerCategoryCoreData? {
        fetchedResultsController.object(at: indexPath).category
    }
    
    func loadTrackers(from date: Date, with filterString: String?) throws {
        let currentDayStringIndex = Date.getCurrentDayStringIndex(at: date)
        var predicates: [NSPredicate] = []
        
        let weekdayPredicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), currentDayStringIndex)
        predicates.append(weekdayPredicate)
        
        if let filterString {
            let filterPredicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.name), filterString)
            predicates.append(filterPredicate)
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        try? fetchedResultsController.performFetch()
        delegate?.didUpdate()
    }
    
    func getCompletedDayCount(from trackerId: String) -> Int {
        var count = 0

        fetchedResultsController.fetchedObjects?.forEach({ tcd in
            if tcd.id == trackerId {
                count = tcd.records?.count ?? 0
            }
        })
        
        return count
    }
    
    func getCompletedDay(from trackerId: String, currentDay: Date) -> Bool {
        var completed = false
        
        guard let trackers = fetchedResultsController.fetchedObjects else { return false }
        trackers.forEach { trackerCoreData in
            if trackerCoreData.id == trackerId {
                completed = trackerRecordStore.checkDate(from: trackerCoreData, with: currentDay)
            }
        }
        return completed
    }
    
    func checkTracker(trackerId: String?, completed: Bool, with date: Date) {
        guard let trackers = fetchedResultsController.fetchedObjects else { return }
        trackers.forEach { trackerCoreData in
            if trackerCoreData.id == trackerId {
                switch completed {
                case true:
                    trackerRecordStore.saveRecord(for: trackerCoreData, with: date)
                case false:
                    trackerRecordStore.removeRecord(for: trackerCoreData, with: date)
                }
            }
        }
    }
    
    func saveTracker(_ tracker: Tracker, in categoryCoreData: TrackerCategoryCoreData) throws {
        trackerStore.addNewTracker(tracker, with: categoryCoreData)
    }
    
    func resaveTracker(at indexPath: IndexPath, newTracker: Tracker, category: TrackerCategoryCoreData?) throws {
        let object = fetchedResultsController.object(at: indexPath)
        let trackerManagedObjectID = object.objectID
        try trackerStore.changeTracker(trackerManagedObjectID, newTracker: newTracker, category: category)
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let object = fetchedResultsController.object(at: indexPath)
        let trackerManagedObjectID = object.objectID
        trackerStore.deleteTracker(forId: trackerManagedObjectID)
        try fetchedResultsController.performFetch()
    }
    
    func setPinnedCategory(tracker: PinnedTracker) {
        guard let pinnedCategory = trackerCategoryStore.getTrackerCategoryCoreData(by: IndexPath(row: 0, section: 0)) else { return }
        let indexPathMarshalling = IndexPathMarshalling()
        
        let newTracker = Tracker(
            id: tracker.tracker.id,
            name: tracker.tracker.name,
            color: tracker.tracker.color,
            emoji: tracker.tracker.emoji,
            schedule: tracker.tracker.schedule,
            isHabit: tracker.tracker.isHabit,
            isPinned: true,
            idCategory: tracker.idOldCategory,
            indexPathInCategory: indexPathMarshalling.stringFromArray(indexPath: tracker.oldIndexPath)
        )
        
        try? deleteTracker(at: tracker.oldIndexPath)
        try? saveTracker(newTracker, in: pinnedCategory)
        try? fetchedResultsController.performFetch()
    }
    
    func unpinnedTracker(unpinned newTracker: PinnedTracker, deleteTrackerAt deleteIndexPath: IndexPath) {
      
        
        let tracker = Tracker(
            id: newTracker.tracker.id,
            name: newTracker.tracker.name,
            color: newTracker.tracker.color,
            emoji: newTracker.tracker.emoji,
            schedule: newTracker.tracker.schedule,
            isHabit: newTracker.tracker.isHabit,
            isPinned: false,
            idCategory: nil,
            indexPathInCategory: nil)
        
        guard
            let idCategory = newTracker.tracker.idCategory,
            let stringIndexPathCategory = newTracker.tracker.indexPathInCategory,
            let indexPath = IndexPathMarshalling().arrayFromString(string: stringIndexPathCategory),
            let category = trackerCategoryStore.getTrackerCategoryCoreData(byCategoryId: idCategory)
        else { return }
       
        try? deleteTracker(at: deleteIndexPath)
        trackerStore.addTrackerAt(indexPath: indexPath, tracker: tracker, inCategory: category)
        try? fetchedResultsController.performFetch()
    }
}


