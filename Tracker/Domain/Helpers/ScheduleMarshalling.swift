import Foundation

/// Класс отвечает за преобразование расписания для хранения и получения ее core data
final class ScheduleMarshalling {
    func stringFromArray(array: [String]) -> String {
        array.joined(separator: ",")
    }

    func arrayFromString(string: String) -> [String] {
        string.components(separatedBy: ",")
    }
}
