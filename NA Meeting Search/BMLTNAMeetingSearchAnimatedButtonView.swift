//
//  BMLTNAMeetingSearchAnimatedButtonView.swift
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
// MARK: - Animated Button Class -
/* ###################################################################################################################################### */
/**
 This is a special class that presents a button. When pressed, it starts animating images with up to 100 frames.
 
 It can be initialized in Interface Builder with a frame prefix (we add a no-leading-zero integer between 0 and 99), and an initial index.
 */
@IBDesignable final class BMLTNAMeetingSearchAnimatedButtonView: UIButton {
    /* ################################################################## */
    // MARK: Private Properties
    /* ################################################################## */
    /** This stores the images we animate. */
    private var _animationFrames: [UIImage] = []
    /** This will be our animation timer. */
    private var _timer: Timer! = nil
    /** This will contain our initial indexed image. */
    private var _initialIndex: Int = 0
    
    /* ################################################################## */
    // MARK: Internal Properties
    /* ################################################################## */
    /** Set to true when we are animating. */
    var isAnimating: Bool = false
    
    /* ################################################################## */
    // MARK: Private Calculated Properties
    /* ################################################################## */
    /**
     This returns the currently indexed image.
     */
    private var _indexedImage: UIImage {
        if 0 < self._animationFrames.count {
            self.currentFrameIndex = max(0, min(self._animationFrames.count - 1, self.currentFrameIndex))
            return self._animationFrames[self.currentFrameIndex]
        } else {    // This is special for Interface Builder, so you see an image.
            let imageName = self.imageNamePrefix + "0"
            return UIImage(named: imageName, in: Bundle(for: type(of: self)), compatibleWith: nil)!
        }
    }
    
    /* ################################################################## */
    /**
     This increments the index, looping it, if necessary, then returns the image at the new index.
     */
    private var _nextIndexedImage: UIImage {
        self.currentFrameIndex += 1
        if self._animationFrames.count == self.currentFrameIndex {
            self.currentFrameIndex = 0
        }
        
        return self._indexedImage
    }
    
    /* ################################################################## */
    // MARK: Internal Inspectable IB Properties
    /* ################################################################## */
    /** This is the initial frame index, and increments to represent the current animation frame. */
    @IBInspectable var currentFrameIndex: Int = 0
    /** This is a prefix for the image names. We will append a no-leading-zero integer to it (0 - 99) */
    @IBInspectable var imageNamePrefix: String = "BMLTNAMeetingSearchAnimatedButtonView/Frame"
    
    /* ################################################################## */
    // MARK: Private Methods
    /* ################################################################## */
    /**
     Increment the current image.
     */
    @objc private func _incrementImage() {
        _ = self._nextIndexedImage
        self.setNeedsDisplay()
    }

    /* ################################################################## */
    /**
     Initial image load.
     */
    private func _loadImages() {
        if 0 == self._animationFrames.count {
            self._initialIndex = self.currentFrameIndex
            for imageNum in 0..<100 {   // No more than 100.
                let imageName: String = self.imageNamePrefix + String(format: "%d", imageNum)
                if let image = UIImage(named: imageName) {
                    self._animationFrames.append(image)
                } else {
                    break
                }
            }
        }
    }
    
    /* ################################################################## */
    // MARK: Internal Methods
    /* ################################################################## */
    /**
     Start animating.
     */
    func startAnimation() {
        if !self.isAnimating {
            self.isAnimating = true
            self.timerCallback()
        }
    }
    
    /* ################################################################## */
    /**
     Stop animating.
     
     - parameter endAnimation: if true, the the index resets to whatever the initial index was. Default is true.
     */
    func stopAnimation(endAnimation: Bool = true) {
        self.isAnimating = false
        self._timer = nil
        if endAnimation {
            self.currentFrameIndex = self._initialIndex
        }
        
        self.setNeedsDisplay()
    }
    
    /* ################################################################## */
    /**
     Increment the current image.
     */
    @objc func timerCallback(_ inTimer: Timer! = nil) {
        if self.isAnimating {
            self._incrementImage()
            self._timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(type(of: self).timerCallback), userInfo: nil, repeats: false)
        }
    }

    /* ################################################################## */
    // MARK: Overridden Methods
    /* ################################################################## */
    /**
     Load all the images.
     */
    override func layoutSubviews() {
        self._loadImages()
        self.setNeedsDisplay()
        super.layoutSubviews()
    }
    
    /* ################################################################## */
    /**
     Draw the current image.
     
     - parameter rect: The rect, in local coordinates, to draw.
     */
    override func draw(_ rect: CGRect) {
        // We can add a highlight overlay.
        if self.isHighlighted {
            self._indexedImage.draw(in: rect)
            let imageName = "BMLTNAMeetingSearchAnimatedButtonView/Highlight"
            if let image = UIImage(named: imageName) {
                image.draw(in: rect)
            }
        } else {    // If there is a different "disabled" image, we use that.
            if !self.isEnabled {
                let imageName = "BMLTNAMeetingSearchAnimatedButtonView/Disabled"
                if let image = UIImage(named: imageName) {
                    image.draw(in: rect)
                } else {
                    self._indexedImage.draw(in: rect)
                }
            } else { // We may use a different image for "at rest."
                if !self.isAnimating {
                    let imageName = "BMLTNAMeetingSearchAnimatedButtonView/Normal"
                    if let image = UIImage(named: imageName) {
                        image.draw(in: rect)
                    } else {
                        self._indexedImage.draw(in: rect)
                    }
                } else {
                    self._indexedImage.draw(in: rect)
                }
            }
        }
    }
}
