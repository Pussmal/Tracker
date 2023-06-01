import Foundation

struct TrackerRecord: Hashable {
    let checkDate: String
}

extension TrackerRecord: Equatable {
    static func == (lrh: TrackerRecord, rhs: TrackerRecord) -> Bool {
       lrh.checkDate == rhs.checkDate ? true : false
    }
}
