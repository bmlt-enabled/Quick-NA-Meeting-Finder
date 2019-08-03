//
//  BMLTNAMeetingSearchResultViewController.swift
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
// MARK: - Meeting Search Result Display View Controller -
/* ###################################################################################################################################### */
/**
 */
class BMLTNAMeetingSearchResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Private Static Class Constant Properties
    /* ################################################################## */
    /** The Search Results Segue ID */
    private static let _sShowDetailSegueID: String = "showMeetingDetails"

    /* ################################################################## */
    // MARK: IBOutlet Properties
    /* ################################################################## */
    /** This is the table that displays the results. */
    @IBOutlet var _resultsTable: UITableView!
    /** This is a segmented switch that dictates how the results are sorted. */
    @IBOutlet weak var _sortSegmentedSwitch: UISegmentedControl!
    
    /* ################################################################## */
    // MARK: Internal Instance Properties
    /* ################################################################## */
    /** These are our meeting search results. */
    var searchResultArray: [BMLTiOSLibMeetingNode]! = []
    /** This contains the center of the search, as specified at the start of things. */
    var searchCenterCoords: CLLocationCoordinate2D! = nil
    
    /* ################################################################## */
    // MARK: Overridden Instance Methods
    /* ################################################################## */
    /**
     We use this to make sure our NavBar has the correct title.
     
     Simplify, simplify, simplify.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let barTitle = self.navigationItem.title {
            self.navigationItem.title = NSLocalizedString(barTitle, comment: "")
        }
        
        if let segment0Title = self._sortSegmentedSwitch.titleForSegment(at: 0) {
            self._sortSegmentedSwitch.setTitle(NSLocalizedString(segment0Title, comment: ""), forSegmentAt: 0)
        }
        
        if let segment1Title = self._sortSegmentedSwitch.titleForSegment(at: 1) {
            self._sortSegmentedSwitch.setTitle(NSLocalizedString(segment1Title, comment: ""), forSegmentAt: 1)
        }
        
        if BMLTNAMeetingSearchPrefs.prefs.sortResultsByDistance {
            self._sortSegmentedSwitch.selectedSegmentIndex = 1
        }
        
        self._sortResults(1 == self._sortSegmentedSwitch.selectedSegmentIndex)
    }

    /* ################################################################## */
    /**
     We use this to make sure our NavBar is shown.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        // Unhighlight any highlighted rows.
        for row in 0..<self._resultsTable.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            self._resultsTable.deselectRow(at: indexPath, animated: true)
        }
        
        super.viewWillAppear(animated)
    }
    
    /* ################################################################## */
    /**
     Called as we prepare to bring in the meeting list.
     We take this opportunity to attach the meeting details to the list controller.
     
     - parameter segue: The segue object.
     - parameter sender: The meeting data we attached to the segue.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BMLTNAMeetingSearchAddressViewController {
            if let node = sender as? BMLTiOSLibMeetingNode {
                destination.meetingObject = node
                destination.searchCenterCoords = self.searchCenterCoords
            }
        }
        super.prepare(for: segue, sender: nil)
    }
    
    /* ################################################################## */
    /**
     Make sure we recalculate our table if things have changed.
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self._resultsTable.reloadData()
    }
    
    /* ################################################################## */
    // MARK: IBAction Methods
    /* ################################################################## */
    /**
     */
    @IBAction func _sortChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        self._sortResults(1 == selectedIndex)
    }
    
    /* ################################################################## */
    // MARK: Private Instance Methods
    /* ################################################################## */
    /**
     This sorts the results, according to the selector switch.
     
     - parameter inByDistance: This is true, if the switch is set to "Sort by Distance".
     */
    private func _sortResults(_ inByDistance: Bool) {
        BMLTNAMeetingSearchPrefs.prefs.sortResultsByDistance = inByDistance
        self.searchResultArray = self.searchResultArray.sorted(by: {
            if inByDistance {
                return $0.distanceInKm < $1.distanceInKm
            } else {
                let firstWeekday = Calendar.current.firstWeekday
                var weekday1 = $0.weekdayIndex - firstWeekday
                var weekday2 = $1.weekdayIndex - firstWeekday
                
                if 0 > weekday1 {
                    weekday1 += 7
                }
                
                if 0 > weekday2 {
                    weekday2 += 7
                }
                
                if 0 == weekday1 && 6 == weekday2 {
                    return false
                } else {
                    if 6 == weekday1 && 0 == weekday2 {
                        return true
                    } else {
                        if weekday1 != weekday2 {
                            return weekday1 < weekday2
                        } else {
                            let startTime1 = $0.startTime
                            let startTime2 = $1.startTime
                            
                            let startTimeAsInteger1 = ((startTime1?.hour)! * 100) + (startTime1?.minute)!
                            let startTimeAsInteger2 = ((startTime2?.hour)! * 100) + (startTime2?.minute)!
                            
                            return startTimeAsInteger1 < startTimeAsInteger2
                        }
                    }
                }
            }
        })
        
        self._resultsTable.reloadData()
    }
    
    /* ################################################################## */
    /**
     This will bring in a detailed meeting view for the selected meeting.
     
     - parameter inMeetingObject: The meeting object to display.
     */
    private func _showMeetingDetails(_ inMeetingObject: BMLTiOSLibMeetingNode) {
        self.performSegue(withIdentifier: type(of: self)._sShowDetailSegueID, sender: inMeetingObject)
    }
    
    /* ################################################################## */
    // MARK: UITableViewDataSource Protocol Methods
    /* ################################################################## */
    /**
     Returns the number of meetings to be displayed.
     
     - parameter tableView: The UITableView that called this
     - parameter numberOfRowsInSection: The section being checked (0-based index)
     
     - returns: The number of rows that correspond to the section (in this case, the count of meetings to display).
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResultArray.count
    }
    
    /* ################################################################## */
    /**
     Returns a cell object that represents a single meeting.
     
     - parameter tableView: The UITableView that called this
     - parameter cellForRowAt: The section row, as an IndexPath (0-based, and we only have 1 section -0).

     - returns: A new UITableViewCell object for the given meeting.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meeting = self.searchResultArray[indexPath.row]
        let reuseID: String = String(meeting.id)
        
        let ret = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseID)
        if let cell = UINib(nibName: "BMLTNAMeetingSearchResultsTableCell", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? BMLTNAMeetingSearchResultsTableCellView {
            cell.meetingDescriptionTextView.text = meeting.description
            var distance: Double = 0
            let distanceFormat = NSLocalizedString("BMLTNAMeetingSearch-DistanceFormat", comment: "")
            let units = BMLTNAMeetingSearchPrefs.prefs.distanceUnits
            
            if "BMLTNAMeetingSearch-DistanceUnitsMiles" == units {
                distance = meeting.distanceInMiles
            } else {
                if "BMLTNAMeetingSearch-DistanceUnitsKm" == units {
                    distance = meeting.distanceInKm
                }
            }
            cell.distanceLabel.text = String(format: distanceFormat, distance) + NSLocalizedString(units, comment: "")
            var bounds: CGRect = CGRect.zero
            bounds.size.height = tableView.rowHeight
            bounds.size.width = tableView.bounds.size.width
            if 0 == (indexPath.row % 2) {
                let backgroundColor = self.view.tintColor.withAlphaComponent(0.1)
                ret.backgroundColor = backgroundColor
            } else {
                ret.backgroundColor = UIColor.clear
            }
            ret.bounds = bounds
            cell.frame = bounds
            ret.addSubview(cell)
        }
        
        return ret
    }
    
    /* ################################################################## */
    // MARK: UITableViewDelegate Protocol Methods
    /* ################################################################## */
    /**
     This reacts to a table row being selected.
     It will bring in a detail screen for the selected meeting.
     
     - parameter tableView: The UITableView that called this
     - parameter didSelectRowAt: The section row, as an IndexPath (0-based, and we only have 1 section -0).
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meeting = self.searchResultArray[indexPath.row]
        
        self._showMeetingDetails(meeting)
    }
}

/* ###################################################################################################################################### */
/* ###################################################################################################################################### */
/**
 */
class BMLTNAMeetingSearchResultsTableCellView: UIView {
    /// The text view for the meeting description.
    @IBOutlet weak var meetingDescriptionTextView: UITextView!
    /// The label that displays the distance from the search center.
    @IBOutlet weak var distanceLabel: UILabel!
}
