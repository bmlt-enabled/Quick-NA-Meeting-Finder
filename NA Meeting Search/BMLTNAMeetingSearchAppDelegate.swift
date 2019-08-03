//
//  BMLTNAMeetingSearchAppDelegate.swift
//  NA Meeting Search
//
//  Created by BMLT-Enabled
//
//  https://bmlt.app/
//
//  This software is licensed under the MIT License.
//  Copyright (c) 2017 BMLT-Enabled
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
    /// The window for the app.
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
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
            
            alertController.addAction(okAction)
            
            topController.present(alertController, animated: true, completion: nil)
        }
    }

    /* ################################################################## */
    /**
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
