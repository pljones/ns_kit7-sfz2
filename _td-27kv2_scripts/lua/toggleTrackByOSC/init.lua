P = {}
toggleTrackByOSC = P

local reaper = reaper
local string = string
local tonumber = tonumber
local tostring = tostring

_ENV = P

local init = nil
local kitPieceGroupParent = nil
local kitPieceGroupParentTkNo = nil

local enableReceiveForSend = function(track, numRx, send)
    local rx = 0
    while (rx < numRx)
    do
        local currentSend = reaper.GetTrackSendInfo_Value(track, -1, rx, "P_SRCTRACK")
        if (currentSend == send) then
            reaper.SetTrackSendInfo_Value(track, -1, rx, "B_MUTE", 0.0)
            reaper.SetMediaTrackInfo_Value(track, "I_FXEN", 1)
            rx = numRx
        end
        rx = rx + 1
    end
end

local enableReceivesForTrack = function(lowTkNo, send)
    local tkNo = lowTkNo
    local track = reaper.GetTrack(0, tkNo)
    while not (track == nil) do
        local numRx = reaper.GetTrackNumSends(track, -1)
        if (numRx > 0) then
            enableReceiveForSend(track, numRx, send)
        end

        tkNo = tkNo + 1
        track = reaper.GetTrack(0, tkNo)
    end
end

local isNsKit7Track = function(track)
    local parent = reaper.GetParentTrack(track)
    if not (parent == nil) then
        local tkName, f = reaper.GetTrackState(parent)
        local startIndex, endIndex = string.find(tkName, "ns_kit7")
        if (startIndex == 1) then
            return true
        else
            return false
        end
    end
end

--[[
  A track can be toggled if and only if:
    * It has MIDI Ins
    * It is record armed
    * It is record monitoring
    * It has track effects
  That's just how life is.
]]
local canToggle = function(track)
    -- Is this a MIDI track?
    local recInput = reaper.GetMediaTrackInfo_Value(track, "I_RECINPUT")
    if recInput & 4096 == 0 then
        return false
    end
    local recArm = reaper.GetMediaTrackInfo_Value(track, "I_RECARM")
    if recArm == 0 then
        return false
    end
    local recMon = reaper.GetMediaTrackInfo_Value(track, "I_RECMON")
    if recMon == 0 then
        return false
    end
    local trackFXCount = reaper.TrackFX_GetCount(track)
    if trackFXCount == 0 then
        return false
    end
    return true
end

local toggleTrackEnableN = function(tkNo, track, setting)
    --local isTkFxEnabled = reaper.GetMediaTrackInfo_Value(track, "I_FXEN")
    --reaper.ShowConsoleMsg("track " .. tkNo .. "; setting " .. setting .. "; isTkFxEnabled " .. isTkFxEnabled .. "\n")
    local srTk = 0
    local search = reaper.GetTrack(0, srTk)
    local srVal = 0

    while not (search == nil) do
        if (search == kitPieceGroupParent) then
            search = nil
        else
            if canToggle(search) then
                -- For the target track, apply the OSC val, otherwise, turn off
                if ((0 + srTk) == (0 + tkNo)) then srVal = setting else srVal = 0 end
                reaper.SetMediaTrackInfo_Value(search, "I_FXEN", srVal)
                -- Trigger the ReaperOSC mapping for feedback
                -- See notes above for why mess is needed...
                reaper.SetTrackSelected(reaper.GetTrack(0, srTk - 1), srVal)
            end
            srTk = srTk + 1
            search = reaper.GetTrack(0, srTk)
        end
    end
end

local muteReceivesForTrack = function(track, numRx)
    local rx = 0
    while (rx < numRx)
    do
        reaper.SetTrackSendInfo_Value(track, -1, rx, "B_MUTE", 1.0)
        rx = rx + 1
    end
end

local muteAllRecives = function(lowTkNo)
    local tkNo = lowTkNo
    local track = reaper.GetTrack(0, tkNo)
    while not (track == nil) do
        local numRx = reaper.GetTrackNumSends(track, -1)
        if (numRx > 0) then
            muteReceivesForTrack(track, numRx)
            reaper.SetMediaTrackInfo_Value(track, "I_FXEN", 0)
        end

        tkNo = tkNo + 1
        track = reaper.GetTrack(0, tkNo)
    end
end

local initialise = function()
    if not (init == nil) then
        return
    end

    local section, key = "toggleTrackByOSC", "kitPieceGroupParentTkNo"

    local stored = reaper.GetExtState(section, key)
    if stored ~= "" then
        kitPieceGroupParentTkNo = tonumber(stored)
        kitPieceGroupParent = reaper.GetTrack(0, kitPieceGroupParentTkNo)
        if (kitPieceGroupParent ~= nil) then
            init = true
            return
        end
    end

    local kitPieceGroupParentName = "ns_kit7 groups"

    local srTk = 0
    local search = reaper.GetTrack(0, srTk)

    while not (search == nil) do
        local tkName, f = reaper.GetTrackState(search)
        if (tkName == kitPieceGroupParentName)
        then
            kitPieceGroupParent = search
            kitPieceGroupParentTkNo = srTk
            reaper.SetExtState(section, key, tostring(kitPieceGroupParentTkNo), false)
            search = nil
        else
            srTk = srTk + 1
            search = reaper.GetTrack(0, srTk)
        end
    end

    init = true
end

local getTkSetting = function()
    local is_new, name, sec, cmd, rel, res, val, ctx = reaper.get_action_context()
    if not (is_new) then
        return
    end

    local tkNo, setting = ctx:match([[^osc:/track/(%d*)/onOff:f=([01])[.]0+$]])
    --reaper.ShowConsoleMsg("; context " .. ctx .. "; tkNo " .. tkNo .. "; setting " .. setting .. "\n")
    if (tkNo == nil) then
        reaper.ShowConsoleMsg(string.format("ctx %s did not match\n", ctx))
        return
    end
    return tkNo, setting
end

toggleTrackEnable = function()
    local tkNo, setting = getTkSetting()
    if (tkNo == nil or setting == nil) then
        return
    end

    -- OSC tkNo from above starts at 1
    -- Reaper GetTrack is zero based
    -- The ReaperOSC
    -- TRACK_SELECT b/track/@/onOff
    -- mapping also maps OSC @=1 to Reaper GetTrack=0

    -- Unfortunately, because of the extra "Sound source parent SEND" Reaper track,
    -- OSC tkNo 1 needs to map to Reaper GetTrack 1.

    -- Hence, the OSC mapping will have touched the wrong track, so turn it off.
    local track = reaper.GetTrack(0, tkNo - 1)
    if (track == nil) then
        return
    end
    reaper.SetTrackSelected(track, 0)

    -- And now, get the intended track
    track = reaper.GetTrack(0, tkNo)

    -- if this track is not a sound source (see below), ignore the request
    if not (canToggle(track)) then
        --  reaper.ShowConsoleMsg(string.format("track %s cannot toggle\n", tkNo))
        return
    end

    initialise()

    muteAllRecives(kitPieceGroupParentTkNo)
    toggleTrackEnableN(tkNo, track, tonumber(setting))

    if (tonumber(setting) == 1.0 and isNsKit7Track(track)) then
        enableReceivesForTrack(kitPieceGroupParentTkNo, track)
    end
end

return toggleTrackByOSC