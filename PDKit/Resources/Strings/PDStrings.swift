//
//  Created by Juliya Smith on 6/4/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//


public class PlaceholderStrings {
    public static var NothingYet: String {
		NSLocalizedString("Nothing yet", comment: "On buttons with plenty of room")
	}
    public static var DotDotDot: String {
		NSLocalizedString("...", comment: "Instruction for empty patch")
	}
}


public class DayStrings {
	private static let comment = "The word 'today' displayed on a button."
	public static var today: String {
		NSLocalizedString("Today", comment: comment)
	}
	public static var yesterday: String {
		NSLocalizedString("Yesterday", comment: comment)
	}
	public static var tomorrow: String {
		NSLocalizedString("Tomorrow", comment: comment)
	}
}


public enum TodayKey: String {
	case nextHormoneSiteName = "nextEstroSiteName"
	case nextHormoneDate = "nextEstroDate"
	case nextPillToTake = "nextPillToTake"
	case nextPillTakeTime = "nextPillTakeTime"
}
