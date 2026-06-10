dofile(debug.getinfo(1,'S').source:match[[^@?(.*[\/])[^\/]-$]] .. 'toggleTrackEnable.lua')
reaper.defer(toggleTrackEnable)
