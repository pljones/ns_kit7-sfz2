dofile(debug.getinfo(1,'S').source:match[[^@?(.*[\/])[^\/]-$]] .. 'enableOnlineService.lua')
reaper.defer(enableService)

