//
//  BMLTNAMeetingSearchResultViewController.swift
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
        
        self._sortResults(BMLTNAMeetingSearchPrefs.prefs.sortResultsByDistance)
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
        self._sortResults((1 == selectedIndex))
    }
    
    /* ################################################################## */
    // MARK: Private Instance Methods
    /* ################################################################## */
    /**
     */
    private func _sortResults(_ inByDistance: Bool) {
        BMLTNAMeetingSearchPrefs.prefs.sortResultsByDistance = inByDistance
        let resultArray = self.searchResultArray.sorted(by: {
            if inByDistance {
                return $0.distanceInKm < $1.distanceInKm
            } else {
                return $0.timeDayAsInteger < $1.timeDayAsInteger
            }
        })
        
        self.searchResultArray = resultArray
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
        
        let ret = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseID)
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
    @IBOutlet weak var meetingDescriptionTextView: UITextView!
    @IBOutlet weak var distanceLabel: UILabel!
}
