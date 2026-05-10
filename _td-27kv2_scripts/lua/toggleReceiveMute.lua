--[[
/**
 * ReaScript Name: toggleReceiveMute
 * Description:
 *   Toggle receive mute from a track to its receives.
 *   You can have one send track and various configurations of receives.
 *   The original intent was to switch between two receive targets.
 * Instructions:
 *   # Install this in user reaper scripts
 *   # Edit to suit:
 *     - you need a send track name
 *     - you need one or more tracks receiving from that track
 *   # Bind to this script (and remember to close the script editor before trying it out)
 *
 * Author: pljones
 * Licence: GPL v3
 * Version: 0.2
 */
]]
function initReceiveMute()

  if not(initReceiveMuteDone == nil) then
    return
  end

  savedSend = nil
  local sendTrackName = "Microphone"

  local srTk = 0
  local search = reaper.GetTrack(0, srTk)
  while(not (search == nil))
  do

    local tkName, f = reaper.GetTrackState(search)
    if (tkName == sendTrackName)
    then
      savedSend = search
--reaper.ShowConsoleMsg("initReceiveMute: " .. tkName .. "; srTk " .. srTk .. "\n")

      -- break out of the while
      search = nil

    else
      -- continue the while
      srTk = srTk + 1
      search = reaper.GetTrack(0, srTk)
    end

  end

  initReceiveMuteDone = true

end

function toggleReceiveMute()
  local is_new,name,sec,cmd,rel,res,val = reaper.get_action_context()
-- local m_is_new
-- if (is_new) then m_is_new = "true" else m_is_new = "false" end
-- reaper.ShowConsoleMsg("... is_new: " .. m_is_new .. "; name: " .. name .. "; sec: " .. sec .. "; cmd: " .. cmd .. ", rel: " .. rel .. "; res: " .. res .. "; val: " .. val .. "\n")
  if not(is_new) then
    return
  end

  initReceiveMute()

  -- Find receives from configured track
  local srTk = 0
  local search = reaper.GetTrack(0, srTk)
  while(not (search == nil))
  do

    local max_srRx = reaper.GetTrackNumSends(search, -1)
    local srRx = 0
    while(srRx < max_srRx)
    do

      local send = reaper.GetTrackSendInfo_Value(search, -1, srRx, "P_SRCTRACK")
      if (send == savedSend)
      then
        local mute = reaper.GetTrackSendInfo_Value(search, -1, srRx, "B_MUTE")
-- local tkName, f = reaper.GetTrackState(search)
-- reaper.ShowConsoleMsg("toggleReceiveMute: " .. tkName .. "; srTk " .. srTk .. "; srRx " .. srRx .. "; mute: " .. mute .. "\n")
        if (not(mute == 1.0)) then mute = 1.0 else mute = 0.0 end
-- local result =
          reaper.SetTrackSendInfo_Value(search, -1, srRx, "B_MUTE", mute)
-- if (result) then reaper.ShowConsoleMsg("; set: true; value: " .. mute .. "\n") else reaper.ShowConsoleMsg("; set: false; value: " .. mute .. "\n") end

      end

      srRx = srRx + 1
      send = reaper.GetTrackSendInfo_Value(search, -1, srRx, "P_SRCTRACK")

    end

    srTk = srTk + 1
    search = reaper.GetTrack(0, srTk)

  end

-- reaper.ShowConsoleMsg("---\n\n\n")
end

toggleReceiveMute()


