//
//  PDPillSwallowHandling.swift
//  PDKit
//
//  Created by Juliya Smith on 10/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol SwallowPillNotificationActionHandling {
    
    /// A handler for a due-pill notification action for swallowing a pill.
    func swallow(pillUid: String)
}
