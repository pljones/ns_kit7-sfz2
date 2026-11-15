# What do we have here?

The Reaper project I use contains a few different parts:
- ns\_kit7 drum kits, built here.
- Native Instruments, Analogue Drums and other drum kits and instruments.
- Audio Ins from my sound card and ASIO Bridge.
- Audio Outs to various online jamming services.

## How do I use these?

This is why I am writing this.  I nearly forgot this bit.  That would not have been helpful...

Open Reaper (no project needed).

Go to "Actions" -> "Show action list" -> "New action..." -> "Load ReaScript"
and find the files to add.  Bulk add should work.

## Track Control

Track control covers two main areas:
- ns\_kit7 drum groups and their associated tracks.
- All the other instruments.

For these, an OSC message of the form `/track/<track number>/onOff` gets sent.
Very, very sadly, Reaper does not pattern match on incoming OSC messages,
so there need to be action scripts to handle each one:

    toggleTrackEnable{[1-9],[1-9][0-9],1[0-9][0-9]}.lua
    toggleTrackByOSC/

These all require `toggleTrackByOSC`, which is a LUA package (i.e. directory).
This contains the logic to manage the different track types.

As a side effect, they also toggle the soundcard input tracks.

## Online Services

I've tried several online jamming services.  For years, before the pandemic, I had my own
Jamulus server - but DSL and latency meant no one really used it.  Ninjam was more popular.
I tried Jamtaba as an alternative to Ninjam for a while.  I also briefly tried Sonobus.

    enableOnlineService.lua
    enableService-{jamkazam,jamtaba,jamulus,ninjam,sonobus}.lua

So all these have `enableService...` scripts which bind to `/<service name>/onOff` OSC messages.
These just call `enableOnlineService.lua`, which find the track by name (thankfully) and toggles it.

## Other Scripts

### `oldToggleTrackEnableN/`

What I used before redoing the ns\_kit7 kit organisation.

### `toggleReceiveMute.lua`

An experiement that lead to the new way of doing ns\_kit7 kits.
