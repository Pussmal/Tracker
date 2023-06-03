import Foundation

protocol StatisticProviderProtocol {
    var isTrackersInCoreData: Bool { get }
}

final class StatisticProvider {
    
    private let dataProvider: DataProviderStatisticProtocol
    
    init(dataProvider: DataProviderStatisticProtocol) {
        self.dataProvider = dataProvider
    }
    
}

extension StatisticProvider: StatisticProviderProtocol {
    var isTrackersInCoreData: Bool {
        dataProvider.isTrackersInCoreData
    }
}
