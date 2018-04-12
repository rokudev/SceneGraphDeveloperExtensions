' Copyright (c) 2018 Roku, Inc. All rights reserved.

sub init()
    m.sid_object = {}
    m.ui_object = {}
    m.vo_object = {}
    
    'Screen stack array
    m.ssA = []
    
    'Screen stack component
    m.addScreen = addScreen 
    m.closeScreen = closeScreen
    m.closeToScreen = closeToScreen
    m.replaceCurrentScreen = replaceCurrentScreen
    m.syncOutProperties = syncOutProperties
    m.saveState = saveState
    
    m.top.observeField("change", "procedureObjectChange")
end sub

sub syncOutProperties()
    if m.ssUI <> invalid
        m.top.currentScreen = m.ssUI.getchild(0)
    else
        m.top.currentScreen = invalid
    end if
    m.top.screenCount = m.ssA.Count()
end sub

sub screenStackUIChange()
    m.ssUI = m.top.screenStackUI
end sub

' >>>   procedureObject  part -----------------------------------------------------------------------------------------------------------
sub procedureObjectChange(event as Object)
    'execute all stacked events
    field = event.getField()
    if field = "change"
        maxEventsCount = 15
        while m.top.getChildCount() > 0 AND maxEventsCount > 0
            procedureNode = m.top.getChild(0)
            if procedureNode <> invalid 
                m.top.removeChildIndex(0)
                procedureObject = procedureNode.procedureObject
                if type(procedureObject) = "roAssociativeArray" and type(m[procedureObject.fn]) = "roFunction" then
                    ?"==============================================================================="
                    ?" Run Procedure from ScreenManager child -> functionName = "procedureObject.fn
                    ?"==============================================================================="
                    runProcedure(procedureObject)
                end if
            else
                exit while
            end if
            maxEventsCount = maxEventsCount - 1
        end while
    else if field = "procedureObject" and m.top.procedureObject <> invalid
        procedureObject = m.top.procedureObject
        ?"==============================================================================="
        ?" Run Procedure from procedureObject field -> functionName = "procedureObject.fn
        ?"==============================================================================="
        if type(procedureObject) = "roAssociativeArray" and type(m[procedureObject.fn]) = "roFunction" then
            runProcedure(procedureObject)
        end if
    else
        ?"==============================================================================="
        ?" Run Procedure from "field" field -> functionName = "field
        ?"==============================================================================="
        data = event.getData()
        if type(m[field]) = "roFunction" and type(data) = "roAssociativeArray" and data.fp <> invalid then
            runProcedure({
                fn : field
                fp : data.fp
            })
        end if
    end if
end sub

' run procedure from 0 to 5 argunments
sub runProcedure(procedureObject)
    procedureParams = procedureObject.fp
    ? " Screen Manager runProcedure "; procedureObject.fn
    if type(procedureParams) = "roArray" then
        if procedureParams.count() = 0 then
            m[procedureObject.fn]()
        else if procedureParams.count() = 1 then
            m[procedureObject.fn](procedureParams[0])
        else if procedureParams.count() = 2 then
            m[procedureObject.fn](procedureParams[0], procedureParams[1])
        else if procedureParams.count() = 3 then
            m[procedureObject.fn](procedureParams[0], procedureParams[1], procedureParams[2])
        else if procedureParams.count() = 4 then
            m[procedureObject.fn](procedureParams[0], procedureParams[1], procedureParams[2], procedureParams[3])
        else if procedureParams.count() = 5 then
            m[procedureObject.fn](procedureParams[0], procedureParams[1], procedureParams[2], procedureParams[3], procedureParams[4])
        end if
    else
        m[procedureObject.fn]()
    end if
end sub
' <<<   procedureObject  part -----------------------------------------------------------------------------------------------------------

function createScreenVO(NodeOrName, screenInitData)

    if lcase(type(screenComponentName)) = "rosgnode" then
        name = NodeOrName.id
    else
        name = NodeOrName
    end if
    previousScreenSid = m.ssA.Peek()
    if previousScreenSid <> invalid then
        previousscreensid = previousscreensid.sid
    else
        previousScreenSid = ""
    end if
    screenVO = {
        name : name
        init_data : screenInitData
        current_state : {
            init_data : screenInitData
            stop_data : invalid
            closed_screen_data : invalid
            
            previousScreenSid : previousScreenSid
        }
        'Screen id
        sid : getScreenId(NodeOrName)
    }
    
    m.vo_object[screenVO.sid] = screenVO
    
    return screenVO
end function

function getScreenId(NodeOrName)

    if lcase(type(NodeOrName)) = "rosgnode" then
        key = NodeOrName.id
    else
        key = NodeOrName
    end if
    
    value = m.sid_object[key]
    if value <> invalid then
        value = value + 1
    else
        value = 1
    end if
    
    m.sid_object[key] = value
    
    return key + "_" + itostr(value)
end function

sub addScreen(screenComponentName, screenInitData)
    nowScreenUI = invalid
    'let previous screen save it's state before opening new screen
    'good for saving focused child     
    if m.ssA.Count() > 0 then
        nowScreenVO = m.ssA.Peek()
        nowScreenUI = m.ui_object[nowScreenVO.sid]
        if nowScreenUI.hasField("saveState") then
            nowScreenUI.saveState = true
        end if
    end if
    screenVO = createScreenVO(screenComponentName, screenInitData)
    
    if lcase(type(screenComponentName)) = "rosgnode" then
        UIObject = screenComponentName
    else
        UIObject = createObject("roSGNode", screenVO.name)
    end if
    
    m.ui_object[screenVO.sid] = UIObject 
    newScreen = m.ui_object[screenVO.sid]
    m.ssUI.appendChild(newScreen)
    if not newScreen.isinFocusChain() AND newScreen.focusedChild = invalid
        
        if newScreen.initialFocusedNode <> invalid
            ?"set focus to :"newScreen.initialFocusedNode.subtype()
            newScreen.initialFocusedNode.setfocus(true) 
        else
            if not newScreen.isInFocusChain()
                newScreen.setFocus(true)
                ?"newScreen.setFocus(true)"
            end if
        end if
    end if
    
    if newScreen.hasField("wasShown") then
        newScreen.wasShown = true
    end if
    
    if NOT newScreen.hasField("close") then
        newScreen.addField("close", "string", true)
    end if
    newScreen.observeFieldScoped("close", "RemoveThisScreenFromStack")
    
    if nowScreenUI <> invalid
        nowScreenUI.visible = false
        m.ssUI.removeChild(nowScreenUI)
    end if
    
    m.ssA.push(screenVO)
    syncOutProperties()
end sub

sub closeScreen(sid = invalid, closeData = invalid)
    if m.ssA.Count() > 0 then
        closedScreenVO = m.ssA.Pop()
        if m.ssA.Count() = 0
            if m.top.allowCloseChannelWhenNoScreens = true
                scene = m.top.getScene()
                if scene <> Invalid and scene.hasField("exitChannel") then
                    scene.exitChannel = true
                    return
                end if
            end if
        end if
        closedScreenUI = m.ui_object[closedScreenVO.sid]
        'tell the screen that it was closed
        ?"fire close for this screen"
        if closedScreenUI.hasField("wasClosed") then
            closedScreenUI.wasClosed = true
        end if
        
        'Re-add previous screen
        if m.ssA.Count() > 0 then
            nowScreenVO = m.ssA.Peek()
            nowScreenVO.current_state.closed_screen_data = closeData
            nowScreenUI = m.ui_object[nowScreenVO.sid]
            if not IsNodeContainsChild(m.ssUI,nowScreenUI) ' check if new screen doesn't opened in close callback
                ?"Showing previous screen"
                nowScreenUI.visible = true
                m.ssUI.appendChild(nowScreenUI)
                
                if nowScreenVO.focusedNode <> invalid then
                    nowScreenVO.focusedNode.setFocus(true)
                else
                    if not nowScreenUI.isInFocusChain()
                        nowScreenUI.setFocus(true)
                    end if
                end if    
                if nowScreenUI.hasField("wasShown") then
                    nowScreenUI.wasShown = true
                end if
            end if
        else
            ?"INFO : Last screen was closed"
        end if
        
        'Delete and clean closed screen
        closedScreenUI = m.ui_object[closedScreenVO.sid]
        closedScreenUI.visible = false
        m.ssUI.removeChild(closedScreenUI)    
        m.ui_object.delete(closedScreenVO.sid)
        m.vo_object.delete(closedScreenVO.sid)
    end if
    
    syncOutProperties()
end sub

sub closeToScreen(sid = invalid, closeData = invalid)
    if m.ssA.Count() > 0 then
        screenVO = m.ssA.peek()
        closedScreenVO = invalid
        closedScreenUI = invalid
        if screenVO <> invalid 
            if sid <> "" and Lcase(screenVO.sid) <> LCase(sid)
                closedScreenVO = m.ssA.Pop()
                closedScreenUI = m.ui_object[closedScreenVO.sid]
                'tell the screen that it was closed
                if closedScreenUI.hasField("wasClosed") then
                    closedScreenUI.wasClosed = true
                end if
            end if
        end if
        
        'Re-add previous screen
        
        if m.ssA.Count() > 0 
            nowScreenVO = invalid
            count = m.ssA.Count()
            if sid <> invalid AND sid.len() > 0 then
                whileCounter = 100
                while true and whileCounter > 0
                    screenVO = m.ssA.peek()
                    if screenVO <> invalid 
                        if Lcase(screenVO.sid) = LCase(sid)
                            nowScreenVO = screenVO
                            exit while
                        else
'                            if screenVO.hasField("wasClosed") then
'                                screenVO.wasClosed = true
'                            end if
                            m.ui_object.delete(screenVO.sid)
                            m.vo_object.delete(screenVO.sid)
                            'delete this screen
                            m.ssA.pop()                
                        end if
                    else
                        ?"failed to get screen"
                        exit while
                    end if
                    whileCounter--
                end while
            end if
            if nowScreenVO = invalid then nowScreenVO = m.ssA.Peek()
            if nowScreenVO <> invalid
                nowScreenVO.current_state.closed_screen_data = closeData
                nowScreenUI = m.ui_object[nowScreenVO.sid]
                nowScreenUI.visible = true
                m.ssUI.appendChild(nowScreenUI)
                
                if nowScreenVO.focusedNode <> invalid then
                    nowScreenVO.focusedNode.setFocus(true)
                else
                    nowScreenUI.setFocus(true)
                end if    
                if nowScreenUI.hasField("wasShown") then
                    nowScreenUI.wasShown = true
                end if
            else
                ?"closed to many screen, check your id"
            end if
        else
            ?"problems with sid,  m.ssA.Count():" m.ssA.Count()", sid:["sid"]"
        end if
        
        'Delete and clean closed screen
        if closedScreenUI <> invalid and closedScreenVO <> invalid
            closedScreenUI = m.ui_object[closedScreenVO.sid]
            closedScreenUI.visible = false
            m.ssUI.removeChild(closedScreenUI)    
            m.ui_object.delete(closedScreenVO.sid)
            m.vo_object.delete(closedScreenVO.sid)
        end if
    end if
    syncOutProperties()
end sub

sub replaceCurrentScreen(screenComponentName, screenInitData)
    if m.ssA.Count() > 0 then
        closedScreenVO = m.ssA.Pop()
        
        'Add new screen
        screenVO = createScreenVO(screenComponentName, screenInitData)
        m.ui_object[screenVO.sid] = createObject("roSGNode", screenVO.name)
        newScreen = m.ui_object[screenVO.sid]
        m.ssUI.appendChild(newScreen)
        newScreen.setFocus(true)
        if newScreen.hasField("wasShown") then
            newScreen.wasShown = true
        end if    
        m.ssA.push(screenVO)
        
        'Delete and clean closed screen
        closedScreenUI = m.ui_object[closedScreenVO.sid]
        closedScreenUI.visible = false
        m.ssUI.removeChild(closedScreenUI)    
        m.ui_object.delete(closedScreenVO.sid)
    end if
    
    syncOutProperties()
end sub

sub RemoveThisScreenFromStack(event as Object)
    
    screen = event.getROSGNode()
    if screen <> invalid AND m.ssA.Count() > 0 then
        
        closedScreenVO = m.ssA.peek()
        closedScreenUI = m.ui_object[closedScreenVO.sid]
        
        if closedScreenUI.isSameNode(screen) then
            'This is simple close so we can call it
            closeScreen("", {})
        else
            for index = m.ssa.count() - 1 to 0 step -1
                possibleScreen = m.ssa[index]
                if possibleScreen <> invalid then
                    possibleScreenRSGNode = m.ui_object[possibleScreen.sid]
                    if possibleScreenRSGNode <> invalid AND possibleScreenRSGNode.isSameNode(screen) then
                        ?"found screen to close"
                        if possibleScreenRSGNode.hasField("wasClosed") then
                            possibleScreenRSGNode.wasClosed = true
                        end if
                        m.ui_object.delete(possibleScreen.sid)
                        m.vo_object.delete(possibleScreen.sid)
                        m.ssa.delete(index)
                        exit for
                    end if
                end if
            end for
        end if
    end if
end sub

sub saveState(sid , saveAA )
    screenVO = m.vo_object[sid]
    if screenVO <> invalid then
        screenVO.current_state.stop_data = saveAA
    end if
end sub

function IsNodeContainsChild(node,child) as boolean
    if node <> invalid and child <> invalid
        for i = 0 to node.getchildcount() - 1
            n_child = node.getChild(i)
            if n_child <> invalid and n_child.isSameNode(child) then return true
        end for
    end if
    return false
end function

'==============================================================================
'                             Helper functions
'==============================================================================

'******************************************************
'itostr
'
'Convert int to string. This is necessary because
'the builtin Stri(x) prepends whitespace
'******************************************************
Function itostr(i As Integer) As String
    str = Stri(i)
    return strTrim(str)
End Function


'******************************************************
'Trim a string
'******************************************************
Function strTrim(str As String) As String
    st=CreateObject("roString")
    st.SetString(str)
    return st.Trim()
End Function
