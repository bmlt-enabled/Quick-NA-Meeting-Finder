//
//  BMLTNAMeetingSearchAboutViewController.swift
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
