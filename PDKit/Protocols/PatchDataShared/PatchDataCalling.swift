//
//  PatchDataCalling.swift
//  PDKit
//
//  Created by Juliya Smith on 9/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PatchDataCalling: PDSaving {
    func createPill(named name: String) -> Swallowable?
    func createPills() -> [Swallowable]
}
