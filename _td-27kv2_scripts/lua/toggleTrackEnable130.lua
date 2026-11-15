package.path = package.path .. ";" .. debug.getinfo(1,'S').source:match[[^@?(.*[\/])[^\/]-$]] .. '?\\init.lua'
require('toggleTrackByOSC')
reaper.defer(toggleTrackByOSC.toggleTrackEnable)