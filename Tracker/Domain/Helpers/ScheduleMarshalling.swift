import Foundation

/// Класс отвечает за преобразование расписания для хранения и получения ее core data
final class ScheduleMarshalling {
    
    func stringFromArray(array: [String]) -> String {
        return array.joined(separator: ",")
    }

    func arrayFromString(string: String) -> [String] {
        return string.components(separatedBy: ",")
    }
}
