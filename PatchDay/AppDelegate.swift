//
//  AppDelegate.swift
//  test
//
//  Created by Juliya Smith on 5/9/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import UserNotifications
import PDKit
import PatchData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var notifications: NotificationScheduling?
    var sdk: PatchDataSDK = PatchData()
    var alerts: AlertDispatching?
    var tabs: TabReflective?
    var nav: NavigationHandling = Navigation()
    var badge: PDBadgeDelegate = PDBadge()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.notifications = Notifications(sdk: sdk, appBadge: badge)
        self.alerts = AlertDispatcher(sdk: sdk)
        self.setBadgeToTotalAlerts()
        return true
    }
    
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static var current: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }

    func applicationWillTerminate(_ application: UIApplication) {
        setBadgeToTotalAlerts()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        setBadgeToTotalAlerts()
    }

    /// Sets the App badge number to the expired count + the total pills due for taking.
    private func setBadgeToTotalAlerts() {
        badge.set(to: sdk.totalAlerts)
    }
}
