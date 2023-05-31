import UIKit

struct Tracker {
    let id: String
    let name: String
    let color: UIColor?
    let emoji: String
    let schedule: [String]?
    let isHabit: Bool
    let isPinned: Bool
    let idCategory: String?
    let indexPathInCategory: String?
}

extension Tracker: Equatable {
    static func == (lrh: Tracker, rhs: Tracker) -> Bool {
        lrh.id == rhs.id ? true : false
    }
}
