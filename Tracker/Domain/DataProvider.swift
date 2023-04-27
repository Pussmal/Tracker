import UIKit
import CoreData

struct DataProviderUpdate {
    let insertedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: DataProviderUpdate)
}

protocol DataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> TrackerCategory?
    func saveTracker(_ tracker: Tracker) throws
    func saveTrackerCategory(_ category: TrackerCategory) throws
}

final class DataProvider: NSObject {
    
    weak var delegate: DataProviderDelegate?
    
    private struct DataProviderConstants {
        static let entityName = "TrackerCategoryCoreData"
    }
    
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: DataProviderConstants.entityName)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
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
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TrackerCategory? {
        let object = fetchedResultsController.object(at: indexPath)
    
        do {
            return try trackerCategoryStore.creatTrackerCategory(from: object)
        } catch {
            assertionFailure("Error decoding TrackerCategory")
            return nil
        }
    }
    
    func saveTrackerCategory(_ category: TrackerCategory) throws {
       // trackerCategoryStore.addTrackerCategoryCoreData(from: category)
    }

    func saveTracker(_ tracker: Tracker) throws {
        
        // по заданию пока категории не реализовываем, поэтому все привычки сохраняю в одну категорию
        
        let fetchRequestCategory = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        guard let categories = try? context.fetch(fetchRequestCategory) else { return }
        trackerStore.addNewTracker(tracker, with: categories[0])
    }
}

extension DataProvider: NSFetchedResultsControllerDelegate {} 


