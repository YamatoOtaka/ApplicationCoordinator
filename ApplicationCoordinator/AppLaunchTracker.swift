//
//  AppLaunchTracker.swift
//  ApplicationCoordinator
//
//  Created by 大高倭 on 2019/08/09.
//  Copyright © 2019 大高倭. All rights reserved.
//

import UserNotifications
import UIKit

protocol LaunchTrackerDelegate: class {
    func normalDidCall()
    func remoteNotificationDidCall(_ appState: AppCoordinator.AppState)
    func localNotificationDidCall(_ appState: AppCoordinator.AppState, userInfo: [AnyHashable: Any])
    func userActivityDidCall(_ activity: NSUserActivity)
    func openURLDidCall(_ url: URL)
    func shortcutItemDidCall(_ shortcutItem: UIApplicationShortcutItem)
}

struct LaunchTracker {
    enum Event: Equatable {
        case normal
        case remoteNotification(_ appState: AppCoordinator.AppState, userInfo: [AnyHashable: Any], notification: UNNotificationRequest)
        case localNotification(_ appState: AppCoordinator.AppState, userInfo: [AnyHashable: Any], notification: UNNotificationRequest)
        case userActivity(_ userActivity: NSUserActivity)
        case openURL(_ url: URL)
        // Fix it later to remove UIKit
        case shortcutItem(_ shortcutItem: UIApplicationShortcutItem)

        init?(launchType: AppCoordinator.LaunchType) {
            switch launchType {
            case .normal:
                self = .normal
            case .notification(let application, let userInfo, let request):
                if request.trigger is UNPushNotificationTrigger {
                    self = .remoteNotification(application, userInfo: userInfo, notification: request)
                } else {
                    self = .localNotification(application, userInfo: userInfo, notification: request)
                }
            case .userActivity(let activity):
                self = .userActivity(activity)
            case .openURL(let url):
                self = .openURL(url)
            case .shortcutItem(let item):
                self = .shortcutItem(item)
            }
        }

        static func == (lhs: LaunchTracker.Event, rhs: LaunchTracker.Event) -> Bool {
            switch lhs {
            case .normal:
                return rhsCompare(rhs, compareValue: nil)
            case .remoteNotification(_, _, let requestt):
                return rhsCompare(rhs, compareValue: requestt)
            case .localNotification(_, _, notification: let request):
                return rhsCompare(rhs, compareValue: request)
            case .userActivity(let activity):
                return rhsCompare(rhs, compareValue: activity)
            case .openURL(let url):
                return rhsCompare(rhs, compareValue: url)
            case .shortcutItem(let item):
                return rhsCompare(rhs, compareValue: item)
            }
        }

        private static func rhsCompare(_ rhs: LaunchTracker.Event, compareValue: Any?) -> Bool {
            switch rhs {
            case .normal:
                return true
            case .remoteNotification(_, _, let request):
                guard let value = compareValue as? UNNotificationRequest else {
                    return false
                }
                if value.identifier == request.identifier {
                    return true
                } else {
                    return false
                }
            case .localNotification(_, _, let request):
                guard let value = compareValue as? UNNotificationRequest else {
                    return false
                }
                if value.identifier == request.identifier {
                    return true
                } else {
                    return false
                }
            case .userActivity(let activity):
                guard let value = compareValue as? NSUserActivity else {
                    return false
                }
                if value.activityType == activity.activityType {
                    return true
                } else {
                    return false
                }
            case .openURL(let url):
                guard let newUrl = compareValue as? URL else {
                    return false
                }
                if newUrl.absoluteString == url.absoluteString {
                    return true
                } else {
                    return false
                }
            case .shortcutItem(let item):
                guard let newItem = compareValue as? UIApplicationShortcutItem else {
                    return false
                }
                if newItem.localizedTitle == item.localizedTitle {
                    return true
                } else {
                    return false
                }
            }
        }
    }

    static func track(launchType: AppCoordinator.LaunchType, delegate: LaunchTrackerDelegate?) -> Event? {
        guard let event = Event(launchType: launchType) else {
            return nil
        }
        if let delegate = delegate {
            return send(event: event, delegate: delegate)
        } else {
            return send(event: event, delegate: nil)
        }
    }

    private static func send(event: Event, delegate: LaunchTrackerDelegate?) -> Event {
        guard let delegate = delegate else {
            return event
        }
        switch event {
        case .normal:
            delegate.normalDidCall()
        case .remoteNotification(let application, _ , _ ):
            delegate.remoteNotificationDidCall(application)
        case .localNotification(let application, let userInfo, _ ):
            delegate.localNotificationDidCall(application, userInfo: userInfo)
        case .userActivity(let activity):
            delegate.userActivityDidCall(activity)
        case .openURL(let url):
            delegate.openURLDidCall(url)
        case .shortcutItem(let item):
            delegate.shortcutItemDidCall(item)
        }
        return event
    }
}
