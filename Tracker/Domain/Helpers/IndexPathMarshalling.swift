import Foundation

/// Класс отвечает за преобразование indexPath трекера в выбранной категории при создании или изменения для хранения и получения ее core data
final class IndexPathMarshalling {
    func stringFromArray(indexPath: IndexPath) -> String {
        let section = String(indexPath.section)
        let row = String(indexPath.row)
        let stringArray = [section, row]
        return stringArray.joined(separator: ",")
    }

    func arrayFromString(string: String) -> IndexPath? {
        let stringArray = string.components(separatedBy: ",")
        let section = Int(stringArray[0])
        let row = Int(stringArray[1])
        guard let section, let row else { return nil }
        return IndexPath(row: row, section: section)
    }
}
