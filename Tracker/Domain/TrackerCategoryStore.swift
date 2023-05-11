import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    private enum TrackerCategoryStoreError: Error {
        case errorDecodingTitle
        case errorDecodingId
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    func creatTrackerCategory(from trackerCategoryCoreData:  TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.title else { throw TrackerCategoryStoreError.errorDecodingTitle }
        return TrackerCategory(title: title )
    }
    
    func addTrackerCategoryCoreData(from trackerCategory: TrackerCategory) -> TrackerCategoryCoreData {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = trackerCategory.title
        saveContext()
        return trackerCategoryCoreData
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

extension TrackerCategoryStore:  NSFetchedResultsControllerDelegate {}
