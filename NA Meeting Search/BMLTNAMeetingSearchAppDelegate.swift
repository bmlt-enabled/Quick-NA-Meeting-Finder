//
//  BMLTNAMeetingSearchAppDelegate.swift
//  NA Meeting Search
//
//  Created by MAGSHARE
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  BMLT is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this code.  If not, see <http://www.gnu.org/licenses/>.

import UIKit

/* ###################################################################################################################################### */
// MARK: - Main Application -
/* ###################################################################################################################################### */
/**
 The principal purpose of this app is doemonstrate usage of [the BMLTiOSLib](https://bmlt.magshare.net) project.
 
 That said, it is a perfectly usable, extremely high-quality shippable app that can be used "in the wild" to find NA meetings.
 */
@UIApplicationMain
class BMLTNAMeetingSearchAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // I got these from here: http://stackoverflow.com/questions/24825123/get-the-current-view-controller-from-the-app-delegate#answer-29834852
    
    /* ################################################################## */
    /**
        - returns: the most recently presented UIViewController (visible)
     */
    class func getCurrentViewController() -> UIViewController? {
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {
            return navigationController.visibleViewController
        }
        
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while currentController.presentedViewController != nil {
                currentController = currentController.presentedViewController
            }
            
            return currentController
        }
        return nil
    }
    
    /* ################################################################## */
    /**
        - returns: the navigation controller if it exists
     */
    class func getNavigationController() -> UINavigationController? {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController {
            return navigationController as? UINavigationController
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     Displays the given error in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter inMessage: a string to be displayed as the message of the alert. It is localized by this method.
     */
    class func displayErrorAlert(_ inTitle: String, inMessage: String) {
        if let topController = self.getNavigationController()?.topViewController {
            let alertController = UIAlertController(title: NSLocalizedString(inTitle, comment: ""), message: NSLocalizedString(inMessage, comment: ""), preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            
            alertController.addAction(okAction)
            
            topController.present(alertController, animated: true, completion: nil)
        }
    }

    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    /* ################################################################## */
    /**
     */
    func applicationWillResignActive(_ application: UIApplication) {
        if let viewController = type(of: self).getCurrentViewController() as? BMLTNAMeetingSearchInitialViewController {
            viewController.dontDisplayErrorMessage = true
            viewController.terminateConnection()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
        if let viewController = type(of: self).getCurrentViewController() as? BMLTNAMeetingSearchInitialViewController {
            viewController.dontDisplayErrorMessage = true
            viewController.terminateConnection()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func applicationWillEnterForeground(_ application: UIApplication) {
        if let viewController = type(of: self).getCurrentViewController() as? BMLTNAMeetingSearchInitialViewController {
            viewController.dontDisplayErrorMessage = true
            viewController.terminateConnection()
            viewController.bigAssButtonWasHit(viewController.theBigSearchButton)
        }
    }
}
