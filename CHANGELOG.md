# Scene Graph Developer Extensions

> 10.11.19

## v.2.1

### New Views

#### MediaView

MediaView replaces VideoView and adds support for audio content. MediaView is backward compatible with VideoView and will work with existing SGDEX channels with minimal integration work required. VideoView is now deprecated and will not be maintained in future versions of SGDEX.

### New Features and Enhancements

* When preloading and endcards are enabled in playlist mode, SGDEX will now preload the last item in the playlist while its endcard is visible

### Bug Fixes

* Fixed an issue where an empty endcard was sometimes displayed unexpectedly 
* Fixed an issue where the next video in a playlist sometimes did not preload while the endcard was visible
* Fixed an issue where RAF ads were sometimes played at the wrong time if preloading was turned on

## v.2.0

### New Views

#### SearchView

SearchView gives developers an easy way to add in-channel search functionality to their channels. Search results are displayed in a standard grid so that navigation is familiar to users. SearchView supports all the same ContentHandlers and data loading models as SGDEX's GridView.

#### TimeGridView

TimeGridView gives developers an easy way to display time based data. Just like other views, SGDEX handles the content management for you so that the view remains performant and responsive even when used with large data sets.

#### ParagraphView

ParagraphView combines the functionality of the legacy roParagraphScreen and roCodeRegistrationScreen. Use it to display short bits of text or codes for rendezvous linking.

### New Features and Enhancements

* SGDEX now supports deep linking via roInput. This makes it easier for developers to meet the latest channel certification requirements for deep linking
* All views now support theming of the busy spinner displayed while the view's content is loading
* EntitlementView now supports username/password style authentication
* VideoView now supports theming the BIF focus ring
* GridView now supports mixed aspect ratio posters
* GridView now supports hiding the BoB (the metadata area above the grid posters). When the BoB is hidden, the grid automatically moves upward so that more posters are visible to the user
* GridView now supports adding a colored background when text is overlaid on posters
* GridView now supports setting focus to an empty row

### Bug Fixes

* Fixed an issue in VideoView that could cause erroneous RAF related error messages in the static analysis tool
* Fixed an issue in VideoView that could prevent post-roll ads from playing
* Fixed an issue in VideoView where setting the content field to invalid could cause a crash
* Fixed an issue in VideoView where an unexpected blank endcard could be displayed in single-video mode
* Fixed an issue in GridView that could cause the BoB title to collide with the overhang
* Fixed an issue in CategoryListView where item descriptions might not wrap correctly with some poster shapes
* Fixed an issue in DetailsView where posters could be loaded at full resolution causing unexpected console errors
* Fixed an issue in DetailsView where an unexpected separator character could be appended to the release date when there was no additional text to be displayed 
* Fixed a theme issue where changing the value of OverhangShowOptions could unexpectedly change the height of the overhang

## v.1.1

### Features

#### VideoView

* To help minimize the amount of time buffer screens are visible, the VideoView has a new _preloadContent_ field that enables preflight execution of ContentHandlers and prebuffering of content both before the view is displayed and while endcards are visible.

#### GridView

* The GridView has been updated to use ZoomRowList instead of RowList to improve performance of the component in most scenarios. This change is transparent to developers, it *does not* change the existing GridView interfaces.
* The GridView has a new "zoom" style that leverages ZoomRowList to enable a zoom effect when scrolling between rows.

#### DetailsView

* The DetailsView has a new _itemLoaded_ field that can be observed to find out when the content of the view has changed.

### Sample Channels

* The Roku Billing / SVOD sample has been updated to work with the latest firmware.
* The videos used in the sample channels have been updated to fix some broken stream URLs.
* Fixed an issue in some samples where the video HUD would not appear as expected.

## v.1.0

### Features

 * Initial release.
