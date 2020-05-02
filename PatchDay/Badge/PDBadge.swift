//
//  PDBadge.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PDBadge: PDBadgeDelegate {

	private var badgeNumber = UIApplication.shared.applicationIconBadgeNumber

	func increment() {
		badgeNumber += 1
	}

	func decrement() {
        guard badgeNumber > 0 else { return }
        badgeNumber -= 1
	}

	func set(to newBadgeValue: Int) {
		badgeNumber = newBadgeValue
	}
}
