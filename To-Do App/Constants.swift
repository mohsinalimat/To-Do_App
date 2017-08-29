//
//  Constants.swift
//  To-Do App
//
//  Created by Wismin Effendi on 8/15/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import Foundation
import CoreLocation

public protocol CloudKitConvertible {
    var identifier: String { get }
    var pendingDeletion: Bool { get set }
    var needsUpload: Bool { get set }
}

public struct ModelName {
    public static let ToDo = "ToDoApp"
}

public struct CellIdentifier {
    public static let DueDateTaskCell = "DueDateTaskCell"
    public static let LocationTaskCell = "LocationTaskCell"
    public static let ArchivedTaskCell = "ArchivedTaskCell"
    public static let LocationName = "LocationName"
}

public struct NavBarTitle {
    public static let TaskByLocation = "Task by location"
    public static let TaskByDueDate = "Task by due date"
    public static let ArchivedTask = "Archived Task"
}

public enum TimeOrder: String {
    case today = "Today"
    case tomorrow = "Tomorrow"
    case yesterday = "Yesterday"
    case twoDaysAgo = "Two days ago"
    case twoDaysFromNow = "Two days from now"
    case futureDaysInThisWeek = "Future days in this week"
    case nextWeek = "Next Week"
    case twoWeeksFromNow = "Two weeks from now"
    case previousDaysInThisWeek = "Previous days in this week"
    case lastWeek = "Last Week"
    case twoWeeksAgo = "Two weeks ago"
    case sometimeInTheFuture = "Sometime in the future"
    case sometimeInThePast = "Sometime in the past"
    
    func ranking() -> Int {
        switch self {
        case .today:                    return 0
        case .tomorrow:                 return 1
        case .twoDaysFromNow:           return 2
        case .futureDaysInThisWeek:     return 3
        case .nextWeek:                 return 4
        case .twoWeeksFromNow:          return 5
        case .sometimeInTheFuture:      return 10
        case .yesterday:                return -1
        case .twoDaysAgo:               return -2
        case .previousDaysInThisWeek:   return -3
        case .lastWeek:                 return -4
        case .twoWeeksAgo:              return -5 
        case .sometimeInThePast:        return -10
        }
    }
}

public struct Constant {
    public static let toDoCategoryPerRow: CGFloat = 3
    public static let hardCodedPadding: CGFloat = 30.0
    public static let geofenceRadius: CLLocationDistance = 100 
}

public struct SegueIdentifier {
    public static let AddNewLocation = "AddNewLocation"
    public static let LocationList = "LocationList"
}

extension UserDefaults {
    public struct Keys {
        public static let mixpanelIdentity = "mixpanelIdentity"
        public static let TodododoZoneID = "TodododoZoneID"
        public static let lastSync = "lastSync"
    }
}



