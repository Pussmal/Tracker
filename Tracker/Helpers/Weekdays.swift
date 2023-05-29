enum WeekDays: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var day: (shortForm: String, numberDay: Int) {
        switch self {
        case .monday:
            return ("Пн", 0)
        case .tuesday:
            return ("Вт", 1)
        case .wednesday:
            return ("Ср", 2)
        case .thursday:
            return ("Чт", 3)
        case .friday:
            return ("Пт", 4)
        case .saturday:
            return ("Сб", 5)
        case .sunday:
            return ("Вс", 6)
        }
    }
}
