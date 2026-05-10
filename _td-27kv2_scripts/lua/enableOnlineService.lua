--[[
/**
 * ReaScript Name: enableOnlineService
 * Description: Toggle parent send on a channel
 * Instructions:
 *  # Install this in user reaper scripts
 *  # Ensure /{service}/onOff is bound to enableService-{service}.lua (because there's no way to look up the shortcut).
 *  # Ensure online service track receive exists, called {service} RECEIVE (and no others like that).
 *  # (You can have multiple RECEIVEs with the same service name and they'll toggle as a group - the feedback
 *     will take account of the track number.)
 *
 * Currently there is no OSC feedback (it's not possible to send OSC from a script), so I fake it with StuffMIDIMessage.
 *
 * Author: pljones
 * Licence: GPL v3
 * Version: 0.3
 */
]]
-- Put these two lines into enableService-{service}.lua for each {service}:
-- dofile(debug.getinfo(1,'S').source:match[[^@?(.*[\/])[^\/]-$]] .. 'enableOnlineService.lua')
-- reaper.defer(enableService)

function initService()

  if not(initServiceDone == nil) then
    return
  end

  hwMidiOut = nil
  SVC_ENABLE = 110 -- CC no for service controls

  local wantedMIDIOutputName = "TouchOSC Bridge"
  local numMIDIOutputs = reaper.GetNumMIDIOutputs()

  local midiOut = 0
  while midiOut < numMIDIOutputs
  do
    retval, nameout = reaper.GetMIDIOutputName(midiOut, "")
    if not(nameout == nil) and nameout == wantedMIDIOutputName then
      hwMidiOut = midiOut
      midiOut = numMIDIOutputs
    end
    midiOut = midiOut + 1
  end
--reaper.ShowConsoleMsg("initService: " .. wantedMIDIOutputName .. " " .. hwMidiOut .. "\n")
  
  initServiceDone = true

end

function enableService()
  is_new,name,sec,cmd,rel,res,val = reaper.get_action_context()
  if not(is_new) then
    return
  end

  local service = name:match("^.+enableService%-?(.+)%.lua$")
  if (service == nil) then
    return
  end

  _enableService(service)
end

function _enableService(service)
--reaper.ShowConsoleMsg("service " .. service .. "; val " .. val .. "\n")
  local serviceNo = 0

  -- Skip all the instrument tracks, so may change
  local srTk = 0
  local search = reaper.GetTrack(0, srTk)
  while(not (search == nil))
  do

    local retVal, searchName = reaper.GetSetMediaTrackInfo_String(search, "P_NAME", "", false)
    if (not(searchName == nil)) then
      local receiveName, mic = searchName:match("^(.+) RECEIVE(.*)$")
      if (not(receiveName == nil)) then

--      reaper.ShowConsoleMsg("service " .. service .. "; searchName " .. searchName .. "\n")
        -- it's a service receive
        local ret
        if (service == receiveName) then
--      reaper.ShowConsoleMsg("service " .. service .. "; searchName " .. searchName .. "\n")
          -- this is track we are looking for
--[[
          Previously this side simply set the value "on" (1) for both commands
          Now it reads and toggles
]]
          local val = reaper.GetMediaTrackInfo_Value(search, "B_MAINSEND")
          if not(val == 0) then val = 0 else val = 1 end
          ret = reaper.SetMediaTrackInfo_Value(search, "B_MAINSEND", val)
          if (mic == "") then
            reaper.StuffMIDIMessage(16 + hwMidiOut, 0xBF, SVC_ENABLE + serviceNo, val)
          end
--        reaper.ShowConsoleMsg("service " .. service .. "; searchName " .. searchName .. ": set to " .. val .. "\n")
--[[
        else
          -- it's a service receive but a different one
          ret = reaper.SetMediaTrackInfo_Value(search, "B_MAINSEND", 0)
          reaper.StuffMIDIMessage(16 + hwMidiOut, 0xBF, SVC_ENABLE + serviceNo, 0)
]]
        end
        if (mic == "") then
          serviceNo = serviceNo + 1
        end

      end
    end

    srTk = srTk + 1
    search = reaper.GetTrack(0, srTk)

  end

end

initService()
