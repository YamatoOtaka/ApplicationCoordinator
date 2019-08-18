//
//  AppCoordinator.swift
//  ApplicationCoordinator
//
//  Created by 大高倭 on 2019/08/09.
//  Copyright © 2019 大高倭. All rights reserved.
//

import UIKit
import UserNotifications

protocol Coordinator {
    func start<T: Any>(_ type: T)
}

final class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let rootViewController: UIViewController

    enum LaunchType {
        case normal
        case notification(_ appState: AppState, userInfo: [AnyHashable: Any], notification: UNNotificationRequest)
        case userActivity(_ userActivity: NSUserActivity)
        case openURL(_ url: URL)
        case shortcutItem(_ shortcutItem: UIApplicationShortcutItem)
    }

    enum AppState {
        case inactive
        case background
        case active
        case unknown
    }

    init(window: UIWindow) {
        self.window = window
        self.rootViewController = UIViewController()
    }

    func start<T>(_ type: T) {
        guard let type = type as? LaunchType else {
            return
        }
        window.rootViewController = rootViewController
        let previousVC = window.rootViewController
        if let previousVC = previousVC {
            previousVC.dismiss(animated: false) {
                previousVC.view.removeFromSuperview()
            }
        }
        window.makeKeyAndVisible()
        _ = LaunchTracker.track(launchType: type, delegate: self)
    }

    static func conversionAppState(_ application: UIApplication) -> AppState {
        switch application.applicationState {
        case .active:
            return .active
        case .inactive:
            return .inactive
        case .background:
            return .background
        @unknown default:
            return .unknown
        }
    }
}

extension AppCoordinator: LaunchTrackerDelegate {
    func remoteNotificationDidCall(_ appState: AppCoordinator.AppState) {
        // TODO: send some events
    }

    func localNotificationDidCall(_ appState: AppCoordinator.AppState, userInfo: [AnyHashable : Any]) {
        // TODO: send some events
    }

    func userActivityDidCall(_ activity: NSUserActivity) {
        // TODO: send some events
    }

    func openURL(_ url: URL) {
        // TODO: send some events
    }
}
