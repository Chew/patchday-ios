//
//  HormoneRepository.swift
//  PatchData
//
//  Created by Juliya Smith on 12/24/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class HormoneStore: EntityStore, HormoneStoring {
    
    private let log = PDLog<HormoneStore>()

    func getStoredHormones(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> [Hormonal] {
        var hormones: [Hormonal] = []
        let hormoneDataEntries = entities.getStoredHormoneData(
            expiration: expiration, method: deliveryMethod
        )
        for hormoneData in hormoneDataEntries {
            let hormone = Hormone(hormoneData: hormoneData, interval: expiration, deliveryMethod: deliveryMethod)
            hormones.append(hormone)
        }
        return hormones
    }
    
    func createNewHormone(expiration: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) -> Hormonal? {
        if let newHormoneDataFromStore = entities.createNewHormone(expiration: expiration, method: deliveryMethod) {
            return Hormone(hormoneData: newHormoneDataFromStore, interval: expiration, deliveryMethod: deliveryMethod)
        }
        return nil
    }

    func delete(_ hormone: Hormonal) {
        entities.deleteHormoneData([CoreDataEntityAdapter.convertToHormoneStruct(hormone)])
    }

    func pushLocalChanges(_ hormones: [Hormonal], doSave: Bool=true) {
        if hormones.count == 0 {
            return
        }
        let hormoneData = hormones.map { h in CoreDataEntityAdapter.convertToHormoneStruct(h) }
        self.pushLocalChanges(hormoneData, doSave: doSave)
    }

    private func pushLocalChanges(_ hormoneData: [HormoneStruct], doSave: Bool) {
        entities.pushHormoneData(hormoneData, doSave: doSave)
    }
}
