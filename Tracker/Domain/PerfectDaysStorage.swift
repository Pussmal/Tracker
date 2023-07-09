import Foundation

enum PerfectDaysStorageType {
    case add
    case delete
}

final class PerfectDaysStorage {
    // MARK: Singletone
    static let shared = PerfectDaysStorage()
    private init() {}
    
    // MARK: Private enum
    private enum Keys: String, CodingKey {
        case perfectDays = "PerfectDays"
    }
    
    // MARK: Private properties
    private let userDefaults = UserDefaults.standard
    
    // MARK: Public properties
    var perfectDays: [Date] {
        get { userDefaults.array(forKey: Keys.perfectDays.rawValue) as? [Date] ?? [Date]() }
        set { userDefaults.set(newValue, forKey: Keys.perfectDays.rawValue) }
    }
    
    func perfectDay(type: PerfectDaysStorageType, at date: Date) {
        switch type {
        case .add:
            addPerfectDay(date: date)
        case .delete:
            deletePerfectDay(date: date)
        }
    }
    
    private func addPerfectDay(date: Date) {
        let dateArray = userDefaults.array(forKey: Keys.perfectDays.rawValue) as? [Date] ?? [Date]()
        let newArray = (dateArray + [date]).sorted()
        userDefaults.set(newArray, forKey: Keys.perfectDays.rawValue)
    }
    
    private func deletePerfectDay(date: Date) {
        var dateArray = userDefaults.array(forKey: Keys.perfectDays.rawValue) as? [Date] ?? [Date]()
        guard let deleteIndex = dateArray.firstIndex(of: date) else { return }
        dateArray.remove(at: deleteIndex)
        userDefaults.set(dateArray, forKey: Keys.perfectDays.rawValue)
    }
}
