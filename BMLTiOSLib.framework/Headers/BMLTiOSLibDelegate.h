//
//  BMLTiOSLibDelegate.h
//  BMLTiOSLib
//
//  Created by MAGSHARE
//
//  https://bmlt.magshare.net/bmltioslib/
//
//  This software is licensed under the MIT License.
//  Copyright (c) 2017 MAGSHARE
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

#ifndef BMLTiOSLib_h
#define BMLTiOSLib_h

#import <Foundation/Foundation.h>

/** Forward declarations for the protocol. */
@class BMLTiOSLib, BMLTiOSLibMeetingNode, BMLTiOSLibFormatNode, BMLTiOSLibChangeNode, BMLTiOSLibEditableMeetingNode, BMLTiOSLibChangedMeeting;

/* ###################################################################################################################################### */
// MARK: - Main Library Interface Class Delegate Protocol -
/* ###################################################################################################################################### */
/**
 This file describes the protocol necessary for a BMLTiOSLibDelegate.
 
 This protocol is required for any class that wants to control an instance of BMLTiOSLib.
 
 Only 2 of these functions are required:
 
     -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance serverIsValid:(BOOL)serverIsValid;
     -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance errorOccurred:(NSError*)errorOccurred;
 
 All the rest are optional.
 
 These are all called in the main thread.
 */
@protocol BMLTiOSLibDelegate <NSObject>
    /** These two methods are required. */
    @required
    
    /* ################################################################## */
    /**
     Indicates whether or not the server pointed to via the URI is a valid server (the connection was successful).
     
     This will be called after the Root Server connection sequence has completed.
     
     This connection sequence consists of:
     
     - Determining the fundamental validity of the URI (Connects to a Root Server). The Root Server MUST run SSL (HTTPS).
     - Determining the fundamental validity of the Root Server (Correct version, supports the proper set of default keys).
     - Loading the full set of available formats (They may not all be in actual use by meetings).
     - Loading the entire set of Service bodies.
     - Loading the entire set of languages available on the Root Server.
     
     By the time this method has been called with serverIsValid as true, the BMLTiOSLib has the following properties set and valid:
     
     - searchCriteria (This will be empty and clear, but available for access).
     - distanceUnits and distanceUnitsString
     - availableMeetingValueKeys (This contains the Dictionary key strings that can access various meeting properties).
     - emailMeetingContactsEnabled (True, if the Server is set to allow emails to be sent to meeting contacts).
     - emailServiceBodyAdminsEnabled (True, if these emails will CC the Service Body Admin for that Service body, as well as the meeting contact -They may be the same email address).
     - changeDepth (The number of changes saved per meeting).
     - googleAPIKey (The API key for the Root Server -May not be useful for most other Servers).
     - delegate (That will be the object that was passed in as delegate when the instance was created).
     - rootServerURI
     - versionAsString and versionAInt
     - isAdminAvailable (True, if Semantic Administration is available).
     - defaultLocation (The Root Server's default central location).
     - serviceBodies (This is a "flat" Array of the Service bodies, with no hierarchy).
     - hierarchicalServiceBodies (This maps out the Service bodies in the hierarchy they occupy on the Root Server, and this is just one node with children only -no parents or Service body).
     - allPossibleFormats (an Array of format objects available -May not all be used by the meetings).
     - availableServerLanguages (an Array of language objects).
     
     You can't call any of the BMLTiOSLib communication instance methods until this callback has been invoked with a serverIsValid value of true.
     
     - parameter bmltLibInstance: the BMLTiOSLib instance.
     - parameter serverIsValid: A Bool, true, if the server was successfully connected. If false, you must reinstantiate BMLTiOSLib. You can't re-use the same instance.
     */
    -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance
              serverIsValid:(BOOL)serverIsValid;
    
    /* ################################################################## */
    /**
     Called if there is an error.
     
     The error String will be a key for localization, and will be pretty much worthless on its own.
     
     - parameter bmltLibInstance: the BMLTiOSLib instance.
     - parameter errorOccurred: The error that occurred.
     */
    -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance
              errorOccurred:(NSError*)errorOccurred;

    /** The following methods are all optional (but the library won't do you much good if you don't implement any of them). */
    @optional
    
    /* ################################################################## */
    /**
     Returns the result of a meeting search.
     
     - parameter bmltLibInstance: the BMLTiOSLib instance.
     - parameter meetingSearchResults: An array of BMLTiOSLibMeetingNode, representing the results of a search.
     */
    -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance
       meetingSearchResults:(NSArray*)meetingSearchResults;
    
    /* ################################################################## */
    /**
     Returns the result of a format search.
     
     - parameter bmltLibInstance: the BMLTiOSLib instance.
     - parameter formatSearchResults: An array of BMLTiOSLibFormatNode, representing the results of a search.
     - parameter isAllUsedFormats: This is true, if this is the "all used formats" call, where we generate objects that reflect the formats actually used by any meetings in the entire database (as opposed to simply "available, but not used").
     */
    -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance
        formatSearchResults:(NSArray*)formatSearchResults
           isAllUsedFormats:(BOOL)isAllUsedFormats;
    
    /* ################################################################## */
    /**
     Returns the result of a change list request.
     
     - parameter bmltLibInstance: the BMLTiOSLib instance.
     - parameter changeListResults: An array of BMLTiOSLibChangeNode.
     */
    -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance
          changeListResults:(NSArray*)changeListResults;
    
    /* ################################################################## */
    /**
     Indicates whether or not a Semantic Admin log in or out occurred.
     
     This actually is called when the login state changes (or doesn't change when change is expected).
     This is called in response to a login or logout. It is always called, even if
     the login state did not change.
     
     - parameter bmltLibInstance: the BMLTiOSLib instance.
     - parameter loginChangedTo: A Bool, true, if the session is currently connected.
     */
    -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance
             loginChangedTo:(BOOL)loginChangedTo;
    
    /* ################################################################## */
    /**
     Called when a new meeting has been added, or a deleted meeting has been restored.

     - parameter bmltLibInstance: the BMLTiOSLib instance.
     - parameter newMeetingAdded: Meeting object.
     */
    -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance
            newMeetingAdded:(BMLTiOSLibEditableMeetingNode*)newMeetingAdded;
    
    /* ################################################################## */
    /**
     Called when a new meeting has been rolled back to a previous version.
     
     - parameter bmltLibInstance: the BMLTiOSLib instance.
     - parameter meetingRolledback: Meeting object.
     */
    -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance
          meetingRolledback:(BMLTiOSLibEditableMeetingNode*)meetingRolledback;
    
    /* ################################################################## */
    /**
     Called when a meeting has been edited.
     
     - parameter bmltLibInstance: the BMLTiOSLib instance.
     - parameter adminMeetingChangeComplete: If successful, this will be the changes made to the meeting. nil, if failed.
     */
    -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance
 adminMeetingChangeComplete:(BMLTiOSLibChangedMeeting*)adminMeetingChangeComplete;
    
    /* ################################################################## */
    /**
     Called when a new meeting has been deleted.

     - parameter bmltLibInstance: the BMLTiOSLib instance.
     - parameter deleteMeetingSuccessful: true, if the operation was successful.
     */
    -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance
    deleteMeetingSuccessful:(BOOL)deleteMeetingSuccessful;

    /* ################################################################## */
    /**
     Called when a message has been sent to a meeting contact.

     - parameter bmltLibInstance: the BMLTiOSLib instance.
     - parameter sendMessageSuccessful: true, if the operation was successful.
     */
    -(void) bmltLibInstance:(BMLTiOSLib*)bmltLibInstance
      sendMessageSuccessful:(BOOL)sendMessageSuccessful;
@end
#endif /* BMLTiOSLib_h */
