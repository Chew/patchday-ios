//
//  SiteSchedule.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit


public class SiteSchedule: NSObject, HormoneSiteScheduling {

    override public var description: String { "Schedule for sites." }
    private var resetWhenEmpty: Bool
    
    private let store: SiteStoring
    private let defaults: UserDefaultsWriting
    private var sites: [Bodily]

    let log = PDLog<SiteSchedule>()
    
    init(store: SiteStoring, defaults: UserDefaultsWriting, resetWhenEmpty: Bool = true) {
        self.store = store
        self.defaults = defaults
        self.resetWhenEmpty = resetWhenEmpty
        let exp = defaults.expirationInterval
        let method = defaults.deliveryMethod.value
        self.sites = store.getStoredSites(expiration: exp, method: method)
        super.init()
        handleSiteCount()
        sort()
    }
    
    public var count: Int { sites.count }
    
    public var all: [Bodily] { sites }

    public var suggested: Bodily? {
        guard count > 0 else { return nil }
        if let trySite = siteIndexSuggested {
            return trySite
        } else if let trySite = firstEmptyFromSiteIndex {
            return trySite
        }
        return siteWithOldestHormone
    }
    
    public var nextIndex: Index {
        sites.firstIndex(where: { b in
            if let suggestedSite = suggested {
                return suggestedSite.id == b.id
            }
            return false
        }) ?? -1
    }
    
    public var occupiedSites: [Bodily] {
        var occupiedList: [Bodily] = []
        for site in sites {
            if site.isOccupied {
                occupiedList.append(site)
            }
        }
        return occupiedList
    }
    
    public var occupiedSitesIndices: [Index] {
        var indices: [Index] = []
        for site in occupiedSites {
            if let i = firstIndexOf(site) {
                indices.append(i)
            }
        }
        return indices
    }

    public var names: [SiteName] {
        sites.map({ (site: Bodily) -> SiteName in site.name })
    }

    public var imageIds: [String] {
        sites.map({ (site: Bodily) -> String in site.imageId })
    }

    public var unionWithDefaults: [SiteName] {
        let method = defaults.deliveryMethod.value
        return Array(Set<String>(SiteStrings.getSiteNames(for: method)).union(names))
    }

    public var isDefault: Bool {
        let method = defaults.deliveryMethod.value
        let defaultSites = SiteStrings.getSiteNames(for: method)
        for i in 0..<sites.count {
            if !defaultSites.contains(sites[i].name) {
                return false
            }
        }
        return false  // if there are no sites, than it is not default
    }
    
    @discardableResult
    public func insertNew(save: Bool) -> Bodily? {
        if let site = createSite(save: save) {
            sites.append(site)
            return site
        }
        return nil
    }

    @discardableResult
    public func insertNew(save: Bool, completion: @escaping () -> ()) -> Bodily? {
        let site = insertNew(save: save)
        completion()
        return site
    }

    @discardableResult
    public func insertNew(name: String, save: Bool) -> Bodily? {
        var site = insertNew(save: save)
        site?.name = name
        return site
    }

    @discardableResult
    public func insertNew(name: String, save: Bool, completion: @escaping () -> ()) -> Bodily? {
        let site = insertNew(name: name, save: save)
        completion()
        return site
    }

    @discardableResult
    public func reset() -> Int {
        if isDefault {
            return handleDefaultStateDuringReset()
        }
        resetSitesToDefault()
        store.pushLocalChangesToManagedContext(sites, doSave: true)
        return sites.count
    }

    public func delete(at index: Index) {
        if let site = at(index) {
            log.info("Deleting site at index \(index)")
            store.delete(site)
            let start = index + 1
            let end = count - 1
            if start < end {
                for i in start...end {
                    sites[i].order -= 1
                }
            }
            sort()
        }
    }
    
    public func sort() {
        sites.sort(by: SiteComparator.lessThan)
    }

    public func at(_ index: Index) -> Bodily? {
        sites.tryGet(at: index)
    }

    public func get(by id: UUID) -> Bodily? {
        sites.first(where: { s in s.id == id })
    }

    public func getName(by id: UUID) -> SiteName? {
        get(by: id)?.name
    }

    public func rename(at index: Index, to name: SiteName) {
        if var site = at(index) {
            site.name = name
            store.pushLocalChangesToManagedContext([site], doSave: true)
        }
    }

    public func reorder(at index: Index, to newOrder: Int) {
        if var site = at(index) {
            if var originalSiteAtOrder = at(newOrder) {
                // Make sure index is correct both before and after swap
                sort()
                site.order = newOrder
                originalSiteAtOrder.order = index + 1
                sort()
                store.pushLocalChangesToManagedContext([originalSiteAtOrder], doSave: true)
            } else {
                site.order = newOrder
            }
        }
    }

    public func setImageId(at index: Index, to newId: String) {
        var siteSet: [String]
        let method = defaults.deliveryMethod.value
        siteSet = SiteStrings.getSiteNames(for: method)
        if var site = at(index) {
            if siteSet.contains(newId) {
                site.imageId = newId
            } else {
                sites[index].imageId = SiteStrings.CustomSiteId
            }
            store.pushLocalChangesToManagedContext([site], doSave: true)
        }
    }
    
    public func firstIndexOf(_ site: Bodily) -> Index? {
        sites.firstIndex { (_ s: Bodily) -> Bool in s.isEqualTo(site) }
    }

    @discardableResult
    private func updateIndex() -> Index {
        defaults.replaceStoredSiteIndex(to: nextIndex, siteCount: count)
    }
    
    @discardableResult
    private func updateIndex(to newIndex: Index) -> Index {
        defaults.replaceStoredSiteIndex(to: newIndex, siteCount: count)
    }
    
    private var siteIndexSuggested: Bodily? {
        if let site = at(defaults.siteIndex.value), site.hormoneCount == 0 {
            return site
        }
        return nil
    }

    private var firstEmptyFromSiteIndex: Bodily? {
        var siteIterator = defaults.siteIndex.value
        for _ in 0..<count {
            if let site = at(siteIterator), site.hormoneCount == 0 {
                return site
            }
            siteIterator = (siteIterator + 1) % count
        }
        return nil
    }

    private var siteWithOldestHormone: Bodily? {
        sites.reduce((oldestDate: Date(), oldest: nil, iterator: 0), {
            (sitesIterator, site) in
            let oldestDateInThisSitesHormones = getOldestHormoneDate(from: site.id)
            if oldestDateInThisSitesHormones < sitesIterator.oldestDate, let site = at(sitesIterator.2) {
                return (oldestDateInThisSitesHormones, site, sitesIterator.2 + 1)
            }
            return (sitesIterator.0, sitesIterator.1, sitesIterator.2 + 1)
        }).1
    }

    private func getOldestHormoneDate(from siteId: UUID) -> Date {
        HormoneSchedule.getOldestHormoneDate(from: store.getRelatedHormones(siteId))
    }
    
    private func createSite(save: Bool) -> Bodily? {
        let exp = defaults.expirationInterval
        let method = defaults.deliveryMethod.value
        return store.createNewSite(expiration: exp, method: method, doSave: save)
    }

    private func handleSiteCount() {
        if resetWhenEmpty && sites.count == 0 {
            log.info("No stored sites - resetting to default")
            reset()
            logSites()
        }
    }

    @discardableResult
    private func handleDefaultStateDuringReset() -> Int {
        log.warn("Resetting sites unnecessary because already default")
        return sites.count
    }

    private func resetSitesToDefault() {
        let defaultSiteNames = SiteStrings.getSiteNames(for: defaults.deliveryMethod.value)
        let previousCount = sites.count
        assignDefaultSiteProperties(options: defaultSiteNames, previousCount: previousCount)
        handleExtraSitesFromReset(previousCount: previousCount, defaultSiteNamesCount: defaultSiteNames.count)
    }

    private func assignDefaultSiteProperties(options: [String], previousCount: Int) {
        for i in 0..<options.count {
            if i < previousCount {
                log.info("Assigning existing site default properties")
                setSite(&sites[i], index: i, name: options[i])
            } else if var site = insertNew(save: false) {
                setSite(&site, index: i, name: options[i])
            }
        }
    }

    private func setSite(_ site: inout Bodily, index: Index, name: String) {
        site.order = index
        site.name = name
        site.imageId = name
    }

    private func handleExtraSitesFromReset(previousCount: Int, defaultSiteNamesCount: Int) {
        if previousCount > defaultSiteNamesCount {
            resetSites(start: defaultSiteNamesCount, end: previousCount - 1)
        }
    }

    private func resetSites(start: Index, end: Index) {
        for i in start...end {
            sites[i].reset()
        }
    }

    private func logSites() {
        var sitesDescription = "The Site Schedule contains:"
        for site in sites {
            sitesDescription.append("\nSite. Id=\(site.id), Order=\(site.order), Name=\(site.name)")
        }
        if sitesDescription.last != ":" {
            log.info(sitesDescription)
        }
    }
}
