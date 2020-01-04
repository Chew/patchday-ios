//
//  HormoneSchedule.swift
//  PatchData
//
//  Created by Juliya Smith on 7/4/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public struct HormoneScheduleData {
    var deliveryMethod: DeliveryMethodUD
    var expirationInterval: ExpirationIntervalUD
}

public class HormoneSchedule: NSObject, HormoneScheduling {
    
    override public var description: String { "Schedule for hormones." }

    private let dataBroadcaster: HormoneDataBroadcasting
    private var store: HormoneStore
    private var state: PDState
    private let defaults: UserDefaultsStoring
    private var hormones: [Hormonal]

    private let log = PDLog<HormoneSchedule>()
    
    init(
        data: HormoneScheduleData,
        hormoneDataBroadcaster: HormoneDataBroadcasting,
        coreDataStack: CoreDataStackWrapper,
        state: PDState,
        defaults: UserDefaultsStoring
    ) {
        let store = HormoneStore(coreDataStack)
        self.store = store
        self.hormones = store.getStoredHormones(
            expiration: data.expirationInterval, deliveryMethod: data.deliveryMethod.value
        )
        self.dataBroadcaster = hormoneDataBroadcaster
        self.state = state
        self.defaults = defaults
        super.init()
        reset()
        sort()
        broadcastHormones()
    }

    public var count: Int { hormones.count }
    
    public var all: [Hormonal] { hormones }
    
    public var isEmpty: Bool { hormones.count == 0 || (hasNoDates && hasNoSites) }
    
    public var next: Hormonal? {
        sort()
        return hormones.tryGet(at: 0)
    }
    
    public var totalExpired: Int {
        hormones.reduce(0, {
            count, hormone in
            let c = hormone.isExpired ? 1 : 0
            return c + count
        })
    }

    @discardableResult public func insertNew() -> Hormonal? {
        let method = defaults.deliveryMethod.value
        let exp = defaults.expirationInterval
        if let hormone = store.createNewHormone(expiration: exp, deliveryMethod: method) {
            hormones.append(hormone)
            sort()
            return hormone
        }
        return nil
    }
    
    public func forEach(doThis: (Hormonal) -> ()) {
        hormones.forEach(doThis)
    }
    
    public func sort() {
        hormones.sort(by: HormoneComparator.lessThan)
    }

    @discardableResult public func reset() -> Int {
        if hormones.count == 0 {
            log.info("No stored hormones - resetting to default")
            return reset(completion: nil)
        }
        return hormones.count
    }

    @discardableResult public func reset(completion: (() -> ())?) -> Int {
        deleteAll()
        let method = defaults.deliveryMethod.value
        let quantity = KeyStorableHelper.defaultQuantity(for: method)
        for _ in 0..<quantity {
            insertNew()
        }
        if let comp = completion {
            comp()
        }
        saveAll()
        return hormones.count
    }

    public func delete(after i: Index) {
        let start = i >= -1 ? i + 1 : 0
        if count >= start {
            for _ in start..<count {
                if let hormone = hormones.popLast() {
                    store.delete(hormone)
                }
            }
        }
    }

    public func saveAll() {
        store.save(hormones)
    }
    
    public func deleteAll() {
        delete(after: -1)
    }

    public func at(_ index: Index) -> Hormonal? {
        hormones.tryGet(at: index)
    }

    public func get(by id: UUID) -> Hormonal? {
        hormones.first(where: { h in h.id == id })
    }

    public func set(for id: UUID, date: Date, site: Bodily) {
        if var hormone = get(by: id) {
            hormone.siteId = site.id
            hormone.date = date
            sort()
            saveFromDateAndSiteChange(hormone)
        }
    }

    public func set(at index: Index, date: Date, site: Bodily) {
        if var hormone = at(index) {
            hormone.siteId = site.id
            hormone.date = date
            sort()
            saveFromDateAndSiteChange(hormone)
        }
    }

    public func setSite(at index: Index, with site: Bodily) {
        if var hormone = at(index) {
            setSite(for: &hormone, with: site)
        }
    }

    public func setSite(for hormone: inout Hormonal, with site: Bodily) {
        hormone.siteId = site.id
        hormone.siteName = site.name
        store.save(hormone)
        state.bodilyChanged = true
        state.onlySiteChanged = true
        state.bodilyChanged = true
        broadcastHormones()
    }

    public func setDate(at index: Index, with date: Date) {
        if var hormone = at(index) {
            setDate(for: &hormone, with: date)
        }
    }

    public func setDate(for hormone: inout Hormonal, with date: Date) {
        hormone.date = date
        sort()
        store.save(hormone)
        broadcastHormones()
        state.onlySiteChanged = false
    }

    public func setBackUpSiteName(at index: Index, with name: String) {
        if var hormone = at(index) {
            hormone.siteNameBackUp = name
            store.save(hormone)
        }
    }

    public func firstIndexOf(_ hormone: Hormonal) -> Index? {
        hormones.firstIndex { (_ h: Hormonal) -> Bool in h.isEqualTo(hormone) }
    }

    public func isEmpty(fromThisIndexOnward: Index, lastIndex: Index) -> Bool {
        if fromThisIndexOnward <= lastIndex {
            for i in fromThisIndexOnward...lastIndex {
                if let mone = at(i), mone.isEmpty {
                    return false
                }
            }
        }
        return true
    }

    public func fillIn(newQuantity: Int) {
        for _ in count..<newQuantity {
            insertNew()
        }
    }
    
    // MARK: - Private
    
    private var hasNoDates: Bool {
        isEmpty || (hormones.filter { !$0.date.isDefault() }).count == 0
    }
    
    private var hasNoSites: Bool {
        isEmpty || (hormones.filter { $0.siteId != nil || $0.siteNameBackUp != nil }).count == 0
    }

    private func broadcastHormones() {
        dataBroadcaster.broadcast(nextHormone: next)
    }
    
    private func saveFromDateAndSiteChange(_ hormone: Hormonal) {
        store.save(hormone)
        broadcastHormones()
        state.onlySiteChanged = false
        state.bodilyChanged = true
    }
}
