import Foundation

extension Date {
    var getDate: Date {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let date = Calendar.current.date(from: dateComponents)
        return date?.addingTimeInterval(24*3600) ?? Date()
    }
    
    static func getDayWeek(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let date = dateFormatter.string(from: date)
        return date
    }
}
