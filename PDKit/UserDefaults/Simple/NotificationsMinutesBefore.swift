//
//  NotificationsMinutesBefore.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class NotificationsMinutesBeforeUD: SimpleUserDefault<Int>, IntKeyStorable {

    public convenience required init() { self.init(0) }
    public static var key = PDDefault.NotificationsMinutesBefore
}
