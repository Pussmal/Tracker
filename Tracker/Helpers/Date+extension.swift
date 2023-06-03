import Foundation

extension Date {
    var getShortDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        let date = dateFormatter.string(from: self)
        return dateFormatter.date(from: date)
    }
    
    static func getCurrentDayStringIndex(at date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let currentDayWeek = dateFormatter.string(from: date)
        let numberOfDay = Calendar.current.shortWeekdaySymbols
        var currentNumberOfDay = ""
    
        for (index, shortSymbols) in numberOfDay.enumerated() {
            if currentDayWeek == shortSymbols {
                //Мне нужно чтобы у текущего дня был индекс на один меньше, так как первый день понедельник с индексом 0
                var currentIndex = index - 1
                if currentIndex < 0 { currentIndex = 6 }
                currentNumberOfDay = String(currentIndex)
                break
            }
        }
        return currentNumberOfDay
    }
    
    var stringDateRecordFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: self)
    }
}
