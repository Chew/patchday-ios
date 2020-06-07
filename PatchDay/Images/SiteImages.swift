//
//  SiteImages.swift
//  PDKit
//
//  Created by Juliya Smith on 6/3/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public class SiteImages: NSObject {

	override public var description: String { "Read-only app image static accessor." }

	// Placeholder
	static var placeholderPatch: UIImage { initImage("Add Patch") }
	static var placeholderInjection: UIImage { initImage("Add Injection") }
	static var placeholderGel: UIImage { initImage("Add Gel") }

	// Patch site images
	static var patchRightGlute: UIImage { initImage("Right Glute") }
	static var patchLeftGlute: UIImage { initImage("Left Glute") }
	static var patchRightAbdomen: UIImage { initImage("Right Abdomen") }
	static var patchLeftAbdomen: UIImage { initImage("Left Abdomen") }
	static var customPatch: UIImage { initImage("Custom Patch") }

	// Injection site images
	static var lnjectionLeftQuad: UIImage { initImage("Left Quad") }
	static var lnjectionRightQuad: UIImage { initImage("Right Quad") }
	static var lnjectionLeftGlute: UIImage { initImage("Left Injection Glute") }
	static var lnjectionGluteRight: UIImage { initImage("Right Injection Glute") }
	static var lnjectionLeftDelt: UIImage { initImage("Left Delt") }
	static var lnjectionRightDelt: UIImage { initImage("Right Delt") }
	static var customInjection: UIImage { initImage("Custom Injection") }

	// Gel images
	static var arms: UIImage { initImage("Arms") }

	static var patchImages: [UIImage] {
		[patchRightGlute, patchLeftGlute, patchRightAbdomen, patchLeftAbdomen, customPatch]
	}

	static var injectionImages: [UIImage] {
		[
			lnjectionRightQuad,
			lnjectionLeftQuad,
			lnjectionLeftGlute,
			lnjectionGluteRight,
			lnjectionLeftDelt,
			lnjectionRightDelt,
			customInjection
		]
	}

	static var gelImages: [UIImage] {
		[arms]
	}

	public static var all: [UIImage] {
		Array(patchImages + injectionImages + gelImages)
	}

	public class All {
		public static subscript(method: DeliveryMethod) -> [UIImage] {
			switch method {
				case .Patches: return patchImages
				case .Injections: return injectionImages
				case .Gel: return gelImages
			}
		}
	}

	private static var imageToSiteNameDict: [UIImage: SiteName] {
		[
			patchRightGlute: SiteStrings.rightGlute,
			patchLeftGlute: SiteStrings.leftGlute,
			patchRightAbdomen: SiteStrings.rightAbdomen,
			patchLeftAbdomen: SiteStrings.leftAbdomen,
			lnjectionGluteRight: SiteStrings.rightGlute,
			lnjectionLeftGlute: SiteStrings.leftGlute,
			lnjectionRightQuad: SiteStrings.rightQuad,
			lnjectionLeftQuad: SiteStrings.leftQuad,
			lnjectionRightDelt: SiteStrings.rightDelt,
			lnjectionLeftDelt: SiteStrings.leftDelt,
			arms: SiteStrings.arms
		]
	}

	private static var siteNameToPatchImageDict: [SiteName: UIImage] {
		[
			SiteStrings.rightGlute: patchRightGlute,
			SiteStrings.leftGlute: patchLeftGlute,
			SiteStrings.rightAbdomen: patchRightAbdomen,
			SiteStrings.leftAbdomen: patchLeftAbdomen
		]
	}

	private static var siteNameToInjectionImageDict: [SiteName: UIImage] {
		[
			SiteStrings.rightGlute: lnjectionGluteRight,
			SiteStrings.leftGlute: lnjectionLeftGlute,
			SiteStrings.leftDelt: lnjectionLeftDelt,
			SiteStrings.rightDelt: lnjectionRightDelt,
			SiteStrings.leftQuad: lnjectionLeftQuad,
			SiteStrings.rightQuad: lnjectionRightQuad
		]
	}

	private static var siteNameToGelImageDict: [SiteName: UIImage] {
		[SiteStrings.arms: arms]
	}

	private static func initImage(_ name: String) -> UIImage {
		guard let image = UIImage(named: name) else { return UIImage() }
		image.accessibilityIdentifier = name
		return image
	}

	static func isPlaceholder(_ img: UIImage) -> Bool {
		img == placeholderPatch || img == placeholderInjection
	}

	/// Converts patch image to SiteName a.k.a String
	static func getName(from image: UIImage) -> SiteName {
		imageToSiteNameDict[image] ?? SiteStrings.NewSite
	}

	static subscript(params: SiteImageDeterminationParameters) -> UIImage {
		provided(from: params) ?? custom(from: params) ?? placeholder(params)
	}

	private static func provided(from params: SiteImageDeterminationParameters) -> UIImage? {
		guard let siteName = params.imageId else { return nil }
		switch params.deliveryMethod {
			case .Patches: return siteNameToPatchImageDict[siteName]
			case .Injections: return siteNameToInjectionImageDict[siteName]
			case .Gel: return siteNameToGelImageDict[siteName]
		}
	}

	private static func custom(from params: SiteImageDeterminationParameters) -> UIImage? {
		guard let _ = params.imageId else { return nil }
		switch params.deliveryMethod {
			case .Patches: return customPatch
			case .Injections: return customInjection
			default: return nil
		}
	}

	private static func placeholder(_ params: SiteImageDeterminationParameters) -> UIImage {
		switch params.deliveryMethod {
			case .Patches: return placeholderPatch
			case .Injections: return placeholderInjection
			case .Gel: return placeholderGel
		}
	}
}
