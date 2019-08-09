//
//  AppLaunchTracker.swift
//  ApplicationCoordinator
//
//  Created by 大高倭 on 2019/08/09.
//  Copyright © 2019 大高倭. All rights reserved.
//

import UserNotifications

protocol LaunchTrackerDelegate: AnyObject {
    func remoteNotificationDidCall(_ appState: AppCoordinator.AppState)
    func localNotificationDidCall(_ appState: AppCoordinator.AppState, userInfo: [AnyHashable: Any])
}

struct LaunchTracker {
    enum Event: Equatable {
        case remoteNotification(_ appState: AppCoordinator.AppState, userInfo: [AnyHashable: Any], notification: UNNotificationRequest)
        case localNotification(_ appState: AppCoordinator.AppState, userInfo: [AnyHashable: Any], notification: UNNotificationRequest)
        // If launch type is not set "self = .none", because this project is WIP
        case none

        init?(launchType: AppCoordinator.LaunchType) {
            switch launchType {
            case .normal:
                self = .none
            case .notification(let application, let userInfo, let request):
                if request.trigger is UNPushNotificationTrigger {
                    self = .remoteNotification(application, userInfo: userInfo, notification: request)
                } else {
                    self = .localNotification(application, userInfo: userInfo, notification: request)
                }
            case .userActivity(_):
                self = .none
            case .openURL(_):
                self = .none
            case .shortcutItem(_):
                self = .none
            }
        }

        static func == (lhs: LaunchTracker.Event, rhs: LaunchTracker.Event) -> Bool {
            switch lhs {
            case .remoteNotification(_, _, let requestt):
                return rhsCompare(rhs, compareValue: requestt)
            case .localNotification(_, _, notification: let request):
                return rhsCompare(rhs, compareValue: request)
            case .none:
                return rhsCompare(rhs, compareValue: nil)
            }
        }

        private static func rhsCompare(_ rhs: LaunchTracker.Event, compareValue: Any?) -> Bool {
            switch rhs {
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
            case .none:
                return true
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

    private static func send(event: Event, delegate: LaunchTrackerDelegate?) -> Event? {
        guard let delegate = delegate else {
            return nil
        }
        switch event {
        case .remoteNotification(let application, _ , _ ):
            delegate.remoteNotificationDidCall(application)
        case .localNotification(let application, let userInfo, _ ):
            delegate.localNotificationDidCall(application, userInfo: userInfo)
        case .none: break
        }
        return event
    }
}
