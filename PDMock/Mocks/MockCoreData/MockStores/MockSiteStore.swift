//
//  MockSiteStore.swift
//  PDMock
//
//  Created by Juliya Smith on 1/16/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class MockSiteStore: MockPatchDataStore<Bodily>, SiteStoring {
    
    public var getRelatedHormonesCallArgs: [UUID] = []
    public var getRelatedHormonesFactory: ((UUID) -> [HormoneStruct])?

    public override init() {
        super.init()
        newObjectFactory = { () in MockSite() }
    }
    
    public override func resetMock() {
        super.resetMock()
        getRelatedHormonesCallArgs = []
        getRelatedHormonesFactory = nil
    }

    public func getStoredSites(expiration: ExpirationIntervalUD, method: DeliveryMethod) -> [Bodily] {
        getNextMockStoredObjects()
    }
    
    public func createNewSite(expiration: ExpirationIntervalUD, method: DeliveryMethod, doSave: Bool) -> Bodily? {
        newObjectFactory?()
    }
    
    public func getRelatedHormones(_ siteId: UUID) -> [HormoneStruct] {
        getRelatedHormonesFactory?(siteId) ?? []
    }
    
    public func delete(_ site: Bodily) {
        deleteCallArgs.append(site)
    }
    
    public func pushLocalChangesToManagedContext(_ sites: [Bodily], doSave: Bool) {
        pushLocalChangesCallArgs.append((sites, doSave))
    }
}
