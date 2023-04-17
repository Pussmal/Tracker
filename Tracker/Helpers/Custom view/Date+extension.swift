import Foundation

extension Date {
    func getDate(date: Date) -> Date {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
        let date = Calendar.current.date(from: dateComponents)
        return date ?? Date()
    }
}
