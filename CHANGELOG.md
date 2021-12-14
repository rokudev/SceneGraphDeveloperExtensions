# Scene Graph Developer Extensions

> 12.10.21

## v.2.9

### Features

* Support for custom button bars. Developers can now build their own button bars and populate them with the SGDEX ContentManager
* MediaView now supports the posterShape field in audio mode

### Bug Fixes

* Fixed a crash that could happen when using TimeGridView with a very wide, left aligned button bar
* Fixed an issue where the handlerConfigDetails field might not be properly removed when using DetailsView in content list mode
* Fixed an issue where GridView did not always render the releaseDate field correctly
* Fixed an issue where MediaView could display multiple spinners unexpectedly when using a RAFHandler with RokuOS v10.5
    
## v.2.8

### Features

* The DetailsView ContentManager can now be used with custom views
* Improved GridView layout to use the full width of the metadata area
* Improved ButtonBar layout by more precisely calculating button widths
* Improved the stability of logic for caching various item components### Bug Fixes

### Bug Fixes

* Fixed an issue where the currentView field could sometimes have the wrong value inside of wasClosed observers
* Fixed an issue in custom grid views where components other than the grid could not be focused
    
## v.2.7

### Features

* EntitlementView now supports TVOD with Roku Pay
* EntitlementView "RokuBilling" mode has been renamed to "RokuPay_SVOD"
* Custom media views now support custom endcard layouts
* MediaView now supports RAF's setTrackingCallback feature

### Bug Fixes

* Fixed an issue in MediaView where the view might close unexpectedly at the end of a piece of content in playlist mode when using client side ad stitching
* Fixed an issue in MediaView where the value of the currentItem field could be invalid when accessed from a BookmarkHandler if the MdiaView also had a RAFHandler
* Fixed an issue in MediaView where the second track in an audio playlist would sometimes fail to play
* Fixed an issue in MediaView where a custom media view being used in audio mode could sometimes display the default audio UX
* Fixed an issue in MediaView where the RAF counter could be displayed over non-ad content if an ad was interrupted programmatically. For instance, when sending a deep link while an ad was playing.

## v.2.6

### Features

* The MediaView ContentManager can now be used with custom views
* GridView has a new currFocusRow field that can be observed to monitor the vertical movement of the focus ring
* TimeGridView has new jumpToRow and jumpToRowItem fields that can be used to move focus programmatically
* ButtonBar has a new overlay field that can be used to render the ButtonBar in front of the active view rather than moving the view to make room for the ButtonBar
* The rowItemFocused field on SearchView will now indicate when focus moves to the keyboard

### Bug Fixes

* Fixed an issue where the value of m.top.componentController.currentView sometimes contained the wrong value when accessed from a wasShown observer
* Fixed an issue where the background color could change unexpectedly after updating the theme
* Fixed an issue in ButtonBar where setting the updateTheme field did not always work as expected
* Fixed an issue in ButtonBar where certain theme attributes sometimes did not work as expected
* Fixed an issue in ButtonBar where the buttons were not always correctly aligned vertically
* Fixed an issue in MediaView where audio would sometimes not repeat if the screensaver was active
* Fixed an issue in MediaView where playback could fail with using RAF with server stitched ads in playlist mode
* Fixed an issue in MediaView where playback could fail after programmatically changing the control field in playlist mode.
* Fixed an issue in MediaView where an unexpected visual artifact sometimes appeared in audio mode
* Fixed an issue in MediaView that could cause large texture warnings to appear on the console
* Fixed an issue in DetailsView the view's layout could become corrupted after changing the height of the overhang
* Fixed an issue in SearchView that could cause a nonexistent field warning to appear on the console

## v.2.5

### Features

* EntitlementView now supports upgrade/downgrade functionality for RokuPay
* All new audio UX in MediaView
* Improved performance of MediaView in audio mode
* Developers can now add buttons to MediaView in audio mode
* The system screensaver will now work with MediaView in audio mode
* Added new theming options for MediaView in audio mode
* Added a new field enableTrickplay on MediaView

### Bug Fixes

* Fixed an issue in MediaView where bookmarks might be deleted unexpectedly when using the seek field

## v.2.4

### Features

* The TimeGrid ContentManager can now be used with custom views
* ButtonBar can now be displayed on the left side of the screen
* MediaView has a new _seek_ field that can be used to move the playback position
* MediaView now supports shuffle in video mode
* MediaView shuffle logic has been improved
* SlideshowView has a new _closeAfterLastSlide_ field that can be used together with the _loop_ field to force the view to close itself when the slideshow is over
* CategoryListView has a new _ffrwPageSize_ field that can be used to customize the behavior of the FF and RW buttons on the remote control

### Bug Fixes

* Fixed a crash in DetailsView that could happen when trying to navigate through a playlist before it had loaded fully
* Fixed a crash that could happen when closing a SearchView
* Fixed a crash in MediaView that could happen when a channel localized the string "video"
* Fixed an issue where MediaView could get stuck on a loading screen in audio mode even after playback had started
* Fixed an issue where a BookmarkHandlerConfig might not be respected when used with MediaView in playlist mode
* Fixed an issue where the ButtonBar footprint could behave unexpectedly after using it with a MediaVIew in audio mode
* Fixed an issue where ButtonBar could appear in the wrong place after using it with a MediaVIew in audio mode
* Fixed an issue where SlideshowView could become unresponsive 
* Fixed an execution timeout when using SlideshowView with a very large set of images
* Fixed an issue where EntitlementView would give users the option to buy a non-trial product when they had not already purchased the equivalent trial product
* Fixed an issue where EntitlementView might not display products in the order specified in the EntitlementHandler
* Removed RIDA and ad limiting logic from RAFHandler. This is now handled by RAF itself

## v.2.3

### New Features and Enhancements

* The grid ContentManager can now be used with custom grid views
* GridVIew now supports vertical wrapping

### Bug Fixes

* Fixed an issue in MediaView where audio mode was sometimes not engaged automatically for audio content
* Fixed an issue in MediaView where d-pad L/R were not handled while content was buffering
* Fixed an issue where ButtonBar was sometimes not displayed over paused video
* Fixed an issue where a channel could crash when setting ButtonBar content to invalid
* Fixed an issue where a channel could crash when setting ButtonBar content to invalid

## v.2.2

### New Components

#### ButtonBar

ButtonBar gives developers an easy way to display a row of buttons in their channel. ButtonBar is a scene level component, so it can be displayed with any view in a channel, saving developers the work of managing it on a per-view basis. When combined with multiple screen stacks, ButtonBar enables powerful new UX paradigms in SGDEX.

#### SlideshowView

SlideshowView allows developers to present a collection of images to the user.

### New Features and Enhancements

* The ComponentController now supports multiple screen stacks
* RAFHandlers now support Client Side Ad Stitching
* DetailsView can now display rating data as an image rather than text
* GridView has a new field nextPageLoadingThreshold that allows developers to control when the next page of data is loaded
* GridView now loads nearby, off-screen metadata while the user is idle, similar to TimeGridView

### Bug Fixes

* Fixed an issue where the currentItem field in MediaView could change at unexpected times 
* Fixed an issue where RAFHandlers sometimes printed unexpected warnings to the console
* Fixed an issue where closing MediaView programmatically while an ad was playing could cause unexpected RAF errors
* Fixed an issue where MediaView sometimes did not invoke BookmarkHandlers when expected
* Fixed several issues where Roku's Static Analysis reported erroneous errors for SGDEX channels

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
