//
//  BMLTNAMeetingSearchPrefs.swift
//  BMLT NA Meeting Search
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
//

import Foundation

/* ###################################################################################################################################### */
// MARK: - Prefs Class -
/* ###################################################################################################################################### */
/**
 This is a very simple "persistent user prefs" class. It is instantiated as a SINGLETON, and provides a simple, property-oriented gateway
 to the simple persistent user prefs in iOS. It shouldn't be used for really big, important prefs, but is ideal for the basic "settings"
 type of prefs most users set in their "gear" screen.
 */
class BMLTNAMeetingSearchPrefs {
    /* ################################################################## */
    // MARK: Private Static Properties
    /* ################################################################## */
    /** This is the key for the prefs used by this app. */
    private static let _mainPrefsKey: String = "BMLTNAMeetingSearchPrefs"
    
    /* ################################################################## */
    // MARK: Private Variable Properties
    /* ################################################################## */
    /** We load the user prefs into this Dictionary object. */
    private var _loadedPrefs: NSMutableDictionary! = nil
    /** This is how we enforce a SINGLETON pattern. */
    private static var _sSingletonPrefs: BMLTNAMeetingSearchPrefs! = nil
    
    /* ################################################################## */
    // MARK: Private Enums
    /* ################################################################## */
    /** These are the keys we use for our persistent prefs dictionary. */
    private enum PrefsKeys: String {
        /** This is the Root Server URI */
        case RootServerURI = "rootURI"
        /** This represents how long we allow a meeting to be in progress before we remove it from our list of candidates. */
        case GracePeriod = "gracePeriod"
        /** This represents the units we use for our distance display. The string that is stored and returned in the localization key, not the displayed string. */
        case DistanceUnits = "distanceUnits"
        /** This dictates how the results are sorted. If 0, then they are sorted by time. If 1, they are sorted by distance. */
        case ResultSort = "resultSort"
        /** In the "More Info" screen, the user can select a map type. This is saved here. 0 = standard, 1 = hybrid, 2 = satellite. */
        case DetailsMapType = "detailsMapType"
    }
    
    /* ################################################################## */
    // MARK: Private Initializer
    /* ################################################################## */
    /** We do this to prevent the class from being instantiated in a different context than our controlled one. */
    private init() { /* Sergeant Schultz says: "I do nut'ing. Nut-ING!" */ }

    /* ################################################################## */
    // MARK: Private Instance Methods
    /* ################################################################## */
    /**
     This method simply saves the main preferences Dictionary into the standard user defaults.
     */
    private func _savePrefs() {
        UserDefaults.standard.set(self._loadedPrefs, forKey: type(of: self)._mainPrefsKey)
    }
    
    /* ################################################################## */
    /**
     This method loads the main prefs into our instance storage.
     
     NOTE: This will overwrite any unsaved changes to the current _loadedPrefs property.
     
     - returns: a Bool. True, if the load was successful.
     */
    private func _loadPrefs() -> Bool {
        if let temp = UserDefaults.standard.object(forKey: type(of: self)._mainPrefsKey) as? NSDictionary {
            self._loadedPrefs = NSMutableDictionary(dictionary: temp)
        } else {
            self._loadedPrefs = NSMutableDictionary()
        }
        
        return nil != self._loadedPrefs
    }
    
    /* ################################################################## */
    // MARK: Class Static Properties
    /* ################################################################## */
    /**
     This is how the singleton instance is instantiated and accessed. Always use this variable to capture the prefs object.
     
     The syntax is:
     
         let myPrefs = BMLTNAMeetingSearchPrefs.prefs
     */
    static var prefs: BMLTNAMeetingSearchPrefs {
        if nil == self._sSingletonPrefs {
            self._sSingletonPrefs = BMLTNAMeetingSearchPrefs()
        }
        
        return self._sSingletonPrefs
    }
    
    /* ################################################################## */
    /**
     This tells us whether or not the device is set for military time.
     */
    static var using12hClockFormat: Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let dateString = formatter.string(from: Date())
        let amRange = dateString.range(of: formatter.amSymbol)
        let pmRange = dateString.range(of: formatter.pmSymbol)
        
        return !(pmRange == nil && amRange == nil)
    }
    
    /* ################################################################## */
    /**
     This tells us whether or not the device is set for kilometers.
     */
    static var usingKilometeres: Bool {
        let locale = NSLocale.current
        return locale.usesMetricSystem
    }
    
    /* ################################################################## */
    // MARK: Instance Static Methods
    /* ################################################################## */
    /**
     Gets a localized version of the weekday name from an index.
     
     Cribbed from Here: http://stackoverflow.com/questions/7330420/how-do-i-get-the-name-of-a-day-of-the-week-in-the-users-locale#answer-34289913
     
     - parameter weekdayNumber: 1-based index (1 - 7)
     
     - returns: The localized, full-length weekday name.
     */
    class func weekdayNameFromWeekdayNumber(_ weekdayNumber: Int) -> String {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.weekdaySymbols
        let firstWeekday = calendar.firstWeekday - 1
        let weekdayIndex = weekdayNumber - 1
        let index = weekdayIndex + firstWeekday
        return weekdaySymbols[index]
    }

    /* ################################################################## */
    // MARK: Instance Calculated Properties
    /* ################################################################## */
    /**
     This is a read-only property, as the value is read from the plist file.
     
     - returns: the selected Root Server URI, as a String.
     */
    var rootURI: String {
        if let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
                if let uri = plistDictionary["BMLTRootServerURI"] as? NSString {
                    return uri as String
                }
            }
        }
        
        return ""
    }
    
    /* ################################################################## */
    /**
     - returns: the selected Distance Units, as a String.
     */
    var distanceUnits: String {
        get {
            var ret: String = type(of: self).usingKilometeres ? "BMLTNAMeetingSearch-DistanceUnitsKm" : "BMLTNAMeetingSearch-DistanceUnitsMiles"
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.DistanceUnits.rawValue) as? String {
                    ret = temp
                } else {
                    self._loadedPrefs.setObject(ret, forKey: PrefsKeys.DistanceUnits.rawValue as NSString)
                }
            }
            
            return ret
        }
        
        set {
            if self._loadPrefs() {
                if newValue.isEmpty {
                    self._loadedPrefs.removeObject(forKey: PrefsKeys.DistanceUnits.rawValue)
                } else {
                    self._loadedPrefs.setObject(newValue, forKey: PrefsKeys.DistanceUnits.rawValue as NSString)
                }
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     - returns: the "grace period" we give meetings (How long they have to already be running before we decide not to attend).
     */
    var gracePeriodInMinutes: Int {
        get {
            if var ret: Int = Int(NSLocalizedString("BMLTNAMeetingSearch-Settings-GraceTime-Picker-Default-Value", comment: "")) {
                if self._loadPrefs() {
                    if let temp = self._loadedPrefs.object(forKey: PrefsKeys.GracePeriod.rawValue) as? NSNumber {
                        ret = temp.intValue
                    } else {
                        self._loadedPrefs.setObject(NSNumber(value: ret), forKey: PrefsKeys.GracePeriod.rawValue as NSString)
                    }
                }
                
                return ret
            } else {
                self._loadedPrefs.setObject(NSNumber(value: 0), forKey: PrefsKeys.GracePeriod.rawValue as NSString)
                return 0
            }
        }
        
        set {
            if self._loadPrefs() {
                let value = NSNumber(value: newValue)
                self._loadedPrefs.setObject(value, forKey: PrefsKeys.GracePeriod.rawValue as NSString)
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     Should we sort meetings by distance? If false, we sort by day and time. Default is false.
     
     - returns: True, if we are to sort by distance. False, if we are to sort by weekday and time.
     */
    var sortResultsByDistance: Bool {
        get {
            var ret: Int = 0   // Default is false
            
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.ResultSort.rawValue) as? NSNumber {
                    ret = temp.intValue
                } else {
                    self._loadedPrefs.setObject(ret as NSNumber, forKey: PrefsKeys.ResultSort.rawValue as NSString)
                }
            }
            
            return 1 == ret
        }
        
        set {
            if self._loadPrefs() {
                let value = newValue ? 1 : 0
                self._loadedPrefs.setObject(value as NSNumber, forKey: PrefsKeys.ResultSort.rawValue as NSString)
                self._savePrefs()
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is the Map type index.
     
     - returns: 0, for standard, 1 for hybrid, and 2 for satellite. Default is hybrid.
     */
    var mapTypeIndex: Int {
        get {
            var ret: Int = 1    // Default is hybrid.
            if self._loadPrefs() {
                if let temp = self._loadedPrefs.object(forKey: PrefsKeys.DetailsMapType.rawValue) as? NSNumber {
                    ret = temp.intValue
                } else {
                    self._loadedPrefs.setObject(NSNumber(value: ret), forKey: PrefsKeys.DetailsMapType.rawValue as NSString)
                }
            }
                
            return ret
        }
        
        set {
            if self._loadPrefs() {
                let value = NSNumber(value: newValue)
                self._loadedPrefs.setObject(value, forKey: PrefsKeys.DetailsMapType.rawValue as NSString)
                self._savePrefs()
            }
        }
    }
}
