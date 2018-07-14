//
//  TodayViewController.swift
//  patchdayToday
//
//  Created by Juliya Smith on 6/19/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import NotificationCenter
import PDKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var nextEstrogenLabel: UILabel!
    
    @IBOutlet weak var estrogenSiteLabel: UILabel!
    @IBOutlet weak var estrogenDateLabel: UILabel!
    
    @IBOutlet weak var nextPillNameLabel: UILabel!
    @IBOutlet weak var nextPillTakeDateLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nextEstro = PDTodayDataController.getNextEstrogen()
        let nextPill = PDTodayDataController.getNextPill()
        
        nextEstrogenLabel.text = PDTodayDataController.usingPatches() ? NSLocalizedString("Change:", comment: "Short label on Today App") : NSLocalizedString("Inject:", comment: "Short label on Today App")
        if let n = nextEstro.siteName {
            estrogenSiteLabel.text = n
        }
        else {
            estrogenSiteLabel.text = PDStrings.PlaceholderStrings.dotdotdot
        }
        if let d = nextEstro.date {
            estrogenDateLabel.text = PDDateHelper.format(date: d, useWords: true)
        }
        else {
            estrogenDateLabel.text = PDStrings.PlaceholderStrings.dotdotdot
        }
        if let n = nextPill.name {
            nextPillNameLabel.text = n
        }
        else {
            nextPillNameLabel.text = PDStrings.PlaceholderStrings.dotdotdot
        }
        if let d = nextPill.nextTakeDate {
            nextPillTakeDateLabel.text = PDDateHelper.format(date: d, useWords: true)
        }
        else {
            nextPillTakeDateLabel.text = PDStrings.PlaceholderStrings.dotdotdot
        }
     
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
    }
    
}
