import Foundation

enum FilterType: String, CaseIterable {
    case allTrackers
    case trackersForToday
    case completed
    case notCompleted
    
    var filterTitle: String {
        switch self {
        case .allTrackers:
            return NSLocalizedString("AllTrackers", comment: "")
        case .trackersForToday:
            return NSLocalizedString("TrackersForToday", comment: "")
        case .completed:
            return NSLocalizedString("Completed", comment: "")
        case .notCompleted:
            return NSLocalizedString("NotCompleted", comment: "")
        }
    }
}
