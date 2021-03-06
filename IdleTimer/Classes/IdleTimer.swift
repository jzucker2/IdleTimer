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
fileprivate let IsEnabledKey = "IsEnabledKey"

public protocol IdleTimerListener {
    func idleTimer(timer: IdleTimer, didUpdateState: Bool)
}

@objc
public enum ScreenState: Int {
    case awake
    case sleepy
    
    public static var allStates: [ScreenState] {
        return [.awake, .sleepy]
    }
    
    public var title: String {
        switch self {
        case .awake:
            return "Awake"
        case .sleepy:
            return "Off"
        }
    }
    
    public var oppositeState: ScreenState {
        switch self {
        case .awake:
            return .sleepy
        case .sleepy:
            return .awake
        }
    }
    
    public static func screenState(for string: String) -> ScreenState? {
        return allStates.first(where: { (state) -> Bool in
            return state.title == string
        })
    }
    
    public func setIdleTimer() {
        let idleTimerState = isIdleTimerDisabled
        UIApplication.shared.isIdleTimerDisabled = idleTimerState
        print("UIApplication.shared.isIdleTimerDisabled = \(UIApplication.shared.isIdleTimerDisabled)")
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

public extension Notification.Name {
    static let IdleTimerDidChange: Notification.Name = Notification.Name("IdleTimerDidChange")
}

@objc
open class IdleTimer: NSObject {
    
    
    open class var defaultScreenState: ScreenState {
        return ScreenState.sleepy
    }
    
    open class var isEnabledByDefault: Bool {
        return false
    }
    
    static let IdleTimerNotificationAwakeCurrentStateKey = "UpdatedIdleTimerStateKey"
    static let IdleTimerNotificationAwakeOldStateKey = "OldIdleTimerStateKey"
    
    public static let sharedInstance = IdleTimer()
    
    private var listeners: [IdleTimerListener] = [IdleTimerListener]()
    
    public override init() {
        if let existingState = UserDefaults.standard.object(forKey: ScreenStateKey) {
            guard let intState = existingState as? Int, let actualState = ScreenState(rawValue: intState) else {
                fatalError("What happened, existingState: \(existingState)")
            }
            self.screenState = actualState
        } else {
            // so that we take subclassing into account
            let defaultState = type(of: self).defaultScreenState
            self.screenState = defaultState
            UserDefaults.standard.set(defaultState.rawValue, forKey: ScreenStateKey)
        }
        if let existingIsEnabled = UserDefaults.standard.object(forKey: IsEnabledKey) {
            guard let boolEnabled = existingIsEnabled as? Bool else {
                fatalError("How did we get the wrong object in this key? key: \(IsEnabledKey), value: \(existingIsEnabled)")
            }
            self.isEnabled = boolEnabled
        } else {
            let defaultIsEnabled = type(of: self).isEnabledByDefault
            self.isEnabled = defaultIsEnabled
            UserDefaults.standard.set(defaultIsEnabled, forKey: IsEnabledKey)
        }
        super.init()
        if isEnabled {
            screenState.setIdleTimer()
        } else {
            print("IdleTimer is initially disabled")
        }
    }
    
    @objc public dynamic var screenState: ScreenState {
        didSet {
            if isEnabled {
                screenState.setIdleTimer()
            } else {
                print("IdleTimer is disabled, saving state anyways")
            }
            UserDefaults.standard.set(screenState.rawValue, forKey: ScreenStateKey)
        }
    }
    
    open var currentScreenStateTitle: String {
        return screenState.title
    }
    
    open func setIdleTimerForCurrentScreenState() {
        guard isEnabled else {
            print("IdleTimer is disabled")
            return
        }
        screenState.setIdleTimer()
    }
    
    open func switchScreenState() -> ScreenState? {
        guard isEnabled else {
            print("IdleTimer is disabled")
            return nil
        }
        screenState = screenState.oppositeState
        return screenState
    }
    
    @objc open dynamic var isEnabled: Bool {
        didSet {
            switch isEnabled {
            case true:
                setIdleTimerForCurrentScreenState()
            case false:
                ScreenState.sleepy.setIdleTimer()
            }
            UserDefaults.standard.set(isEnabled, forKey: IsEnabledKey)
        }
    }

}

public extension UIAlertController {
    
    public static func idleTimerDurationAlertController(idleTimer: IdleTimer) -> UIAlertController {
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
