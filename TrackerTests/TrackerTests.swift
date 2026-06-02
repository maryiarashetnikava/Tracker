import XCTest
import SnapshotTesting

@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackersViewControllerLight() {

        let trackerStore = TrackerStore(
            context: CoreDataStack.shared.context
        )

        let recordStore = TrackerRecordStore(
            context: CoreDataStack.shared.context
        )

        let vc = TrackersViewController(
            trackerStore: trackerStore,
            recordStore: recordStore
        )

        assertSnapshot(
            matching: vc,
            as: .image(
                on: .iPhone13,
                traits: UITraitCollection(
                    userInterfaceStyle: .light
                )
            )
        )
    }
    
    func testTrackersViewControllerDark() {

        let trackerStore = TrackerStore(
            context: CoreDataStack.shared.context
        )

        let recordStore = TrackerRecordStore(
            context: CoreDataStack.shared.context
        )

        let vc = TrackersViewController(
            trackerStore: trackerStore,
            recordStore: recordStore
        )

        assertSnapshot(
            matching: vc,
            as: .image(
                on: .iPhone13,
                traits: UITraitCollection(
                    userInterfaceStyle: .dark
                )
            )
        )
    }
}
