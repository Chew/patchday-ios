//
//  PillCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/25/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class PillCell: UITableViewCell {
    
    public var index: Index = -1

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var stateImageButton: MFBadgeButton!
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var lastTakenLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
    @IBOutlet weak var imageViewView: UIView!
    
    public func load() {
        if let pill = patchData.pillSchedule.getPill(at: index) {
            nameLabel.text = pill.getName()
            loadStateImage(from: pill)
            stateImageButton.type = .pills
            loadLastTakenText(from: pill)
            loadDueDateText(from: pill)
            takeButton.setTitleColor(UIColor.lightGray, for: .disabled)
            stateImageButton.restorationIdentifier = "i \(index)"
            takeButton.restorationIdentifier = "t \(index)"
            takeButton.isEnabled = (pill.isDone()) ? false : true
            enableOrDisableTake()
            setBackground()
            setBackgroundSelected()
            setImageBadge(using: pill)
            applyTheme()
        }
    }
    
    /// Set the "last taken" label to the curent date as a string.
    public func stamp() {
        lastTakenLabel.text = PDDateHelper.format(date: Date(), useWords: true)
    }
    
    public func loadDueDateText(from pill: MOPill) {
        if let dueDate = pill.due() {
            nextDueDate.text = PDDateHelper.format(date: dueDate, useWords: true)
        }
    }
    
    public func loadLastTakenText(from pill: MOPill) {
        if let lastTaken = pill.getLastTaken() {
            lastTakenLabel.text = PDDateHelper.format(date: lastTaken as Date, useWords: true)
        } else {
            lastTakenLabel.text = PDStrings.PlaceholderStrings.dotdotdot
        }
    }
    
    public func loadStateImage(from pill: MOPill) {
        stateImage.image = PDImages.pill
        if pill.isDone() {
            stateImage.tintColor = UIColor.lightGray
        } else {
            stateImage.tintColor = UIColor.blue
        }
    }
    
    public func enableOrDisableTake() {
        if stateImage.tintColor == UIColor.lightGray {
            // Disable
            takeButton.setTitle(PDStrings.ActionStrings.taken, for: .normal)
            takeButton.isEnabled = false
            stateImageButton.isEnabled = false
        } else {
            // Enable
            takeButton.setTitle(PDStrings.ActionStrings.take, for: .normal)
            takeButton.isEnabled = true
            stateImageButton.isEnabled = true
        }
    }
    
    public func setBackground() {
        imageViewView.backgroundColor = nil
        stateImageButton.backgroundColor = nil
        backgroundColor = appDelegate.themeManager.getCellColor(at: index)
    }
    
    // MARK: - Private
    
    private func setBackgroundSelected() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = PDColors.getColor(.Pink)
        selectedBackgroundView = backgroundView
    }
    
    private func setImageBadge(using pill: MOPill) {
        stateImageButton.badgeValue = (pill.isExpired()) ? "!" : nil
    }
    
    private func applyTheme() {
        nameLabel.textColor = appDelegate.themeManager.text_c
        takeButton.setTitleColor(appDelegate.themeManager.button_c, for: .normal)
        lastTakenLabel.textColor = appDelegate.themeManager.text_c
        nextDueDate.textColor = appDelegate.themeManager.text_c
        let img = stateImage.image?.withRenderingMode(.alwaysTemplate)
        stateImage.image = img
        stateImage.tintColor = appDelegate.themeManager.button_c
    }
}
