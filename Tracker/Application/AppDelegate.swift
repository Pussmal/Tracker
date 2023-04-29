import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {}
        }
        return container
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //TODO: удалить после реализации создания категории
        createdCategories()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.ypWhite
        appearance.titleTextAttributes = [.foregroundColor: UIColor.ypBlack ?? UIColor.black]
        UINavigationBarAppearance().titleTextAttributes = [.font: UIFont.ypMediumSize16]
        UINavigationBar.appearance().prefersLargeTitles = false
        UINavigationBar.appearance().backgroundColor = UIColor.ypWhite
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //TODO: удалить после реализации создания категории
    private func createdCategories() {
        let categoryIsLoaded = UserDefaults.standard.bool(forKey: "isLoaded")
        // создаем категории для хранения привычек
        if !categoryIsLoaded  {
            let categoryOne = TrackerCategoryCoreData(context: persistentContainer.viewContext)
            categoryOne.title = "Важное"
            let categoryTwo = TrackerCategoryCoreData(context: persistentContainer.viewContext)
            categoryTwo.title = "Спорт"
            saveContext()
            UserDefaults.standard.set(true, forKey: "isLoaded")
        }
    }
}

