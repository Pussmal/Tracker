import UIKit
import CoreData

enum Pinned {
    case pinned
    case unpinned
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate()
}

protocol DataProviderStatisticProtocol: AnyObject {
    var isTrackersInCoreData: Bool { get }
}

protocol DataProviderProtocol {
    var delegate: DataProviderDelegate? { get set }
    var numberOfSections: Int { get }
    var isTrackersForSelectedDate: Bool { get }
    var isTrackersInCoreData: Bool { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func getTracker(at indexPath: IndexPath) -> Tracker?
    func getTrackersCategory(atTrackerIndexPath indexPath: IndexPath) -> TrackerCategoryCoreData?
    func getSectionTitle(at section: Int) -> String?
    
    func loadTrackers(from date: Date, showTrackers: ShowTrackers, with filterString: String?) throws
    
    func getCompletedDayCount(from trackerId: String) -> Int
    func getCompletedDay(from trackerId: String, currentDay: Date) -> Bool
    
    func checkTracker(trackerId: String?, completed: Bool, with date: Date)
    
    func saveTracker(_ tracker: Tracker, in categoryCoreData: TrackerCategoryCoreData) throws
    func resaveTracker(at indexPath: IndexPath, newTracker: Tracker, category: TrackerCategoryCoreData?) throws
    func deleteTracker(at indexPath: IndexPath) throws
    
    func pinned(tracker: PinnedTracker, pinned: Pinned)
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
    
    private func changePinnedCategory(trackerIndexPath indexPath: IndexPath, category: TrackerCategoryCoreData?, isPinned: Bool, idCategory: String?) {
        let object = fetchedResultsController.object(at: indexPath)
        try? trackerStore.changeTrackerCategory(object.objectID, category: category, isPinned: isPinned, idCadegory: idCategory)
        try? fetchedResultsController.performFetch()
    }
}

extension DataProvider: DataProviderProtocol {
    var isTrackersForSelectedDate: Bool {
        guard let objects = fetchedResultsController.fetchedObjects else { return false }
        return objects.isEmpty
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
    
    func loadTrackers(from date: Date, showTrackers: ShowTrackers, with filterString: String?) throws {
        let currentDayStringIndex = Date.getCurrentDayStringIndex(at: date)
        var predicates: [NSPredicate] = []
        
        let weekdayPredicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), currentDayStringIndex)
        predicates.append(weekdayPredicate)
        
        if let filterString {
            let filterPredicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.name), filterString)
            predicates.append(filterPredicate)
        }
        
        switch showTrackers {
        case .isCompleted:
            let completedPredicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(TrackerCoreData.records), date.stringDateRecordFormat)
            predicates.append(completedPredicate)
        case .isNotComplited:
            let completedPredicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.records), date as NSDate)
            predicates.append(completedPredicate)
        case .isAllTrackers:
            break
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
    
    func pinned(tracker: PinnedTracker, pinned: Pinned) {
        var category: TrackerCategoryCoreData?
        var isPinned: Bool = false
        var idCategory: String?
        switch pinned {
        case .pinned:
            // by default категория "Закрепленные", создана при первом запуске программы
            category = trackerCategoryStore.getTrackerCategoryCoreData(by: IndexPath(row: 0, section: 0))
            idCategory = tracker.idOldCategory
            isPinned = true
        case .unpinned:
            guard let oldIDCategory = tracker.tracker.idCategory else { return }
            category = trackerCategoryStore.getTrackerCategoryCoreData(byCategoryId: oldIDCategory)
            idCategory = tracker.idOldCategory
        }
        changePinnedCategory(trackerIndexPath: tracker.trackerIndexPath, category: category, isPinned: isPinned, idCategory: idCategory)
    }
}

extension DataProvider: DataProviderStatisticProtocol {
    var isTrackersInCoreData: Bool {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: DataProviderConstants.entityName)
        let result = try? context.fetch(fetchRequest)
        guard let isEmpty = result?.isEmpty else { return false }
        return !isEmpty
    }
}
