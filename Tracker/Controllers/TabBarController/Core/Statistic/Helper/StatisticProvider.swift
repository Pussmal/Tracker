import Foundation

protocol StatisticProviderProtocol {
    var isTrackersInCoreData: Bool { get }
    var bestPeriod: Int { get }
    var perfectDays: Int { get }
    var completedTrackers: Int { get }
    var averageValue: Float { get }
    
}

final class StatisticProvider {
    private let dataProvider: DataProviderStatisticProtocol
    private var currentDay: Date?
    
    private var imageListServiceObserver: NSObjectProtocol?
    
    init(dataProvider: DataProviderStatisticProtocol, currentDay: Date?) {
        self.currentDay = currentDay
        self.dataProvider = dataProvider
        configNotification()
    }
    
    private func configNotification() {
        imageListServiceObserver = NotificationCenter.default
            .addObserver(forName: TrackersViewController.didChangeNotification,
                         object: nil,
                         queue: .main,
                         using: { [weak self] notification in
                guard let self = self else { return }
                self.currentDay = notification.userInfo?["date"] as? Date
            })
    }
}

extension StatisticProvider: StatisticProviderProtocol {
    var bestPeriod: Int {
        0
    }
    
    var perfectDays: Int {
        0
    }
    
    var completedTrackers: Int {
        dataProvider.completedTrackersAllTime
    }
    
    var averageValue: Float {
        dataProvider.averageValueCompletedTrackers(forDate: currentDay)
    }
    
    var isTrackersInCoreData: Bool {
        dataProvider.isTrackersInCoreData
    }
}
