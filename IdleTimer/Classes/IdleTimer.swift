//
//  IdleTimer.swift
//  Pods
//
//  Created by Jordan Zucker on 1/25/17.
//
//

import UIKit

fileprivate let IsAwakeKey = "IsAwakeKey"
fileprivate let ScreenStateKey = "ScreenStateKey"

protocol IdleTimerListener {
    func idleTimer(timer: IdleTimer, didUpdateState: Bool)
}

@objc
enum ScreenState: Int {
    case awake
    case sleepy
    
    static var allStates: [ScreenState] {
        return [.awake, .sleepy]
    }
    
    var title: String {
        switch self {
        case .awake:
            return "Awake"
        case .sleepy:
            return "Off"
        }
    }
    
    static func screenState(for string: String) -> ScreenState? {
        return allStates.first(where: { (state) -> Bool in
            return state.title == string
        })
    }
    
    func setIdleTimer() {
        let idleTimerState = isIdleTimerDisabled
        UIApplication.shared.isIdleTimerDisabled = idleTimerState
    }
    
    var isIdleTimerDisabled: Bool {
        switch self {
        case .awake:
            return true
        case .sleepy:
            return false
        }
    }
}

extension Notification.Name {
    static let IdleTimerDidChange: Notification.Name = Notification.Name("IdleTimerDidChange")
}

@objc
class IdleTimer: NSObject {
    
    static let IdleTimerNotificationAwakeCurrentStateKey = "UpdatedIdleTimerStateKey"
    static let IdleTimerNotificationAwakeOldStateKey = "OldIdleTimerStateKey"
    
    static let sharedInstance = IdleTimer()
    
    private var listeners: [IdleTimerListener] = [IdleTimerListener]()
    
    override init() {
        if let existingState = UserDefaults.standard.object(forKey: ScreenStateKey) {
            guard let intState = existingState as? Int, let actualState = ScreenState(rawValue: intState) else {
                fatalError("What happened, existingState: \(existingState)")
            }
            self.screenState = actualState
        } else {
            self.screenState = ScreenState.awake
        }
        super.init()
    }
    
    dynamic var screenState: ScreenState {
        didSet {
            UserDefaults.standard.set(screenState.rawValue, forKey: ScreenStateKey)
        }
    }

}

extension UIAlertController {
    
    static func idleTimerDurationAlertController(idleTimer: IdleTimer) -> UIAlertController {
        let alertController = UIAlertController(title: "Awake duration", message: "Choose a duration to keep the screen awake", preferredStyle: .actionSheet)
        
        let alertActionHandler: (UIAlertAction) -> Void = { (alertAction) in
            guard let title = alertAction.title, let newState = ScreenState.screenState(for: title) else {
                fatalError("How did we not find an expected value?")
            }
            idleTimer.screenState = newState
        }
        func alertAction(for state: ScreenState) -> UIAlertAction {
            return UIAlertAction(title: state.title, style: .default, handler: alertActionHandler)
        }
        
        ScreenState.allStates.forEach { (state) in
            let action = alertAction(for: state)
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        return alertController
    }
}
