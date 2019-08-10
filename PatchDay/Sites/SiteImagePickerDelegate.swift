//
//  SiteImagePickerDelegate.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/12/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class SiteImagePickerDelegate: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let estrogenSchedule: EstrogenScheduling
    private let defaults: PDDefaultManaging
    private let state: PDStateManaging
    
    public var images: [UIImage]
    public var picker: UIPickerView
    public var imageView: UIImageView
    public var saveButton: UIBarButtonItem
    public var selectedSite: MOSite
    public var selectedImage: UIImage?
    
    convenience init(with picker: UIPickerView,
                     and imageView: UIImageView,
                     saveButton: UIBarButtonItem,
                     selectedSite: MOSite,
                     deliveryMethod: DeliveryMethod) {
        self.init(with: picker,
                  and: imageView,
                  saveButton: saveButton,
                  selectedSite: selectedSite,
                  deliveryMethod: deliveryMethod,
                  estrogneSchedule: patchData.sdk.estrogenSchedule,
                  defaults: patchData.sdk.defaults,
                  state: patchData.sdk.state)
    }
    
    init(with picker: UIPickerView,
         and imageView: UIImageView,
         saveButton: UIBarButtonItem,
         selectedSite: MOSite,
         deliveryMethod: DeliveryMethod,
         estrogenSchedule: EstrogenScheduling,
         defaults: PDDefaultManaging,
         state: PDStateManaging) {
        self.imageView = imageView
        self.images = PDImages.siteImages(theme: defaults.theme.value, deliveryMethod: deliveryMethod)
        self.picker = picker
        self.saveButton = saveButton
        self.selectedSite = selectedSite
        self.estrogenSchedule = estrogenSchedule
        self.defaults = defaults
        self.state = state
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return images.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 180
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let size = CGSize(width: 330.1375, height: 462.0)
        let img = ModiiImageResizer.resizeImage(images[row], targetSize: size)
        let imgView = (row < images.count) ? UIImageView(image: img) : UIView()
        return imgView
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < images.count && row >= 0 {
            selectedImage = images[row]
        }
    }
 
    public func openPicker(closure: @escaping () -> ()) {
        UIView.transition(with: picker as UIView,
                          duration: 0.4,
                          options: .transitionFlipFromTop,
                          animations: {
                            self.picker.isHidden = false;
                            self.imageView.isHidden = true
                          }
                        )
        closure()
        
        if selectedImage == nil {
            selectedImage = imageView.image
        }
        if let i = images.firstIndex(of: selectedImage!) {
            picker.selectRow(i, inComponent: 0, animated: false)
            state.siteChanged = true
            if let estros = selectedSite.estrogenRelationship {
                for estro in estros {
                    if let estro_i = estrogenSchedule.getIndex(for: estro as! MOEstrogen) {
                        patchData.state.indicesOfChangedDelivery.append(estro_i)
                    }
                }
            }
        }
    }
}
