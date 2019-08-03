//
//  BMLTNAMeetingSearchAboutViewController.swift
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
// MARK: - Meeting Search About View Controller -
/* ###################################################################################################################################### */
/**
 */
class BMLTNAMeetingSearchAboutViewController: UIViewController {
    /* ################################################################## */
    // MARK: IB Properties
    /* ################################################################## */
    /** This is the credit label on the top. */
    @IBOutlet weak var goMeLabel: UILabel!
    /** This displays the version. */
    @IBOutlet weak var versionLabel: UILabel!
    /** This is more about the app and its distibutor/maintainer. */
    @IBOutlet weak var aboutUsTextItem: UITextView!
    /** This is the big "Beanie" button. If we have a URI, it is enabled, and hitting it executes that URI in the browser. */
    @IBOutlet weak var beanieButton: UIButton!
    
    /* ################################################################## */
    // MARK: Internal Instance Properties
    /* ################################################################## */
    /** This is the URI that is executed when someone hits the "Beanie Button." */
    var buttonURI: String = ""
    
    /* ################################################################## */
    // MARK: Overridden Instance Methods
    /* ################################################################## */
    /**
     We use this to make sure our NavBar has the correct title.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var appName = ""
        var appVersion = ""
        
        if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
                if let appNameTemp = plistDictionary["CFBundleName"] as? NSString {
                    appName = appNameTemp as String
                }
                
                if let versionTemp = plistDictionary["CFBundleShortVersionString"] as? NSString {
                    appVersion = versionTemp as String
                }
                
                if let version2Temp = plistDictionary["CFBundleVersion"] as? NSString {
                    appVersion += "." + (version2Temp as String)
                }
                
                if let buttonURI = plistDictionary["BMLTButtonURL"] as? NSString {
                    self.buttonURI = buttonURI as String
                }
            }
        }

        if let barTitle = self.navigationItem.title {
            self.navigationItem.title = String(format: NSLocalizedString(barTitle, comment: ""), appName)
        }
        self.goMeLabel.text = NSLocalizedString(self.goMeLabel.text!, comment: "")
        self.versionLabel.text = String(format: NSLocalizedString(self.versionLabel.text!, comment: ""), appVersion)
        self.aboutUsTextItem.text = NSLocalizedString(self.aboutUsTextItem.text!, comment: "")
        
        self.beanieButton!.isEnabled = !self.buttonURI.isEmpty
    }
    
    /* ################################################################## */
    /**
     Called just after the screen appears.
     We use this to make sure the text is scrolled all the way up.
     
     - parameter: animated True, if the transition is animated.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.aboutUsTextItem.setContentOffset(CGPoint.zero, animated: true)
    }
    
    /* ################################################################## */
    /**
     The "Beanie Button" was hit.
     
     - parameter sender: The button object.
     */
    @IBAction func beanieBanged(_ sender: UIButton) {
        if !self.buttonURI.isEmpty {
            let openLink = NSURL(string: self.buttonURI)
            UIApplication.shared.open(openLink! as URL, options: [:], completionHandler: nil)
        }
    }
}
