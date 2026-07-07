import XCTest
@testable import Grouted

@MainActor
final class GroutedTests: XCTestCase {

    func makeItem(_ tag: String) -> Job {
        Job(room: tag)
    }

    func testSeedDataBelowFreeLimit() {
        let seeded = Store.seedData()
        XCTAssertLessThan(seeded.count, Store.freeLimit)
    }

    func testAddIncreasesCount() {
        let store = Store()
        let before = store.items.count
        store.add(makeItem("Test Entry"))
        XCTAssertEqual(store.items.count, before + 1)
    }

    func testDeleteRemovesItem() {
        let store = Store()
        let item = makeItem("To Delete")
        store.add(item)
        store.delete(item)
        XCTAssertFalse(store.items.contains(where: { $0.id == item.id }))
    }

    func testCanAddMoreWhenBelowLimit() {
        let store = Store()
        XCTAssertTrue(store.canAddMore)
    }

    func testCanAddMoreFalseAtLimit() {
        let store = Store()
        while store.items.count < Store.freeLimit {
            store.add(makeItem("Filler"))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testUpdateModifiesItem() {
        let store = Store()
        var item = makeItem("Original")
        store.add(item)
        item.rating = 5
        store.update(item)
        XCTAssertEqual(store.items.first(where: { $0.id == item.id })?.rating, 5)
    }

    func testFreshInstallHasSeedData() {
        let store = Store()
        XCTAssertFalse(store.items.isEmpty)
    }
}
