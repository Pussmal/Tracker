import Foundation

struct TrackerRecord: Hashable {
    let checkDate: Date
}

extension TrackerRecord: Equatable {
    static func == (lrh: TrackerRecord, rhs: TrackerRecord) -> Bool {
       lrh.checkDate == rhs.checkDate ? true : false
    }
}
