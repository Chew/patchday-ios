//
//  SiteImageHistoryManaging.swift
//  PDKit
//
//  Created by Juliya Smith on 11/4/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public protocol SiteImageHistorical {
    subscript(index: Index) -> SiteImageRecording { get }
}
