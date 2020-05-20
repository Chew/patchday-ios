//
//  ApplyHormoneNotificationActionHandling.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/7/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormoneNotificationActionHandling {
	
	/// Set for updating views after action handling.
	var updateViewsHook: (() -> Void)? { get set }

	/// A handler for an expired-hormone notification action for applying a hormone.
	func handleHormone(id: String)
}
