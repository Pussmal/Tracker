import UIKit
import CoreData

struct DataProviderUpdate {
    let insertedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate()
}

protocol DataProviderProtocol {
    var delegate: DataProviderDelegate? { get set }
    var numberOfSections: Int { get }
    var isTrackersForSelectedDate: Bool { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func getTracker(at indexPath: IndexPath) -> Tracker?
    func getSectionTitle(at secrion: Int) -> String?
   
    func loadTrackers(from date: Date, with filterString: String?) throws
    
   
    
    func saveTracker(_ tracker: Tracker) throws
    func saveTrackerCategory(_ category: TrackerCategory) throws
}

final class DataProvider: NSObject {
    
    weak var delegate: DataProviderDelegate?
    
    private struct DataProviderConstants {
        static let entityName = "TrackerCoreData"
        static let sectionNameKeyPath = "category"
    }
    
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    
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

    func loadTrackers(from date: Date, with filterString: String?) throws {
        let currentDayWeek = Date.getStringWeekday(from: date)
        var predicates: [NSPredicate] = []
        
        let weekdayPredicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), currentDayWeek)
        predicates.append(weekdayPredicate)
        
        if let filterString {
            let filterPredicate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.name), filterString)
            predicates.append(filterPredicate)
        }
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        try? fetchedResultsController.performFetch()
        delegate?.didUpdate()
    }
        
    func saveTrackerCategory(_ category: TrackerCategory) throws {
        // trackerCategoryStore.addTrackerCategoryCoreData(from: category)
    }
    
    func saveTracker(_ tracker: Tracker) throws {
        
        // по заданию пока категории не реализовываем, поэтому все привычки сохраняю в одну рандомную категорию
        
        let fetchRequestCategory = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        guard let trackerCategoryCoreData = try? context.fetch(fetchRequestCategory).randomElement() else { return }
        trackerStore.addNewTracker(tracker, with: trackerCategoryCoreData)
    }
}

extension DataProvider: NSFetchedResultsControllerDelegate {} 


