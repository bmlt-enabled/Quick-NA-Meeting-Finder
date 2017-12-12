//
//  BMLTNAMeetingSearchSettingsViewController.swift
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
import BMLTiOSLib

/* ###################################################################################################################################### */
// MARK: - Meeting Search Settings View Controller -
/* ###################################################################################################################################### */
/**
 */
class BMLTNAMeetingSearchSettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    /** This is the overall section label for the "Grace Period" Setting. */
    @IBOutlet weak var graceTimeSectionLabel: UILabel!
    /** This is the textual dexcription of that section. */
    @IBOutlet weak var graceTimeDescriptiveTextView: UITextView!
    /** This is the label that goes just over the Grace Time picker. */
    @IBOutlet weak var graceTimePickerLabel: UILabel!
    /** This is the picker view for selecting a Grace Time. */
    @IBOutlet weak var graceTimePicker: UIPickerView!
    /** This is the main explanation text item. */
    @IBOutlet weak var explainText: UITextView!
    
    /* ################################################################## */
    // MARK: Private Instance Methods
    /* ################################################################## */
    /**
     Matches a row index to a value.
     
     - parameter inRow: The row index
     - returns: A value for a given picker row index.
     */
    private func _getPickerValueForRow (_ inRow: Int) -> Int {
        
        var pickerValue: String = ""
        
        switch inRow {
        case 0:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-00", comment: "")
        case 1:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-01", comment: "")
        case 2:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-02", comment: "")
        case 3:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-03", comment: "")
        case 4:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-04", comment: "")
        case 5:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-05", comment: "")
        case 6:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Value-06", comment: "")
        default:
            pickerValue = "0"
        }
        
        var ret: Int = 0
        
        if let pickerIntValue = Int(pickerValue) {
            ret = pickerIntValue
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     Matches a value to a row index (opposite of above).
     
     - parameter inValue: The value
     - returns: A row index for a given value. -1 if no row matched the value.
     */
    private func _getPickerRowForValue (_ inValue: Int) -> Int {
        var ret: Int = -1
        
        for i in 0..<self.pickerView(self.graceTimePicker, numberOfRowsInComponent: 0) {
            let value = self._getPickerValueForRow(i)
            
            if value == inValue {
                ret = i
                
                break
            }
        }
        
        return ret
    }
    
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
        
        if let labelText = self.graceTimeSectionLabel.text {
            self.graceTimeSectionLabel.text = NSLocalizedString(labelText, comment: "")
        }
        
        if let descriptiveText = self.graceTimeDescriptiveTextView.text {
            self.graceTimeDescriptiveTextView.text = NSLocalizedString(descriptiveText, comment: "")
        }
        
        if let labelText = self.graceTimePickerLabel.text {
            self.graceTimePickerLabel.text = NSLocalizedString(labelText, comment: "")
        }
        
        let defaultRow = self._getPickerRowForValue(BMLTNAMeetingSearchPrefs.prefs.gracePeriodInMinutes)
        
        if 0 <= defaultRow {
            self.graceTimePicker.selectRow(defaultRow, inComponent: 0, animated: false)
        }
        
        if let textItemText = self.explainText.text {
            self.explainText.text = NSLocalizedString(textItemText, comment: "")
        }
    }

    /* ################################################################## */
    /**
     We use this to make sure our NavBar is shown.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        super.viewWillAppear(animated)
    }
    
    /* ################################################################## */
    // MARK: UIPickerViewDataSource Methods
    /* ################################################################## */
    /**
     We only have 1 component.
     
     - parameter pickerView: The UIPickerView being checked
     
     - returns: 1
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /* ################################################################## */
    /**
     We have 7 possible values.
     
     - parameter pickerView: The UIPickerView being checked
     
     - returns: 7
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
    
    /* ################################################################## */
    // MARK: UIPickerViewDelegate Methods
    /* ################################################################## */
    /**
     This returns the name for the given row.
     
     - parameter pickerView: The UIPickerView being checked
     - parameter row: The row being checked
     - parameter forComponent: The component (always 0)
     - parameter reusing: If the view is being reused, it is passed in here.
     
     - returns: a view, containing a label with the string for the row.
     */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let size = pickerView.rowSize(forComponent: 0)
        var frame = pickerView.bounds
        frame.size.height = size.height
        frame.origin = CGPoint.zero
        
        var pickerValue: String = ""
        
        switch row {
        case 0:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-00", comment: "")
        case 1:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-01", comment: "")
        case 2:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-02", comment: "")
        case 3:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-03", comment: "")
        case 4:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-04", comment: "")
        case 5:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-05", comment: "")
        case 6:
            pickerValue = NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Text-06", comment: "")
        default:
            pickerValue = "ERROR"
        }
        
        let ret = UIView(frame: frame)
        
        ret.backgroundColor = UIColor.clear
        
        let label = UILabel(frame: frame)
        
        label.textAlignment = NSTextAlignment.center
        
        label.backgroundColor = self.view.tintColor.withAlphaComponent(0.5)
        label.textColor = UIColor.white
        label.text = pickerValue
        
        ret.addSubview(label)
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This is called when the user finishes selecting a row.
     We use this to add the selected town to the filter.
     
     If it is one of the top 2 rows, we select the first row, and ignore it.
     
     :param: pickerView The UIPickerView being checked
     :param: row The row being checked
     :param: component The component (always 0)
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        BMLTNAMeetingSearchPrefs.prefs.gracePeriodInMinutes = self._getPickerValueForRow(row)
    }
}
