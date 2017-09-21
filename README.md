NA Meeting Finder iOS App
=========================

This app began life as a simple demo app of the BMLTiOSLib, but was deemed so full of WIN that it deserves its own existence.

It's a *VERY* simple app that has just one button. Pressing it locates you, and then finds nearby meetings that will be available either later today or tomorrow.

The whole idea of the app is to remove decision points for the user. Present a simple, straightforward path that gives them exactly the information they need to find an NA meeting.

CHANGELIST
----------
***Version 1.2.0.3001* ** *- September 21, 2017*

- App Store Submission (Fixed location bug).

***Version 1.2.0.3000* ** *- September 20, 2017*

- App Store Submission.

***Version 1.2.0.2001* ** *- September 13, 2017*

- Added a check to see if the app has localization enabled before starting.

***Version 1.2.0.2000* ** *- September 13, 2017*

- Added some basic fixes to make the app more responsive.
- Compiled for iOS 11.
- Added a link to the new instructions page.
- First App Store beta release.

***Version 1.1.0.3000* ** *- June 19, 2017*

- Updated with the new permanent Server, and store release.
- Now make sure to terminate any in-process operations, so we won't get that "Communication Error" when reopening the app.

***Version 1.1.0.2005* ** *- April 9, 2017*

- Fixed an issue where older datasets caused a parse failure.

***Version 1.1.0.2004* ** *- April 8, 2017*

- Changed some of the text in the Settings and About dialogs to be a bit more usable and relevant.

***Version 1.1.0.2003* ** *- April 4, 2017*

- Fixed a bug that forced distance units to always be miles.

***Version 1.1.0.2002* ** *- March 27, 2017*

- Made the Service Body Read even more robust.

***Version 1.1.0.2001* ** *- March 22, 2017*

- Made the Service Body Read more robust.

***Version 1.1.0.2000* ** *- March 22, 2017*

- First worldwide beta.

***Version 1.1.0.1000* ** *- March 10, 2017*

- Added the new BMLT Aggregator as the Root Server URI.

***Version 1.0.1.3000* ** *- March 10, 2017*

- Uses the new deliverable format of the BMLTiOSLib
- Now automatically starts a search if the main window is shown.
- Formal release.

***Version 1.0.0.3000* ** *- January 16, 2017*

- First release to app store.
- Turned the development system error-checking to "11".

***Version 1.0.0.2004* ** *- January 15, 2017*

- The animation was going in the wrong direction. That's been fixed.

***Version 1.0.0.2003* ** *- January 15, 2017*

- Removed the interim step. You go straight to More Info now.
- Made the grace time picker a bit more obvious. It looked too much like standard text.
- Now use "stripes" to separate the table rows, as opposed to lines.

***Version 1.0.0.2002* ** *- January 15, 2017*

- The BMLTiOSLibDelegate protocol now has almost all its functions optional. Removed the unused required functions.
- Added directions (displayed on a map).
- The app now requires iOS 10 or above (because of the directions API).
- Since we now require iOS 10, I had to tweak a URL callout to replace a deprecated configuration.
- Added a Nicki Minaj background gradient, as folks figured the old, more subdued gradient was difficult to read.

***Version 1.0.0.2001* ** *- January 14, 2017*

- Added the silly CYA plist thing that says I'm not consorting with turrists using encryption.

***Version 1.0.0.2000* ** *- January 14, 2017*

- First Beta Release of the BMLTiOSLib Project, which includes the first beta release of this project.
