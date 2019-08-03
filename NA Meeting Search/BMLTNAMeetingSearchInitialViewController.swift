//
//  BMLTNAMeetingSearchInitialViewController.swift
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
import MapKit
import BMLTiOSLib

/* ###################################################################################################################################### */
// MARK: - Initial View Controller -
/* ###################################################################################################################################### */
/**
 This is the fundamental instance for the app.
 
 The whole deal with the app, is that it's a "one button" app. Press the big button, and get a modal set of results presented simply and intuitively.
 */
class BMLTNAMeetingSearchInitialViewController: UIViewController, BMLTiOSLibDelegate, CLLocationManagerDelegate {
    /* ################################################################## */
    // MARK: Private Static Class Constant Properties
    /* ################################################################## */
    /** The Search Results Segue ID */
    private static let _sSearchResultsSegueID: String = "showSearchResults"
    
    /* ################################################################## */
    // MARK: Private Static Class Properties
    /* ################################################################## */
    /** This is the BMLTiOSLib instance that handles the session with the server. */
    private static var _svCommunicationObject: BMLTiOSLib! = nil
    
    /* ################################################################## */
    // MARK: Private Class Properties
    /* ################################################################## */
    /** This will hold our location manager. */
    private var _locationManager: CLLocationManager! = nil

    /* ################################################################## */
    /** We can do two tries to determine location. This is set to true after the first one. */
    private var _locationFailedOnce: Bool = false
    
    /* ################################################################## */
    /** This contains the coordinates we found when we geolocated. */
    private var _searchCenterCoords: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    /* ################################################################## */
    /** This is a flag that tells us to run the app upon first load. */
    private var _firstLoad: Bool = true
    
    /* ################################################################## */
    /** This is a flag that tells the error display not to yell at us (for now). */
    var dontDisplayErrorMessage: Bool = false
    
    /* ################################################################## */
    // MARK: Internal Instance IB Properties
    /* ################################################################## */
    /** This is the big fat button that the user presses. */
    @IBOutlet weak var theBigSearchButton: BMLTNAMeetingSearchAnimatedButtonView!
    
    /* ################################################################## */
    // MARK: Internal Instance Calculated Properties
    /* ################################################################## */
    /** Tells us whether or not we have an active, valid session (read-only) */
    var isSessionValid: Bool {
        var ret: Bool = false
        
        if nil != type(of: self)._svCommunicationObject {
            ret = type(of: self)._svCommunicationObject.isConnected
        }
        
        return ret
    }
    
    /* ################################################################## */
    /** This is a quick access to the communication object. */
    var commObject: BMLTiOSLib! {
        get {
            return type(of: self)._svCommunicationObject
        }
        
        // We can set the object. It will terminate and overwrite any existing instance. There can only be one.
        set {
            type(of: self)._svCommunicationObject = newValue
        }
    }
    
    /* ################################################################## */
    /** Quick access to the search Criteria (read-only) */
    var criteriaObject: BMLTiOSLibSearchCriteria! {
        var ret: BMLTiOSLibSearchCriteria! = nil
        
        if nil != self.commObject {
            ret = self.commObject.searchCriteria
        }
        
        return ret
    }
    
    /* ################################################################## */
    // MARK: Private Instance Methods
    /* ################################################################## */
    /**
     Handles a found location. This starts the process of finding meetings that start today, after our current time.
     We add tomorrow, as well, looping the week if we are at the end.
     
     - parameter coordinate: The coordinate of the user's location.
     */
    private func _startSearch(_ coordinate: CLLocationCoordinate2D) {
        self._searchCenterCoords = coordinate
        self._locationFailedOnce = false
        if nil != self.criteriaObject {
            self.criteriaObject.clearAll()
            self.criteriaObject.searchLocation = coordinate
        
            let date = NSDate()
            let calendar = NSCalendar.current
            let today = calendar.component(.weekday, from: date as Date)
            let tomorrow = (7 > today) ? today + 1 : 1
            
            if let todayIndex = BMLTiOSLibSearchCriteria.WeekdayIndex(rawValue: today) {
                self.criteriaObject.weekdays[todayIndex] = .Selected
            }
            
            if let tomorrowIndex = BMLTiOSLibSearchCriteria.WeekdayIndex(rawValue: tomorrow) {
                self.criteriaObject.weekdays[tomorrowIndex] = .Selected
            }
            self.criteriaObject.searchRadius = -20  // We do a double-shot, in case we'll be throwing out a bunch of meetings.
            self.criteriaObject.performMeetingSearch(.MeetingsOnly)
        }
    }
    
    /* ################################################################## */
    /**
     Displays the given error in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter inMessage: a string to be displayed as the message of the alert. It is localized by this method.
     */
    class func _displayErrorAlert(_ inTitle: String, inMessage: String, presentedBy inPresentingViewController: UIViewController ) {
        if let presentingController = inPresentingViewController as? BMLTNAMeetingSearchInitialViewController {
            if presentingController.dontDisplayErrorMessage {
                presentingController.dontDisplayErrorMessage = false
                return
            }
        }
        
        let alertController = UIAlertController(title: NSLocalizedString(inTitle, comment: ""), message: NSLocalizedString(inMessage, comment: ""), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("BMLTNAMeetingSearchError-OKButtonText", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
        
        alertController.addAction(okAction)
        
        inPresentingViewController.present(alertController, animated: true, completion: nil)
    }
    
    /* ################################################################## */
    // MARK: Overridden Instance Methods
    /* ################################################################## */
    /**
     We simply use this to make sure our NavBar is hidden.
     
     Simplify, simplify, simplify.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        self._locationFailedOnce = false
        self.commObject = nil
        self.navigationController?.isNavigationBarHidden = true
        super.viewWillAppear(animated)
        if self._firstLoad {
            self._firstLoad = false
            self.bigAssButtonWasHit(self.theBigSearchButton)
        }
    }
    
    /* ################################################################## */
    /**
     Called as we prepare to bring in the meeting list.
     We take this opportunity to attach the meeting search results to the list controller.
     
     - parameter segue: The segue object.
     - parameter sender: The meeting search results Array data we attached to the segue.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let senderArray = sender as? [BMLTiOSLibMeetingNode] {
            if let searchResultsDisplayController = segue.destination as? BMLTNAMeetingSearchResultViewController {
                searchResultsDisplayController.searchResultArray = senderArray
                searchResultsDisplayController.searchCenterCoords = self._searchCenterCoords
            }
        }
        
        super.prepare(for: segue, sender: nil)
    }

    /* ################################################################## */
    // MARK: Internal IBAction Handlers
    /* ################################################################## */
    /**
     This is called when the large search button is called.
     
     - parameter sender: The big button of Search.
     */
    @IBAction func bigAssButtonWasHit(_ sender: BMLTNAMeetingSearchAnimatedButtonView) {
        var goodLoc: Bool = false
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                break
                
            case .notDetermined, .authorizedAlways, .authorizedWhenInUse:
                goodLoc = true
            @unknown default:
                fatalError("UNKOWN ERROR")
            }
        }
        
        if !goodLoc {
            type(of: self)._displayErrorAlert("BMLTNAMeetingSearchError-LocationFailHeader", inMessage: "BMLTNAMeetingSearchError-LocationOffText", presentedBy: self)
        } else {
            self._locationFailedOnce = false
            if !self.theBigSearchButton.isAnimating {
                self.startNewConnection()
            } else {
                self.terminateConnection()
                self.theBigSearchButton.stopAnimation() // This makes sure the button is reset.
            }
        }
    }
    
    /* ################################################################## */
    // MARK: Internal Instance Methods
    /* ################################################################## */
    /**
     Sets up a new connection.
     This starts the animation.
     */
    func startNewConnection() {
        self.terminateConnection()
        self.theBigSearchButton.startAnimation()
        self.commObject = BMLTiOSLib(inRootServerURI: BMLTNAMeetingSearchPrefs.prefs.rootURI, inDelegate: self)
    }
    
    /* ################################################################## */
    /**
     Kills the connection.
     
     When this stops the animation, it does so in a fashion that does not reset the animation to the first frame.
     If you want to reset the animation, you need to subsequently call self.theBigSearchButton.stopAnimation() <- Notice no arguments.
     */
    func terminateConnection() {
        if nil != self._locationManager {
            self._locationManager.stopUpdatingLocation()
        }
        self.theBigSearchButton.stopAnimation(endAnimation: false)
        self.commObject = nil
    }
    
    /* ################################################################## */
    // MARK: Internal BMLTiOSLibDelegate Methods
    /* ################################################################## */
    /**
     Indicates whether or not the server pointed to via the URI is a valid server (the connection was successful).
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter inServerIsValid: A Bool, true, if the server was successfully connected.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, serverIsValid: Bool) {
        self._locationFailedOnce = false
        if !serverIsValid { // If we didn't make it, then we terminate the attempt.
            self.terminateConnection()
            self.theBigSearchButton.stopAnimation() // This makes sure the button is reset.
        } else {    // If we did, w00t! We start a "Find out where I am" geolocation, and we'll do a search from there.
            self._locationManager = CLLocationManager()
            self._locationManager.delegate = self
            self._locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self._locationManager.requestWhenInUseAuthorization()
            self._locationManager.startUpdatingLocation()
        }
    }
    
    /* ################################################################## */
    /**
     Returns the result of a meeting search.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter meetingSearchResults: An array of meeting objects, representing the results of a search.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, meetingSearchResults: [BMLTiOSLibMeetingNode]) {
        if nil != self._locationManager {
            self._locationManager.stopUpdatingLocation()
        }
        self.terminateConnection()
        self.theBigSearchButton.stopAnimation() // This makes sure the button is reset.
        
        // After we fetch all the results, we then sort through them, and remove ones that have already passed today (We leave tomorrow alone).
        var finalResults: [BMLTiOSLibMeetingNode] = []
        let calendar = NSCalendar.current
        let today = calendar.component(.weekday, from: Date())
        var hour = calendar.component(.hour, from: Date())
        var minute = calendar.component(.minute, from: Date())
        
        let tempHourMinutes = (hour * 60) + minute + BMLTNAMeetingSearchPrefs.prefs.gracePeriodInMinutes
        hour = Int(tempHourMinutes / 60)
        minute = Int(tempHourMinutes - (hour * 60))
        
        let startingTime = DateComponents(calendar: nil, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: hour, minute: minute, second: 0, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        
        // Build up an array of ones that pass muster.
        for meeting in meetingSearchResults {
            if (meeting.weekdayIndex != today) || meeting.meetingStartsOnOrAfterThisTime(startingTime as NSDateComponents) {
                finalResults.append(meeting)
            }
        }
        
        if 0 < finalResults.count {
            self.performSegue(withIdentifier: type(of: self)._sSearchResultsSegueID, sender: finalResults)
        } else {
            if !self.dontDisplayErrorMessage {
                type(of: self)._displayErrorAlert("BMLTNAMeetingSearchError-NoResultsHeader", inMessage: "BMLTNAMeetingSearchError-NoResultsText", presentedBy: self)
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called if there is an error.
     
     The error String will be a key for localization, and will be pretty much worthless on its own.
     
     - parameter inLibInstance: the BMLTiOSLib instance.
     - parameter errorOccurred: The error that occurred.
     */
    func bmltLibInstance(_ inLibInstance: BMLTiOSLib, errorOccurred error: Error) {
        if nil != self._locationManager {
            self._locationManager.stopUpdatingLocation()
        }
        self.terminateConnection()
        self.theBigSearchButton.stopAnimation() // This makes sure the button is reset.
        if !self.dontDisplayErrorMessage {
            type(of: self)._displayErrorAlert("BMLTNAMeetingSearchError-CommErrorHeader", inMessage: "BMLTNAMeetingSearchError-CommErrorText", presentedBy: self)
        }
    }
    
    /* ################################################################## */
    // MARK: Internal CLLocationManagerDelegate Methods
    /* ################################################################## */
    /**
     This is called if the location manager suffers a failure.
     
     - parameter manager: The Location Manager object that had the error.
     - parameter didFailWithError: The error in question.
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.terminateConnection()
        self.theBigSearchButton.stopAnimation() // This makes sure the button is reset.
        if self._locationFailedOnce {   // If at first, you don't succeed...
            self.theBigSearchButton.stopAnimation()
            self._locationFailedOnce = false
            if !self.dontDisplayErrorMessage {
                type(of: self)._displayErrorAlert("BMLTNAMeetingSearchError-LocationFailHeader", inMessage: "BMLTNAMeetingSearchError-LocationFailText", presentedBy: self)
            }
        } else {    // We try two times.
            self._locationFailedOnce = true
            self.startNewConnection()
        }
    }
    
    /* ################################################################## */
    /**
     Callback to handle found locations.
     
     - parameter manager: The Location Manager object that had the event.
     - parameter didUpdateLocations: an array of updated locations.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self._locationManager.stopUpdatingLocation()
        self._locationFailedOnce = false
        for location in locations where 2 > location.timestamp.timeIntervalSinceNow {
            let coordinate = location.coordinate
            DispatchQueue.main.async(execute: { self._startSearch(coordinate) })
            break
        }
    }
}
