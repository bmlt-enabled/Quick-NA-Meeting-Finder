//
//  BMLTNAMeetingSearchAddressViewController.swift
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
// MARK: - Meeting Search Meeting Details View Controller -
/* ###################################################################################################################################### */
/**
 */
class BMLTNAMeetingSearchAddressViewController: UIViewController, MKMapViewDelegate {
    /* ################################################################## */
    // MARK: IB Instance Properties
    /* ################################################################## */
    /** This is the meeting name label across the top. */
    @IBOutlet weak var meetingNameLabel: UILabel!
    /** This is the weekday and time, just below that. */
    @IBOutlet weak var meetingTimeLabel: UILabel!
    /** This text view has the adress information. */
    @IBOutlet weak var addressTextView: UITextView!
    /** If we have comments, they are displayed here. */
    @IBOutlet weak var commentsTextField: UITextView!
    /** This allows us to expand the map if the comments aren't shown. */
    @IBOutlet weak var mapTopConstraint: NSLayoutConstraint!
    /** This is the map that occupies most of the screen. */
    @IBOutlet weak var locationMapView: MKMapView!
    /** This is the segmented control that lets us select the map type. */
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    /** This is the NavBar button for directions. */
    @IBOutlet weak var directionsButton: UIBarButtonItem!
    
    /* ################################################################## */
    // MARK: Internal Instance Properties
    /* ################################################################## */
    /** This is the object that contains our meeting data. */
    var meetingObject: BMLTiOSLibMeetingNode! = nil
    /** This is the location of the search center. We use this to create a map with the right zoom. */
    var searchCenterCoords: CLLocationCoordinate2D = CLLocationCoordinate2D()

    /* ################################################################## */
    // MARK: IB Instance Methods
    /* ################################################################## */
    /**
     Reacts to the map type control being changed.
     
     - parameter sender: The segmented control that triggered this.
     */
    @IBAction func mapTypeControlChanged(_ sender: UISegmentedControl) {
        let mapTypeIndex = sender.selectedSegmentIndex
        BMLTNAMeetingSearchPrefs.prefs.mapTypeIndex = mapTypeIndex
        self.locationMapView.mapType = (0 == mapTypeIndex) ? .standard : ((1 == mapTypeIndex) ? .hybrid : .satellite)
    }
    
    /* ################################################################## */
    // MARK: Overridden Instance Methods
    /* ################################################################## */
    /**
     We use this to make sure our NavBar has the correct title.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the main window title.
        if let barTitle = self.navigationItem.title {
            self.navigationItem.title = NSLocalizedString(barTitle, comment: "")
        }
        
        self.directionsButton.title = NSLocalizedString(self.directionsButton.title!, comment: "")
        self.meetingNameLabel.text = self.meetingObject.name // Set the meeting name.
        
        // Set the time, day and format text.
        if var hour = self.meetingObject.startTimeAndDay.hour {
            if let minute = self.meetingObject.startTimeAndDay.minute {
                var time = ""
                
                if ((23 == hour) && (55 <= minute)) || ((0 == hour) && (0 == minute)) || (24 == hour) {
                    time = NSLocalizedString("DETAILS-SCREEN-MIDNIGHT", comment: "")
                } else if (12 == hour) && (0 == minute) {
                    time = NSLocalizedString("DETAILS-SCREEN-NOON", comment: "")
                } else {
                    let formatter = DateFormatter()
                    formatter.locale = Locale.current
                    formatter.dateStyle = .none
                    formatter.timeStyle = .short
                    
                    let dateString = formatter.string(from: Date())
                    let amRange = dateString.range(of: formatter.amSymbol)
                    let pmRange = dateString.range(of: formatter.pmSymbol)
                    
                    if !(pmRange == nil && amRange == nil) {
                        var amPm = formatter.amSymbol
                        
                        if 12 < hour {
                            hour -= 12
                            amPm = formatter.pmSymbol
                        } else if 12 == hour {
                            amPm = formatter.pmSymbol
                        }
                        time = String(format: "%d:%02d %@", hour, minute, amPm!)
                    } else {
                        time = String(format: "%d:%02d", hour, minute)
                    }
                }
                
                let weekday = BMLTNAMeetingSearchPrefs.weekdayNameFromWeekdayNumber(self.meetingObject.weekdayIndex)
                let localizedFormat = NSLocalizedString("DETAILS-SCREEN-MEETING-TIME-FORMAT", comment: "")
                let formats = self.meetingObject.formatsAsCSVList.isEmpty ? "" : " (" + self.meetingObject.formatsAsCSVList + ")"
                self.meetingTimeLabel.text = String(format: localizedFormat, weekday, time) + formats
            }
        }
        
        self.addressTextView.text = self.meetingObject.basicAddress // Add the address information to that field.
        if !self.meetingObject.comments.isEmpty { self.commentsTextField.text = self.meetingObject.comments }
        
        // Set up localized names for the map type control.
        for i in 0..<self.mapTypeSegmentedControl.numberOfSegments {
            if let segmentTitle = self.mapTypeSegmentedControl.titleForSegment(at: i) { self.mapTypeSegmentedControl.setTitle(NSLocalizedString(segmentTitle, comment: ""), forSegmentAt: i) }
        }
        
        self.setUpMap()
        self.mapTypeSegmentedControl.selectedSegmentIndex = BMLTNAMeetingSearchPrefs.prefs.mapTypeIndex
    }
    
    /* ################################################################## */
    /**
     If we have no comments, then we make the map bigger.
     */
    override func viewDidLayoutSubviews() {
        if self.meetingObject.comments.isEmpty {
            self.commentsTextField.isHidden = true
            self.mapTopConstraint.constant = 0
        }
        super.viewDidLayoutSubviews()
    }
    
    /* ################################################################## */
    /**
     Called as we prepare to bring in the directions controller.
     We take this opportunity to attach the meeting details to the controller.
     
     - parameter segue: The segue object.
     - parameter sender: Ignored.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BMLTNAMeetingSearchDirectionsViewController {
            destination.meetingObject = self.meetingObject
            destination.searchCenterCoords = self.searchCenterCoords
        }
        super.prepare(for: segue, sender: nil)
    }
    
    /* ################################################################## */
    // MARK: Internal Instance Methods
    /* ################################################################## */
    /**
     Set up our map to show the meeting location.
     */
    func setUpMap() {
        if nil != self.locationMapView {
            if let mapLocation = self.meetingObject.locationCoords {
                let mapTypeIndex = BMLTNAMeetingSearchPrefs.prefs.mapTypeIndex
                self.locationMapView.mapType = (0 == mapTypeIndex) ? .standard : ((1 == mapTypeIndex) ? .hybrid : .satellite)
                let mapAnnotation = BMLTNAMeetingSearchAnnotation(coordinate: mapLocation, meetings: [self.meetingObject])
                self.locationMapView.addAnnotation(mapAnnotation)
                let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0)
                let newRegion: MKCoordinateRegion = MKCoordinateRegion(center: mapLocation, span: span)
                self.locationMapView.setRegion(newRegion, animated: false)
            }
        }
    }
    
    /* ################################################################## */
    // MARK: MKMapViewDelegate Methods
    /* ################################################################## */
    /**
     This delivers a marker view to the map.
     We add a button to the callout so we can bring in directions and show the address.
     
     - parameter mapView: The map view object
     - parameter viewFor: The annotation object we'll be creating the view for
     
     - returns: A marker view.
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: BMLTNAMeetingSearchAnnotation.self) {
            let reuseID = ""
            if let myAnnotation = annotation as? BMLTNAMeetingSearchAnnotation {
                let markerView = BMLTNAMeetingSearchMarker(annotation: myAnnotation, draggable: false, reuseID: reuseID)
                return markerView
            }
        }
        
        return nil
    }
}
