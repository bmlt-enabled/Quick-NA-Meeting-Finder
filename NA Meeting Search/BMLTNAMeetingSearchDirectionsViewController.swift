//
//  BMLTNAMeetingSearchDirectionsViewController.swift
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
// MARK: - Meeting Search Meeting Details View Controller -
/* ###################################################################################################################################### */
/**
 This class will display the name of the meeting, and a large map object that will display the directions.
 */
class BMLTNAMeetingSearchDirectionsViewController : UIViewController, MKMapViewDelegate {
    /* ################################################################## */
    // MARK: IB Instance Properties
    /* ################################################################## */
    /** This is the name of the meeting */
    @IBOutlet weak var meetingNameLabel: UILabel!
    /** This is the map view that will show the directions. */
    @IBOutlet weak var directionsMapView: MKMapView!
    /** This is displayed while the directions are being looked up. */
    @IBOutlet weak var busyView: UIView!
    
    /* ################################################################## */
    // MARK: Internal Instance Properties
    /* ################################################################## */
    /** This is the object that contains our meeting data. */
    var meetingObject: BMLTiOSLibMeetingNode! = nil
    /** This is the location of the search center. We use this to create a map with the right zoom. */
    var searchCenterCoords: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
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
        
        // Set the meeting name.
        self.meetingNameLabel.text = self.meetingObject.name
        
        self.setUpMap()
    }
    
    /* ################################################################## */
    // MARK: Internal Instance Methods
    /* ################################################################## */
    /**
     This calculates a region that fits both the current user location and the meeting location.
     
     - returns: A region that should fit both.
     */
    var regionThatFitsBothUserLocationAndMeetingLocation: MKCoordinateRegion {
        get {
            if let meetingCoords = self.meetingObject.locationCoords {
                let myCoords = self.searchCenterCoords
                // First, describe a rectangle that contains our two points.
                let maxLong = max(meetingCoords.longitude, myCoords.longitude)
                let minLong = min(meetingCoords.longitude, myCoords.longitude)
                let maxLat = max(meetingCoords.latitude, myCoords.latitude)
                let minLat = min(meetingCoords.latitude, myCoords.latitude)
                
                let topLeft: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: maxLat, longitude: minLong)
                let bottomRight: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: minLat, longitude: maxLong)
                
                var region: MKCoordinateRegion = MKCoordinateRegion()
                
                // Simple average to get the center.
                region.center.latitude = (topLeft.latitude + bottomRight.latitude) / 2.0
                region.center.longitude = (topLeft.longitude + bottomRight.longitude) / 2.0
                // We multiply by 2.5, because that gives us enough slop.
                region.span.latitudeDelta = fabs(topLeft.latitude - bottomRight.latitude) * 2.5
                region.span.longitudeDelta = fabs(bottomRight.longitude - topLeft.longitude) * 2.5
                
                return self.directionsMapView.regionThatFits(region)
            }
            
            // If the above fails, we just return the map region.
            return self.directionsMapView.region
        }
    }
    
    /* ################################################################## */
    /**
     Set up our map to show the meeting location.
     */
    func setUpMap() {
        if nil != self.directionsMapView {
            if let mapLocation = self.meetingObject.locationCoords {
                let mapAnnotation = BMLTNAMeetingSearchAnnotation(coordinate: mapLocation, meetings: [self.meetingObject])
                let yahAnnotation = BMLTNAMeetingSearchAnnotation(coordinate: self.searchCenterCoords)
                mapAnnotation.title = NSLocalizedString("DETAILS-SCREEN-MAP-INFO-TEXT", comment: "")
                yahAnnotation.title = NSLocalizedString("DETAILS-SCREEN-MAP-YAH-INFO-TEXT", comment: "")
                self.directionsMapView.addAnnotation(yahAnnotation)
                self.directionsMapView.addAnnotation(mapAnnotation)
                self.directionsMapView.setRegion(self.regionThatFitsBothUserLocationAndMeetingLocation, animated: false)
                
                if let meetingCoords = self.meetingObject.locationCoords {
                    let myCoords = self.searchCenterCoords
                    let mePlacemark = MKPlacemark(coordinate: myCoords)
                    let meetingPlacemark = MKPlacemark(coordinate: meetingCoords)
                    let directionsRequest = MKDirectionsRequest()
                    directionsRequest.destination = MKMapItem(placemark: meetingPlacemark)
                    directionsRequest.source = MKMapItem(placemark: mePlacemark)
                    
                    let directions = MKDirections(request: directionsRequest)
                    
                    directions.calculate(completionHandler: { (response, error) in
                        self.busyView.isHidden = true
                        if nil == error {
                            if let hardResponse = response {
                                var overlays: [MKOverlay] = []
                                for route in hardResponse.routes {
                                    let overlayLine = route.polyline
                                    overlays.append(overlayLine)
                                }
                                if 0 < overlays.count {
                                    self.directionsMapView.addOverlays(overlays, level: MKOverlayLevel.aboveRoads)
                                }
                            }
                        } else {
                            BMLTNAMeetingSearchInitialViewController._displayErrorAlert("BMLTNAMeetingSearchError-FailedDirectionsHeader", inMessage: "BMLTNAMeetingSearchError-NoDirectionsResultsText", presentedBy: self)
                        }
                    })
                }
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
            let myAnnotation = annotation as! BMLTNAMeetingSearchAnnotation
            let markerView = BMLTNAMeetingSearchMarker(annotation: myAnnotation, draggable: false, reuseID: reuseID)
            return markerView
        }
        
        return nil
    }
    
    /* ################################################################## */
    /**
     This renders the directions polylines.
     
     - parameter mapView: The map view object
     - parameter rendererFor: The overlay to be rendered.
     
     - returns: a new renderer for the overlay.
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = self.view.tintColor
            polylineRenderer.lineWidth = 2
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
}

