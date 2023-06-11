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
    var bestPeriod: Int { get }
    var completedTrackersAllTime: Int { get }
    var perfectDays: Int { get }
    func averageValueCompletedTrackers(forDate date: Date?) -> Float
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
    
    func getCompletedDayCount(at indexPath: IndexPath) -> Int
    func getCompletedDay(currentDay: Date, at indexPath: IndexPath) -> Bool
    
    func checkTracker(trackerId: String?, completed: Bool, with date: Date)
    
    func saveTracker(_ tracker: Tracker, in categoryCoreData: TrackerCategoryCoreData) throws
    func resaveTracker(at indexPath: IndexPath, newTracker: Tracker, category: TrackerCategoryCoreData?) throws
    func deleteTracker(at indexPath: IndexPath) throws
    
    func pinned(tracker: PinnedTracker, pinned: Pinned)
    
    func checkPerfectDay(forDate date: Date)
}

final class DataProvider: NSObject {
    
    weak var delegate: DataProviderDelegate?
    
    private struct DataProviderConstants {
        static let entityName = "TrackerCoreData"
        static let sectionNameKeyPath = "category"
    }
    
    private let context: NSManagedObjectContext
    
    private lazy var trackerStore = TrackerStore(context: context)
    private lazy var trackerCategoryStore = TrackerCategoryStore()
    private lazy var trackerRecordStore = TrackerRecordStore(context: context)
    private lazy var perfectDaysStorage = PerfectDaysStorage.shared
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: DataProviderConstants.entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category, ascending: true)
        ]
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: DataProviderConstants.sectionNameKeyPath,
            cacheName: nil)
        
        do {
            try fetchedResultController.performFetch()
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
        return fetchedResultController
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func changePinnedCategory(trackerIndexPath indexPath: IndexPath, category: TrackerCategoryCoreData?, isPinned: Bool, idCategory: String?) {
        let object = fetchedResultsController.object(at: indexPath)
        
        do {
            try trackerStore.changeTrackerCategory(object.objectID, category: category, isPinned: isPinned, idCadegory: idCategory)
            try fetchedResultsController.performFetch()
            
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func checkDate(from trackerCoreData: TrackerCoreData, with date: Date) -> Bool {
        var completed = false
        guard let date = date.getShortDate,
              let records =  trackerCoreData.records else { return completed }
        
        for record in records {
            if let record = record as? TrackerRecordCoreData,
               let checkDate = record.date {
                completed = checkDate == date
                break
            }
        }
        
        return completed
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
        
        guard let date = date.getShortDate as? NSDate else { return }
        
        switch showTrackers {
        case .isCompleted:
            let completedPredicate = NSPredicate(format: "records.date CONTAINS[cd] %@", date)
            predicates.append(completedPredicate)
        case .isNotCompleted:
            let notCompletedPredicate = NSPredicate(format: "NOT (records.date CONTAINS[cd] %@)", date)
            predicates.append(notCompletedPredicate)
        case .isAllTrackers:
            break
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        try? fetchedResultsController.performFetch()
        delegate?.didUpdate()
    }
    
    func getCompletedDayCount(at indexPath: IndexPath) -> Int {
        fetchedResultsController.object(at: indexPath).records?.count ?? 0
    }
    
    func getCompletedDay(currentDay: Date, at indexPath: IndexPath) -> Bool {
        let currentTrackerCoreData = fetchedResultsController.object(at: indexPath)
        guard let date = currentDay.getShortDate, let records = currentTrackerCoreData.records else { return false }
        for record in records {
            if let checkDate = (record as? TrackerRecordCoreData)?.date,
               checkDate == date {
                return true
            }
        }
        return false
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
    
    func checkPerfectDay(forDate date: Date) {
        guard let date = date.getShortDate,
              let totalTrackerPerDay = fetchedResultsController.fetchedObjects?.count
        else { return }
        let completedTrackers = trackerRecordStore.countCompletedTrackersFor(date: date)
        
        if totalTrackerPerDay == completedTrackers, totalTrackerPerDay != 0 {
            guard !perfectDaysStorage.perfectDays.contains(date) else { return }
            perfectDaysStorage.perfectDay(type: .add, at: date)
        } else {
            guard perfectDaysStorage.perfectDays.contains(date) else { return }
            perfectDaysStorage.perfectDay(type: .delete, at: date)
        }
    }
}

extension DataProvider: DataProviderStatisticProtocol {
    var bestPeriod: Int {
        // если нет идеальных дней, значит нет идеального периода
        guard !perfectDaysStorage.perfectDays.isEmpty else { return 0 }
        let bestDays = perfectDaysStorage.perfectDays
        var index = 0
        var nextIndex = 1
        
        // если bestDays не пустой значит есть один идеальный день, значит лучший период 1 день
        var bestPeriod = 1
       
        // если период обрывается записываю сюда сколько этот период длился
        var bestPeriods: [Int] = []
        
        while index < bestDays.count {
            if nextIndex >= bestDays.count { break }
            let day = bestDays[index]
            let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: day)
        
            if nextDay == bestDays[nextIndex] {
                bestPeriod += 1
            } else {
                bestPeriods.append(bestPeriod)
                bestPeriod = 1
            }
            
            index += 1
            nextIndex += 1
        }
        
        bestPeriods.append(bestPeriod)
        let sortBestPeriods = bestPeriods.sorted(by: >)
        return sortBestPeriods.first ?? 0
    }
    
    var perfectDays: Int {
        perfectDaysStorage.perfectDays.count
    }
    
    func averageValueCompletedTrackers(forDate date: Date?) -> Float {
        guard let date = date?.getShortDate else { return 0 }
        let completedTrackers = trackerRecordStore.countCompletedTrackersFor(date: date)
        guard let totalTrackerPerDay = fetchedResultsController.fetchedObjects?.count else { return 0 }
        return Float(completedTrackers) / Float(totalTrackerPerDay) * 100
    }
    
    var completedTrackersAllTime: Int {
        trackerRecordStore.trackerRecordsCoreData.count
    }
    
    var isTrackersInCoreData: Bool {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: DataProviderConstants.entityName)
        let result = try? context.fetch(fetchRequest)
        guard let isEmpty = result?.isEmpty else { return false }
        return !isEmpty
    }
}
