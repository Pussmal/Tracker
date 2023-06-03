import Foundation

protocol StatisticProviderProtocol {
    var isTrackersInCoreData: Bool { get }
    var bestPeriod: Int { get }
    var perfectDays: Int { get }
    var completedTrackers: Int { get }
    var averageValue: Int { get }
    
}

final class StatisticProvider {
    
    private let dataProvider: DataProviderStatisticProtocol
    
    init(dataProvider: DataProviderStatisticProtocol) {
        self.dataProvider = dataProvider
    }
    
}

extension StatisticProvider: StatisticProviderProtocol {
    var bestPeriod: Int {
        6
    }
    
    var perfectDays: Int {
        2
    }
    
    var completedTrackers: Int {
        5
    }
    
    var averageValue: Int {
        4
    }
    
    var isTrackersInCoreData: Bool {
        dataProvider.isTrackersInCoreData
    }
}
