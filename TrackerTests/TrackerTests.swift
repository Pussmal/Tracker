import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewController() throws {
        let dataProvider = DataProviderStub()
        let vc = TrackersViewController(dataProvider: dataProvider)
            
        assertSnapshots(
            matching: vc,
            as: [.image(traits: .init(userInterfaceStyle: .light)) ])
        
        assertSnapshots(
            matching: vc,
            as: [.image(traits: .init(userInterfaceStyle: .dark)) ])
    }
}
