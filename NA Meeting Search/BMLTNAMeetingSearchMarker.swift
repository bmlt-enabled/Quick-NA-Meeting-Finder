//
//  BMLTNAMeetingSearchMarker.swift
//  BMLTiOSLib
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

/**
 This file contains a couple of classes that allow us to establish and manipulate markers in our map.
 */

import MapKit
import BMLTiOSLib

/** Points to an array of meetings. */
typealias BMLTNAMeetingSearchMeetingList = [BMLTiOSLibMeetingNode]

// MARK: - Classes -
/* ###################################################################################################################################### */
/**
 This handles the marker annotation.
 */
class BMLTNAMeetingSearchAnnotation : NSObject, MKAnnotation, NSCoding {
    let sCoordinateObjectKey: String = "BMLTNAMeetingSearchAnnotation_Coordinate"
    let sMeetingsObjectKey: String = "BMLTNAMeetingSearchAnnotation_Meetings"
    let sTitleObjectKey: String = "BMLTNAMeetingSearchAnnotation_Title"
    
    @objc var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    @objc var meetings: BMLTNAMeetingSearchMeetingList = []
    @objc var title: String? = nil
    
    /* ################################################################## */
    /**
     Convenience initializer.
     
     :param: coordinate the coordinate for this annotation display.
     */
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(coordinate: coordinate, meetings: [])
    }
    
    /* ################################################################## */
    /**
     Default initializer.
     
     :param: coordinate the coordinate for this annotation display.
     :param: meetings a list of meetings to be assigned to this annotation.
     */
    init(coordinate: CLLocationCoordinate2D, meetings: BMLTNAMeetingSearchMeetingList) {
        self.coordinate = coordinate
        self.meetings = meetings
    }
    
    // MARK: - NSCoding Protocol Methods -
    /* ################################################################## */
    /**
     This method will restore the meetings and coordinate objects from the coder passed in.
     
     :param: aDecoder The coder that will contain the coordinates.
     */
    @objc required init?(coder aDecoder: NSCoder) {
        if let temp = aDecoder.decodeObject(forKey: self.sTitleObjectKey) as? String {
            self.title = temp
        } else {
            self.title = nil
        }
        self.meetings = aDecoder.decodeObject(forKey: self.sMeetingsObjectKey) as! BMLTNAMeetingSearchMeetingList
        if let tempCoordinate = aDecoder.decodeObject(forKey: self.sCoordinateObjectKey) as! [NSNumber]! {
            self.coordinate.longitude = tempCoordinate[0].doubleValue
            self.coordinate.latitude = tempCoordinate[1].doubleValue
        }
    }
    
    /* ################################################################## */
    /**
     This method saves the meetings and coordinates as part of the serialization.
     
     :param: aCoder The coder that contains the coordinates.
     */
    @objc func encode(with aCoder: NSCoder) {
        let long: NSNumber = NSNumber(value: self.coordinate.longitude as Double)
        let lat: NSNumber = NSNumber(value: self.coordinate.latitude as Double)
        let values: [NSNumber] = [long, lat]
        
        aCoder.encode(values, forKey: self.sCoordinateObjectKey)
        aCoder.encode(self.meetings, forKey: self.sMeetingsObjectKey)
        if nil != self.title {
            aCoder.encode(self.title, forKey: self.sTitleObjectKey)
        }
    }
}

/* ###################################################################################################################################### */
/**
 This handles our map marker.
 */
class BMLTNAMeetingSearchMarker : MKAnnotationView {
    /* ################################################################## */
    // MARK: Internal Static Properties
    /* ################################################################## */
    /** The coder key */
    let sAnnotationObjectKey: String = "BMLTNAMeetingSearchMarker_Annotation"
    /** This is how many display units to shift the annotation view up. */
    let sRegularAnnotationOffsetUp: CGFloat     = 24;
    /** This is how many display units to shift the annotation view right. */
    let sRegularAnnotationOffsetRight: CGFloat  = 5;

    /* ################################################################## */
    // MARK: Internal Instance Properties
    /* ################################################################## */
    /** In an animation (dragging the current frame. */
    var currentFrame: Int = 0
    /** The timer used for animation. */
    var animationTimer: Timer! = nil
    /** The frames to be drawn during an animation. */
    var animationFrames: [UIImage] = []
    
    /* ################################################################## */
    // MARK: Internal Computed Properties
    /* ################################################################## */
    /**
     We override this, so we can be sure to refresh the need for a draw state when draggable is set (Meaning it's a black marker).
     */
    override var isDraggable: Bool {
        get {
            return super.isDraggable
        }
        
        set {
            // You can only drag if there are no meetings, or just one meeting.
            if 2 > self.meetings.count {
                super.isDraggable = newValue
            } else {
                super.isDraggable = false
            }
            
            if !super.isDraggable {
                self.animationFrames = []
            }
            
            self.setNeedsDisplay()
        }
    }
    
    /* ################################################################## */
    /**
     This gives us a shortcut to the annotation prpoerty.
     */
    var coordinate: CLLocationCoordinate2D {
        get {
            return (self.annotation?.coordinate)!
        }
    }
    
    /* ################################################################## */
    /**
     This gives us a shortcut to the annotation prpoerty.
     */
    var meetings: BMLTNAMeetingSearchMeetingList {
        get {
            return ((self.annotation as! BMLTNAMeetingSearchAnnotation).meetings)
        }
    }
    
    /* ################################################################## */
    // MARK: Internal Instance Methods
    /* ################################################################## */
    /**
     The default initializer.
     
     - parameter annotation: The annotation that represents this instance.
     - parameter draggable: If true, then this will be draggable (ignored if the annotation has more than one meeting).
     - parameter reuseID: The reuse ID of the annotation.
     */
    init(annotation: MKAnnotation?, draggable : Bool, reuseID: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseID)
        if nil != annotation?.title {
            self.canShowCallout = true
        }
        self.isDraggable = draggable
        self.backgroundColor = UIColor.clear
        self.image = self.selectImage(false)
        self.centerOffset = CGPoint(x: self.sRegularAnnotationOffsetRight, y: -self.sRegularAnnotationOffsetUp)
    }
    
    /* ################################################################## */
    /**
     This selects the appropriate image for our display.
     - parameter inAnimated: If true, then the drag will be animated.
     */
    func selectImage(_ inAnimated: Bool) -> UIImage! {
        var image: UIImage! = nil
        if self.isDraggable && (2 > self.meetings.count) {
            if self.dragState == MKAnnotationViewDragState.dragging {
                if inAnimated {
                    image = self.animationFrames[self.currentFrame]
                } else {
                    image = UIImage(named: "MapMarkerGreen", in: nil, compatibleWith: nil)
                }
            } else {
                image = UIImage(named: "MapMarkerBlack", in: nil, compatibleWith: nil)
            }
        } else {
            if 0 < self.meetings.count {
                if self.isSelected {
                    image = UIImage(named: "MapMarkerGreen", in: nil, compatibleWith: nil)
                } else {
                    if 1 < self.meetings.count {
                        image = UIImage(named: "MapMarkerRed", in: nil, compatibleWith: nil)
                    } else {
                        image = UIImage(named: "MapMarkerBlue", in: nil, compatibleWith: nil)
                    }
                }
            } else {
                image = UIImage(named: "MapMarkerBlack", in: nil, compatibleWith: nil)
            }
        }
        
        return image
    }
    
    /* ################################################################## */
    // MARK: Base Class Override Methods
    /* ################################################################## */
    /**
     Draws the image for the marker.
     
     - parameter rect: The rectangle in which this is to be drawn.
     */
    override func draw(_ rect: CGRect) {
        let image = self.selectImage(0 < self.animationFrames.count)
        if nil != image {
            image!.draw(in: rect)
        }
    }
    
    /* ################################################################## */
    /**
     Sets the drag state for this marker.
     
     - parameter newDragState: The new state that should be set after this call.
     - parameter animated: True, if the state change is to be animated (ignored).
     */
    override func setDragState(_ newDragState: MKAnnotationViewDragState, animated: Bool) {
        var subsequentDragState = MKAnnotationViewDragState.none
        switch newDragState {
        case MKAnnotationViewDragState.starting:
            subsequentDragState = MKAnnotationViewDragState.dragging
            self.currentFrame = 0
            self.animationFrames = []
            
        case MKAnnotationViewDragState.dragging:
            if animated && (0 == self.animationFrames.count) {
                // Set up the drag animation.
                // We have 10 frames in the drag animation.
                for c in 1 ..< 11 {
                    // Construct an image name for each frame.
                    var imageName = "Frame"
                    if 10 > c {
                        imageName += "0"
                    }
                    
                    imageName += String(c)
                    
                    if let image = UIImage(named: imageName, in: nil, compatibleWith: nil) {
                        self.animationFrames.append(image)
                    }
                }
            }
            
            _ = self.selectImage(true)
            self.currentFrame += 1
            subsequentDragState = MKAnnotationViewDragState.dragging
            if self.currentFrame == self.animationFrames.count {
                self.currentFrame = 0
            }

        default:
            subsequentDragState = MKAnnotationViewDragState.none
        }
        
        super.dragState = subsequentDragState
        self.setNeedsDisplay()
    }
    
    /* ################################################################## */
    // MARK: NSCoding Protocol Methods
    /* ################################################################## */
    /**
     This class will restore its meeting object from the coder passed in.
     
     - parameter coder: The coder that will contain the meeting.
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.annotation = aDecoder.decodeObject(forKey: self.sAnnotationObjectKey) as! BMLTNAMeetingSearchAnnotation
    }
    
    /* ################################################################## */
    /**
     This method saves the meetings and coordinates as part of the serialization.
     
     - parameter with: The coder that contains the coordinates.
     */
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.annotation, forKey: self.sAnnotationObjectKey)
        super.encode(with: aCoder)
    }
}
