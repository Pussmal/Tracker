import XCTest
@testable import Tracker

final class DataProviderStub: DataProviderProtocol {
    var delegate: DataProviderDelegate?
    
    var numberOfSections: Int
    var isTrackersForSelectedDate: Bool
    var isTrackersInCoreData: Bool
    
    init() {
        numberOfSections = 1
        isTrackersForSelectedDate = false
        isTrackersInCoreData = true
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int { 1 }
    
    func getTracker(at indexPath: IndexPath) -> Tracker? {
       return Tracker(
        id: "ID",
        name: "Test tracker",
        color: .ypColorSelection1,
        emoji: "🤌🏽",
        schedule: ["0", "1", "2", "3", "4", "5", "6"],
        isHabit: false,
        isPinned: false,
        idCategory: nil
       )
    }
    
    func getSectionTitle(at section: Int) -> String? { "Test category" }
    func getCompletedDayCount(at indexPath: IndexPath) -> Int { 1 }
    func getCompletedDay(currentDay: Date, at indexPath: IndexPath) -> Bool { true }
    
    func getTrackersCategory(atTrackerIndexPath indexPath: IndexPath) -> TrackerCategoryCoreData? { nil }
    func loadTrackers(from date: Date, showTrackers: ShowTrackers, with filterString: String?) throws {}
    func checkTracker(trackerId: String?, completed: Bool, with date: Date) {}
    func saveTracker(_ tracker: Tracker, in categoryCoreData: TrackerCategoryCoreData) throws {}
    func resaveTracker(at indexPath: IndexPath, newTracker: Tracker, category: TrackerCategoryCoreData?) throws {}
    func deleteTracker(at indexPath: IndexPath) throws {}
    func pinned(tracker: PinnedTracker, pinned: Pinned) {}
    func checkPerfectDay(forDate date: Date) {}
}
