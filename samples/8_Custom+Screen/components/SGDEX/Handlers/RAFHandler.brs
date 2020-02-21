' Copyright (c) 2018 Roku, Inc. All rights reserved.

Library "Roku_Ads.brs"

sub Init()
    m.top.functionname = "PlayContentWithFullRAFIntegration"
end sub

sub ConfigureRAF(adIface)
    ? "ConfigureRAF in library task"
end sub

' A full RAF integration Example:
' - Include RAF.
' - setAdURL to set the ad URL.
' - Examples of RAF MACROS being passed in the ad call.
' - getAds() for VAST parsing.
' - showAds for rendering.
' - Enable Nielsen.
' - Pass all parameters to Nielsen beacons with examples of genre, program id and content.
' @param videoContent [AA] object that has valid data for playing video with roVideoScreen.
sub PlayContentWithFullRAFIntegration()
    ' Video node should be set outside because there is no way to get it with another way
    videoNode = m.top.video
    videoView = videoNode.getParent()
    adIface = Roku_Ads() ' RAF initialize

    ' We should override Raf functions to know that thay were called in channel handler
    ' and for importAds we should save ads array somewhere to pass it later to ShowAds
    adIface.sgdex_original_importAds = adIface.importAds
    adIface.importAds = sub(ads, enableLogging = false as Boolean)
            m.sgdex_flag_importAds_was_called = true
            m.sgdex_importedAds = ads
            m.sgdex_original_importAds(ads, enableLogging)
        end sub

    adIface.sgdex_original_StitchedAdsInit = adIface.StitchedAdsInit
    adIface.StitchedAdsInit = sub(ads)
            m.sgdex_flag_StitchedAdsInit_was_called = true
            m.sgdex_original_StitchedAdsInit(ads)
        end sub

    ' Overriding setTrackingCallback function to allow MediaView and developer track events using proxying
    adIface.sgdex_original_SetTrackingCallBack = adIface.setTrackingCallBack
    adIface.setTrackingCallBack = sub(callbackName = invalid as dynamic, obj = invalid as dynamic)
            m["sgdex_user_custom_trackingCallback"] = callbackName
            m["sgdex_user_custom_callbackObj"] = obj
        end sub
    ' developer can configure Raf via overrided ConfigureRAF function inside Handler in channel
    ConfigureRAF(adIface)

    content = m.top.content

    adUrl = adIface.getAdUrl()
    if adUrl <> invalid and adUrl <> ""
        RIDA = ""
        dev_info = createObject("roDeviceInfo")
        if not dev_info.IsRIDADisabled()
            RIDA = dev_info.GetRida()
        end if

        adUrl.replace("ROKU_ADS_TRACKING_ID", RIDA)
        adUrl.replace("ROKU_ADS_LIMIT_TRACKING", dev_info.IsRIDADisabled().ToStr())
        adIface.SetAdUrl(adUrl)
    end if

    ' Should developer scene as a place for ads rendering
    view = m.top.getScene()
    if view = invalid
        print "Error: invalid view"
        return
    end if

    ' Add loading facade for case if GetAds would be loaded for some time
    facade = videoView.createChild("LoadingFacade")

    ' adPods is array of ads - used for preroll playback
    adPods = Invalid

    ' if flag was set, we'll use Client-stitched ads approach
    if m.top.useCSAS then
        adIface.sgdex_flag_ClientStitchedAds_was_enabled = true
        adIface.sgdex_flag_StitchedAdsInit_was_called = true
        adIface.sgdex_original_SetTrackingCallBack(SGDEXProxyTrackingCallback)
        m.m_adinstance["videoView"] = videoView
    end if

    ' if it is not imported ads and not stitched ads, load ads with usual GetAds
    if adIface.sgdex_flag_importAds_was_called = Invalid and (adIface.sgdex_flag_StitchedAdsInit_was_called = Invalid or adIface.sgdex_flag_ClientStitchedAds_was_enabled = true) then
        adPods = adIface.GetAds()

    ' if it is imported ads, get it to show in preroll
    else if adIface.sgdex_flag_importAds_was_called = true
        adPods = adIface.sgdex_importedAds
    end if

    ' close loading facade, because all ads already loaded
    videoView.removeChild(facade)

    ' If there are some ads to play and it is not stitched ads, try to play preroll
    playContent = true
    if adPods <> invalid and adPods.count() > 0 and adIface.sgdex_flag_StitchedAdsInit_was_called = Invalid
        m.top.isPlayingAds = true
        playContent = adIface.ShowAds(adPods, invalid, view)
        m.top.isPlayingAds = false
    end if

    m.port = CreateObject("roMessagePort")

    ' if preroll was played successfully, configure video node and start playback
    if playContent
        videoNode.ObserveFieldScoped("position", m.port)
        videoNode.ObserveFieldScoped("state", m.port)
        videoNode.SetFocus(true)
        videoNode.enableUI = true
        videoNode.visible = true
        videoNode.control = "play"
    else ' if preroll was skipped, close the video view
        videoView.close = true
        return
    end if

    ' local var for local ad played
    adPod = invalid

    ' create video node wrapper object for StitchedAdHandledEvent function
    player = { sgNode: videoNode, port: m.port }

    ' event loop
    while true
        msg = Wait(0, m.port)
        msgType = type(msg)

        ' if ads is stitched, handle it
        curAd = Invalid
        if adIface.sgdex_flag_StitchedAdsInit_was_called <> Invalid and adIface.sgdex_flag_StitchedAdsInit_was_called = true
            curAd = adIface.StitchedAdHandledEvent(msg, player)
        end if

        if adIface.sgdex_flag_ClientStitchedAds_was_enabled <> Invalid and adIface.sgdex_flag_ClientStitchedAds_was_enabled = true and videoView.currentItem <>invalid
            content = videoView.currentItem
            ' TODO: log for invalid content/adPods
            csasStream = adIface.constructStitchedStream(content,adPods) ' contructing stream with ads to work with
            ThemeRAFRenderer(csasStream,videoView) ' sharing themes between MediaView and RAFContentRenderer
            isCSASPlaying = adIface.renderStitchedStream(csasStream, videoView) ' Start RAFContentRenderer playback
        end if

        ' ad handled event; if stitched ad skipped, exit playback
        if curAd <> invalid and curAd.evtHandled <> invalid
            if curAd.adExited
                videoView.close = true
                exit while
            end if

        ' if it is some video playback event
        else if msgType = "roSGNodeEvent" and msg.GetNode() = "video"
            ' if it is video playback and videoNode losed focus (in Raf), restore focus to Video node
            if videoNode.hasFocus() = false then videoNode.setFocus(true)

            ' if it is not stitched ad
            if adIface.sgdex_flag_StitchedAdsInit_was_called = Invalid
                ' at position state we should check if there is a midroll ad
                if msg.GetField() = "position"
                    ' save current position to restore later
                    curPos = msg.GetData()

                    ' try to get midroll ad
                    adPod = adIface.GetAds(msg)

                    ' if there is a midroll ad, try to play
                    if adPod <> invalid and adPod.Count() > 0
                        ' render mid-roll ads

                        ' video node should be hidden and stopped before play midroll
                        videoNode.visible = false
                        videoNode.control = "stop"

                        ' play midroll
                        m.top.isPlayingAds = true
                        playContent = adIface.ShowAds(adPod, invalid, view)
                        m.top.isPlayingAds = false

                        ' save local variable to handle "stopped" state for midroll playback
                        m.midRoll = playContent

                        ' if midroll was played successfully
                        if playContent then
                            videoNode.visible = true
                            videoNode.SetFocus(true)
                            videoNode.seek = curPos
                            videoNode.control = "play"
                        else ' if midroll was skipped video should be closed
                            videoNode.visible = true
                            videoView.close = true
                            exit while
                        end if
                    end if ' // midroll if

                ' states should be handled - finished for postroll, stopped and error for close video
                else if msg.GetField() = "state"
                    curState = msg.GetData()

                    ' if video finished, try to play postroll
                    if curState = "finished"
                        ' videoNode.control = "none"
                        ' render post-roll ads
                        adPod = adIface.GetAds(msg)
                        if adPod <> invalid and adPod.Count() > 0
                            ' postroll ad. stop video. show postroll when
                            ' state changes to  "sаtopped".
                            videoNode.control = "stop"
                            m.top.isPlayingAds = true
                            adIface.ShowAds(adPod, invalid, view)
                            m.top.isPlayingAds = false
                        end if
                        exit while
                    else if curState = "stopped"
                        ' before midroll playback video node should be stopped, and message for state == "stopped"
                        ' will appear in this while loop, so we should skip this one state to handle midroll case
                        ' for this reason we saved a m.midRoll flag before.
                        if m.midRoll = true
                            m.midRoll = false
                        else
                            exit while
                        end if
                    else if curState = "error"
                        exit while
                    end if
                end if

            ' if it is stitched ad, we still should handle finish, stop or error states to close video
            else if msg.GetField() = "state"
                curState = msg.GetData()
                if curState = "finished" or curState = "stopped" or curState = "error" then exit while
            end if ' adIface.sgdex_flag_StitchedAdsInit_was_called = Invalid
        end if
    end while

    videoNode.UnobserveFieldScoped("position")
    videoNode.UnobserveFieldScoped("state")
    videoNode.UnobserveFieldScoped("control")
    videoNode = Invalid
end sub

' Sharing MV theme with RAFContentRenderer node
sub ThemeRAFRenderer(renderer as Object, view as Object)
    ' Setting render node to work with it in MV scope
    m.top.renderNode = renderer
end sub

' Proxy tracking callback to provide info about position, state to MediaView and allow developer to track them independently
sub SGDEXProxyTrackingCallback(obj = invalid as Dynamic, eventType = invalid as Dynamic, ctx = invalid as Dynamic)
    instance = getglobalAA().m_adinstance 'TODO: replace getglobalAA()
    videoView = instance.videoView
    if instance.sgdex_user_custom_trackingCallback <> invalid then
        instance.sgdex_user_custom_trackingCallback(obj,eventType,ctx)
    end if

    ' handling position/state change events to allow user track them on MediaView
    if eventType = "ContentPosition" then
        videoView.position = ctx.contentPos
    else if eventType = "AdStateChange" then
        videoView.state = ctx.state
    else if eventType = "ContentStateChange" then
        videoView.state = ctx.state
    end if
end sub
