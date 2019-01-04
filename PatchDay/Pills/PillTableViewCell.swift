//
//  PillTableViewCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/25/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class PillTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var stateImageButton: MFBadgeButton!
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var lastTakenLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
    @IBOutlet weak var imageViewView: UIView!
    
    public func configure(using pill: MOPill, at index: Index) {
        let indexStr = String(index)
        
        nameLabel.text = pill.getName()
        loadStateImage(from: pill)
        stateImageButton.type = .pills
        loadLastTakenText(from: pill)
        loadDueDateText(from: pill)
        takeButton.setTitleColor(UIColor.lightGray, for: .disabled)
        stateImageButton.restorationIdentifier = "i" + indexStr
        takeButton.restorationIdentifier = "t" + indexStr
        takeButton.isEnabled = (pill.isDone()) ? false : true
        enableOrDisableTake()
        setBackground(at: index)
        setBackgroundSelected()
        setImageBadge(using: pill)

    }
    
    /// Set the "last taken" label to the curent date as a string.
    public func stamp() {
        lastTakenLabel.text = PDDateHelper.format(date: Date(), useWords: true)
    }
    
    public func loadDueDateText(from pill: MOPill) {
        if let dueDate = pill.getDueDate() {
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
        stateImage.image = PDImages.pill.withRenderingMode(.alwaysTemplate)
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
    
    // MARK: - Private
    
    private func setBackground(at index: Index) {
        if index % 2 == 0 {
            backgroundColor = PDColors.pdLightBlue
            imageViewView.backgroundColor = nil
            stateImageButton.backgroundColor = nil
        }
    }
    
    private func setBackgroundSelected() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = PDColors.pdPink
        selectedBackgroundView = backgroundView
    }
    
    private func setImageBadge(using pill: MOPill) {
        stateImageButton.badgeValue = (pill.isExpired()) ? "!" : nil
    }
}
