//
//  PDBadgeDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/9/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDBadgeDelegate {
	var value: Int { get }
	func clear()
	func reflect()
}
