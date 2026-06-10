--[[
/**
 * ReaScript Name: toggleTrackEnable
 * Description: Toggle Track Enable
 * Instructions: Install this in user reaper scripts.
 * Author: pljones
 * Licence: GPL v3
 * Version: 0.6
 */
]]
function toggleTrackEnable()
  is_new,name,sec,cmd,rel,res,val,ctx = reaper.get_action_context()
  if not(is_new) then
    return
  end

  local tkNo, setting = ctx:match([[^osc:/track/(%d*)/onOff:f=([01])[.]0+$]])
--reaper.ShowConsoleMsg("; context " .. ctx .. "; tkNo " .. tkNo .. "; setting " .. setting .. "\n")
  if (tkNo == nil) then
    reaper.ShowConsoleMsg(string.format("ctx %s did not match\n", ctx))
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
  if not(canToggle(track)) then
  --  reaper.ShowConsoleMsg(string.format("track %s cannot toggle\n", tkNo))
    return
  end

  _toggleTrackEnableN(tkNo, track, tonumber(setting))

end

--[[
  A track can be toggled if it has MIDI In for All inputs.
  That's just how life is.
]]
function canToggle(track)
  -- Is this a MIDI track?
  local recInput = reaper.GetMediaTrackInfo_Value(track, "I_RECINPUT")
  if recInput & 4096 == 0 then
    return false
  end
-- Is this receiving all inputs?
-- return recInput & 31 == 0
-- This was for using a filter on a single track then sending that to all others
-- but that means turning off track MIDI input...
--  local retval, buf = reaper.GetTrackReceiveName(track, 0)
--  if recMon == 0 then
--    return false
--  end
--  if buf == "All MIDI In"
--  then
--  end

  local recArm = reaper.GetMediaTrackInfo_Value(track, "I_RECARM")
  if recArm == 0 then
    return false
  end
  local recMon = reaper.GetMediaTrackInfo_Value(track, "I_RECMON")
  if recMon == 0 then
    return false
  end
  local trackFXCount = reaper.TrackFX_GetCount(track)
  if trackFXCount > 0 then
    return true
  end
  return false
end

function _toggleTrackEnableN(tkNo, track, setting)
--local isTkFxEnabled = reaper.GetMediaTrackInfo_Value(track, "I_FXEN")
--reaper.ShowConsoleMsg("track " .. tkNo .. "; setting " .. setting .. "; isTkFxEnabled " .. isTkFxEnabled .. "\n")
  local srTk = 0
  local search = reaper.GetTrack(0, srTk)
  local srVal = 0

  while not(search == nil) do
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
