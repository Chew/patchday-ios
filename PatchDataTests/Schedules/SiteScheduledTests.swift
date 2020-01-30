//
//  SiteScheduledTests.swift
//  PatchDataTests
//
//  Created by Juliya Smith on 1/16/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchData


class SiteScheduleTests: XCTestCase {

    private var mockStore: MockSiteStore!
    private var mockDefaults: MockUserDefaultsWriter!
    private var sites: SiteSchedule!
    
    override func setUp() {
        mockStore = MockSiteStore()
        mockDefaults = MockUserDefaultsWriter()
    }
    
    override func tearDown() {
        mockStore.resetMock()
        mockDefaults.resetMock()
    }
    
    private func createMockOccupiedSite(hormoneCount: Int) -> MockSite {
        let site = MockSite()
        site.hormoneCount = hormoneCount
        var ids: [UUID] = []
        for _ in 0..<hormoneCount {
            ids.append(UUID())
        }
        site.hormoneIds = ids
        return site
    }
    
    private func createOccupiedSites(hormoneCounts: [Int]) -> [MockSite] {
        var sites: [MockSite] = []
        for count in hormoneCounts {
            sites.append(createMockOccupiedSite(hormoneCount: count))
        }
        return sites
    }
    
    private func createTestHormoneStructs(from mockSite: MockSite) -> [HormoneStruct] {
        var hormones: [HormoneStruct] = []
        for id in mockSite.hormoneIds {
            let hormone = createTestHormoneStruct(id)
            hormones.append(hormone)
        }
        return hormones
    }
    
    private func createTestHormoneStruct(_ id: UUID? = nil, _ date: Date? = nil) -> HormoneStruct {
        var hormone = HormoneStruct(id ?? UUID())
        hormone.date = date ?? Date()
        return hormone
    }
    
    private func setUpRelatedHormonesFactory(sites: [MockSite], hormonesOptions: [[HormoneStruct]]) {
        let c = min(sites.count, hormonesOptions.count)
        mockStore.getRelatedHormonesFactory = {
            for i in 0..<c {
                if sites[i].id == $0 {
                    return hormonesOptions[i]
                }
            }
            return []
        }
    }
    
    // MARK: - Tests
    
    public func testSuggested_whenSitesCountIsZero_returnsNil() {
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults, resetWhenEmpty: false)
        XCTAssertNil(sites.suggested)
    }

    public func testSuggested_whenDefaultsSiteIndexIsUnoccupied_returnsSiteAtDefaultsSiteIndex() {
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        mockDefaults.siteIndex = SiteIndexUD(2)
        let expected = sites.at(2)!.id
        let actual = sites.suggested!.id
        XCTAssertEqual(expected, actual)
    }
     
    public func testSuggested_whenDefaultsSiteIndexIsOccupied_returnsNextSiteAfterIndexWithNoHormones() {
        let mockSites = [MockSite(), MockSite(), createMockOccupiedSite(hormoneCount: 2), MockSite()]
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        mockDefaults.siteIndex = SiteIndexUD(2)
        let expected = mockSites[3].id
        let actual = sites.suggested!.id
        XCTAssertEqual(expected, actual)
    }
     
    public func testSuggested_whenAllSitesAreOccupied_returnsSiteWithOldestHormoneDate() {
        let mockSites = createOccupiedSites(hormoneCounts: [2, 3, 1, 3])
        let oldestDate = Date(timeInterval: -100000, since: Date())
        mockStore.getStoredCollectionReturnValues = [mockSites]
        let hormonesOne = createTestHormoneStructs(from: mockSites[0])
        let hormonesTwo = createTestHormoneStructs(from: mockSites[1])
        let hormonesThree = createTestHormoneStructs(from: mockSites[2])
        
        // This hormone list contains the hormone with the oldest date at index 1
        // The site that is occpied by this list is located at index 3.
        let hormonesFour = [
            createTestHormoneStruct(mockSites[3].hormoneIds[0]),
            createTestHormoneStruct(mockSites[3].hormoneIds[1], oldestDate),
            createTestHormoneStruct(mockSites[3].hormoneIds[2])
        ]
        let hormonesOptions = [hormonesOne, hormonesTwo, hormonesThree, hormonesFour]
        setUpRelatedHormonesFactory(sites: mockSites, hormonesOptions:hormonesOptions)
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
         
        let expected = mockSites[3].id
        let actual = sites.suggested!.id
        XCTAssertEqual(expected, actual)
    }
    
    public func testNextIndex_whenSitesCountIsZero_returnsNegativeOne() {
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults, resetWhenEmpty: false)
        let expected = -1
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
    
    public func testNextIndex_whenDefaultsSiteIndexIsUnoccupied_returnsDefaultsSiteIndex() {
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        mockDefaults.siteIndex = SiteIndexUD(2)
        let expected = 2
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
    
    public func testNextIndex_whenDefaultsSiteIndexIsOccupied_returnsFirstSiteAfterDefaultsSiteIndexWithNoHormones() {
        let mockSites = [MockSite(), MockSite(), createMockOccupiedSite(hormoneCount: 2), MockSite()]
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        mockDefaults.siteIndex = SiteIndexUD(2)
        let expected = 3
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
    
    public func testNextIndex_whenAllSitesAreOccupied_returnsSiteIndexWithOldestHormoneDate() {
        let mockSites = createOccupiedSites(hormoneCounts: [2, 3, 1, 3])
        let oldestDate = Date(timeInterval: -100000, since: Date())
        mockStore.getStoredCollectionReturnValues = [mockSites]
        let hormonesOne = createTestHormoneStructs(from: mockSites[0])
        let hormonesTwo = createTestHormoneStructs(from: mockSites[1])
        let hormonesThree = createTestHormoneStructs(from: mockSites[2])
        
        // This hormone list contains the hormone with the oldest date at index 1
        // The site that is occpied by this list is located at index 3.
        let hormonesFour = [
            createTestHormoneStruct(mockSites[3].hormoneIds[0]),
            createTestHormoneStruct(mockSites[3].hormoneIds[1], oldestDate),
            createTestHormoneStruct(mockSites[3].hormoneIds[2])
        ]
        let hormonesOptions = [hormonesOne, hormonesTwo, hormonesThree, hormonesFour]
        setUpRelatedHormonesFactory(sites: mockSites, hormonesOptions:hormonesOptions)
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        
        let expected = 3
        let actual = sites.nextIndex
        XCTAssertEqual(expected, actual)
    }
    
    public func testIsDefault_whenSiteCountIsZero_returnsFalse() {
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults, resetWhenEmpty: false)
        XCTAssertFalse(sites.isDefault)
    }
    
    public func testIsDefault_whenIsDefault_returnsTrue() {
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        XCTAssertTrue(sites.isDefault)
    }
    
    public func testIsDefault_whenIsNotDefault_returnsFalse() {
        let mockSites = createOccupiedSites(hormoneCounts: [2, 3, 1, 3])
        mockStore.getStoredCollectionReturnValues = [mockSites]
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        XCTAssertFalse(sites.isDefault)
    }
    
    public func testInsertNew_callsSiteStoreCreateNewSiteWithExpectedArgs() {
        mockDefaults.deliveryMethod = DeliveryMethodUD(.Injections)
        mockDefaults.expirationInterval = ExpirationIntervalUD(.OnceAWeek)
        let testSite = MockSite()
        mockStore.newObjectFactory = { testSite }
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults, resetWhenEmpty: false)
        sites.insertNew(name: "Doesn't matter", save: true, onSuccess: nil)
        let args = mockStore.createNewSiteCallArgs[0]
        
        XCTAssert(
            ExpirationInterval.OnceAWeek == args.0.value
                && DeliveryMethod.Injections == args.1
                && true
        )
    }
    
    public func testInsertNew_whenSuccessful_increaseCount() {
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)  // starts with 4 sites
        sites.insertNew(name: "Doesn't matter", save: false, onSuccess: nil)
        let expected = 5
        let actual = sites.count
        XCTAssertEqual(expected, actual)
    }
    
    public func testInsertNew_whenSuccessful_insertsSiteWithGivenName() {
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        sites.insertNew(name: "Ok, now it matters I guess", save: false, onSuccess: nil)
        XCTAssert(sites.all.contains(where: { $0.name == "Ok, now it matters I guess" }))
    }
    
    public func testInsertNew_whenSuccessful_returnsNewlyInsertedSite() {
        let expected = MockSite()
        mockStore.newObjectFactory = { expected }
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        let actual = sites.insertNew(name: "Doesn't matter again.", save: false, onSuccess: nil)
        XCTAssertEqual(expected.id, actual!.id)
    }
    
    public func testInsertNew_whenSuccessful_callsOnSuccess() {
        var called = false
        let testClosure = { called = true }
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        sites.insertNew(name: "Doesn't matter", save: false, onSuccess: testClosure)
        XCTAssert(called)
    }
    
    public func testInsertNew_whenUnsuccessful_doesNotAffectCount() {
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)  // starts with 4 sites
        mockStore.newObjectFactory = nil
        sites.insertNew(name: "Doesn't matter", save: false, onSuccess: nil)
        let expected = 4
        let actual = sites.count
        XCTAssertEqual(expected, actual)
    }
    
    public func testInsertNew_whenUnsuccessful_returnsNil() {
        mockStore.newObjectFactory = nil
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        sites.insertNew(name: "Doesn't matter", save: false, onSuccess: nil)
        XCTAssertNil(sites.insertNew(name: "Doesn't matter again.", save: false, onSuccess: nil))
    }
    
    public func testInsertNew_whenUnsuccessful_doesNotCallOnSuccess() {
        mockStore.newObjectFactory = nil
        var called = false
        let testClosure = { called = true }
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        sites.insertNew(name: "Doesn't matter", save: false, onSuccess: testClosure)
        XCTAssertFalse(called)
    }
    
    public func testReset_whenAlreadyDefault_returnsSameCount() {
        let expected = sites.count
        sites = SiteSchedule(store: mockStore, defaults: mockDefaults)
        sites.reset()
        let actual = sites.count
        XCTAssertEqual(expected, actual)
    }
}
