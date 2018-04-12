RCL supports customizing colors of elements in base RCL views.
There are three ways to customize look of view.

# Setting theme attributes

## Global theme parameters

Set theme attribute to any RCL view 

    scene.theme = {
        global: {
            textColor: "FF0000FF"
            backgroundColor: "00FF00FF"
        }
    }
 
 Provided code sets text color to RED to all supported text in RCL views. All RCL views will have green background
 
## View type specific attributes

If you want to have all views with Green background but all grids should have red one you should use such code:

    scene.theme = {
        global: {
            backgroundColor: "00FF00FF"
        }
        gridView: {
            backgroundColor: "FF0000FF"
        }
    }


## Instance specific attributes

Each view has it's own theme field, so if you want to set view specific attributes you can do it via this field.
Note you should only set fields that are different from the ones set in scene 
 
if you want to want to have all view with Green background but only one details screen with white one you should use such code:

    scene.theme = {
        global: {
            backgroundColor: "00FF00FF"
        }
    }
    
    view = CreateObject("roSgNode", "DetailsView")
    
    view.theme = {
        backgroundColor: "FFFFFFFF"
    }
    
# Usage notes

*   Set theme attributes at start of channel in Show(args) function.
*   No need to set global theme attributes before opening each screen.
*   If you want to change one attribute use updateTheme field so you can only specify needed attribute.
*   Set theme attributes and update attributes as one block so you don't trigger to many theme updates.
*   Theme attributes are used by RCL views and other RSG nodes wouldn't use configured theme attributes.

# Update theme attributes

Some times you need to update branding when user makes action, for example when user logs in logo should be changed. In such cases best approach to do this is just update one field, for such cases baseScene and RCL views have updateTheme field. You can use it to change/set any theme attribute.

UpdateTheme has same syntax as theme.

If you want to change overhang logo in all channels after login use such code:

    sub OnLoginSuccess()
        scene = m.top.getScene()
        
        scene.updateTheme = {
            global: {
                OverhangLogoUri: "new logo url"
            }
        }
    
    end sub   

# Theme attributes
## Common Theme Attributes
*   textColor - Set text color to all supported labels
*   focusRingColor - Set focus ring color
*   progressBarColor - Set color for progress bars
        
*   backgroundImageURI - Set url to background image
*   backgroundColor - Set background color

*   OverhangTitle - text that will be displayed in overhang title 
*   OverhangTitleColor - Color of overhang title
*   OverhangShowClock - toggle showing of overhang clock
*   OverhangShowOptions - show options on overhang
*   OverhangOptionsAvailable - tells if options are available. Note this is only visual field and doesn't affect if developer implements options
*   OverhangVisible - set if overhang should be visible      

*   OverhangLogoUri - url to overhang logo
*   OverhangBackgroundUri - overhang background url
*   OverhangOptionsText - text that will be show in options
*   OverhangHeight - height of overhang
*   OverhangBackgroundColor - overhang background color

## Grid View Theme Attributes
*   textColor - sets the color of all text elements in the view
*   focusRingColor - set color of focus ring 
*   focusFootprintColor - set color for focus ring when unfocused
*   rowLabelColor - sets color for row title
   
*   itemTextColorLine1 - set color for first row in item description
*   itemTextColorLine2 - set color for second row in item description
 
*   titleColor - sets color of title 
*   descriptionColor - sets color of description text
*   descriptionmaxWidth - sets max width for description
*   descriptionMaxLines - sets max lines for description

## Details View Theme Attributes

*   textColor - sets the color of all text elements in the view
*   focusRingColor - set color of focus ring 
*   focusFootprintColor - set color for focus ring when unfocused
*   rowLabelColor - sets color for row title
   
*   descriptionColor -set the color of descriptionLabel
*   actorsColor -set the color of actorsLabel
*   ReleaseDateColor -set the the color for ReleaseDate
*   RatingAndCategoriesColor -set the color of categories

*   buttonsFocusedColor - set the color of focused buttons
*   buttonsUnFocusedColor - set the color of unfucused buttons
*   buttonsFocusRingColor - set the color of button focus ring
*   buttonsSectionDividerTextColor - set the color of section divider

## CategoryListView Theme Attributes

*   TextColor - changes color for all text fields in category list
*   focusRingColor - changes color of focus rings for both category and item list
*   categoryFocusedColor - set focused text color for category
*   categoryUnFocusedColor - set unfocused text color for category 
*   itemTitleColor - set item title color           
*   itemDescriptionColor - set item description color    
*   categoryfocusRingColor - set color for category list focus ring 
*   itemsListfocusRingColor - set color for item list focus ring

## VideoView Theme Attributes

<b>General fields</b>
                
*   TextColor - set text color for all texts on video and endcard views
*   progressBarColor - set color for progress bar
*   focusRingColor - set color for focus ring on endcard view

*   backgroundColor - set background color for endcards view
*   backgroundImageURI - set background image url for endcards view
*   endcardGridBackgroundColor -set background color for grid for endcard items

<b>Video player fields:</b>

*   trickPlayBarTextColor - Sets the color of the text next to the trickPlayBar node indicating the time elapsed/remaining.
*   trickPlayBarTrackImageUri - A 9-patch or ordinary PNG of the track of the progress bar, which surrounds the filled and empty bars. This will be blended with the color specified by the trackBlendColor field, if set to a non-default value. 
*   trickPlayBarTrackBlendColor - This color is blended with the graphical image specified by trackImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
*   trickPlayBarThumbBlendColor - Sets the blend color of the square image in the trickPlayBar node that shows the current position, with the current direction arrows or pause icon on top. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.   
*   trickPlayBarFilledBarImageUri - A 9-patch or ordinary PNG of the bar that represents the completed portion of the work represented by this ProgressBar node. This is typically displayed on the left side of the track. This will be blended with the color specified by the filledBarBlendColor field, if set to a non-default value.
*   trickPlayBarFilledBarBlendColor - This color will be blended with the graphical image specified in the filledBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.      
*   trickPlayBarCurrentTimeMarkerBlendColor - This is blended with the marker for the current playback position. This is typically a small vertical bar displayed in the TrickPlayBar node when the user is fast-forwarding or rewinding through the video.

<b>Buffering Bar customization</b>     
     
*   bufferingTextColor - The color of the text displayed near the buffering bar defined by the bufferingBar field, when the buffering bar is visible. If this is 0, the system default color is used. To set a custom color, set this field to a value other than 0x0.  
*   bufferingBarEmptyBarImageUri - A 9-patch or ordinary PNG of the bar presenting the remaining work to be done. This is typically displayed on the right side of the track, and is blended with the color specified in the emptyBarBlendColor field, if set to a non-default value.
*   bufferingBarFilledBarImageUri - A 9-patch or ordinary PNG of the bar that represents the completed portion of the work represented by this ProgressBar node. This is typically displayed on the left side of the track. This will be blended with the color specified by the filledBarBlendColor field, if set to a non-default value.
*   bufferingBarTrackImageUri - A 9-patch or ordinary PNG of the track of the progress bar, which surrounds the filled and empty bars. This will be blended with the color specified by the trackBlendColor field, if set to a non-default value.
                                       
*   bufferingBarTrackBlendColor - This color is blended with the graphical image specified by trackImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
*   bufferingBarEmptyBarBlendColor - A color to be blended with the graphical image specified in the emptyBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.
*   bufferingBarFilledBarBlendColor - This color will be blended with the graphical image specified in the filledBarImageUri field. The blending is performed by multiplying this value with each pixel in the image. If not changed from the default value, no blending will take place.

<b>Retrieving Bar customization</b>  
       
*   retrievingTextColor - Same as bufferingTextColor but for retrieving bar
*   retrievingBarEmptyBarImageUri - Same as bufferingBarEmptyBarImageUri but for retrieving bar
*   retrievingBarFilledBarImageUri - Same as bufferingBarFilledBarImageUri but for retrieving bar
*   retrievingBarTrackImageUri - Same as bufferingBarTrackImageUri but for retrieving bar
                                       
*   retrievingBarTrackBlendColor - Same as bufferingBarTrackBlendColor but for retrieving bar
*   retrievingBarEmptyBarBlendColor - Same as bufferingBarEmptyBarBlendColor but for retrieving bar
*   retrievingBarFilledBarBlendColor - Same as bufferingBarFilledBarBlendColor but for retrieving bar

<b>Endcard view theme attributes</b>  

*   buttonsFocusedColor - repeat button focused text color     
*   buttonsUnFocusedColor - repeat button unfocused text color
*   buttonsfocusRingColor - repeat button background color

<b>Endcard grid attributes</b>

*   rowLabelColor - grid row title color
*   focusRingColor - grid focus ring color
*   focusFootprintBlendColor - grid unfocused focus ring color
*   itemTextColorLine1 - text color for 1st row on endcard item 
*   itemTextColorLine2 - text color for 2nd row on endcard item     
*   timerLabelColor - Color of remaining timer

###### Copyright (c) 2018 Roku, Inc. All rights reserved.
