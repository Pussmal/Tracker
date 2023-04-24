import UIKit
import CoreData

final class TrackerStore: NSObject {
    
    private struct TrackerStoreConstants {
        static let entityName = "TrackerCoreData"
        static let categorySectionNameKeyPath = "category"
    }
    
    private let context: NSManagedObjectContext
    
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
}

extension TrackerStore: NSFetchedResultsControllerDelegate {}
