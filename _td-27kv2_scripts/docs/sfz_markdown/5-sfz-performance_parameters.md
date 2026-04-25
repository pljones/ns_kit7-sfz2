# Performance Parameters

Performance Parameters are all sound modifiers.

## Amplifier
### pan

The panoramic position for the region.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `-100` to `100`
**Unit:** %

#### Modulation
**MIDI CC Modulation:**
- `pan_onccN`: 
- `pan_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate pan.
- `pan_smoothccN`: 
- `pan_stepccN`: 

### pan_random

Random panoramic position for the region.

**Version:** ARIA

**Type:** `float`
**Default:** `0`
**Range:** `-100` to `100`
**Unit:** %

### position

Only operational for stereo samples, <code>position</code> defines the position in the stereo field of a stereo signal, after channel mixing as defined in the <a href='5-sfz-performance_parameters.md#width'>width</a> opcode.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `-100` to `100`
**Unit:** %

#### Modulation
**MIDI CC Modulation:**
- `position_onccN`: 
- `position_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate position.
- `position_smoothccN`: 
- `position_stepccN`: 

### position_random

**Version:** ARIA

**Type:** `float`
**Default:** `0`
**Range:** `-100` to `100`
**Unit:** %

### position_keycenter

**Version:** ARIA

### position_keytrack

**Version:** ARIA

### position_veltrack

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `-200` to `200`

### volume

The volume for the region, in decibels.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `-144` to `6`
**Unit:** dB

#### Modulation
**MIDI CC Modulation:**
- `gain_ccN`: Gain applied on MIDI control N, in decibels.
- `volume_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate volume.
- `volume_smoothccN`: 
- `volume_stepccN`: 

#### See Also
- `Amplifier / Amplitude`
- `Cross fade`
- `Gain`
- `Volume`

### width

Only operational for stereo samples, width defines the amount of channel mixing applied to play the sample.

**Version:** SFZ v1

**Type:** `float`
**Default:** `100`
**Range:** `-100` to `100`
**Unit:** %

#### Modulation
**MIDI CC Modulation:**
- `width_onccN`: 
- `width_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate width.
- `width_smoothccN`: 
- `width_stepccN`: 

### amp_keycenter

Center key for amplifier keyboard tracking. In this key, the amplifier keyboard tracking will have no effect.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `60`
**Range:** `0` to `127`

### amp_keytrack

Amplifier keyboard tracking (change in amplitude per key) in decibels.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `-96` to `12`
**Unit:** dB

### amp_veltrack

Amplifier velocity tracking, represents how much the amplitude changes with incoming note velocity.

**Version:** SFZ v1

**Type:** `float`
**Default:** `100`
**Range:** `-100` to `100`
**Unit:** %

#### Modulation
**MIDI CC Modulation:**
- `amp_veltrack_onccN`: 
- `amp_veltrack_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate amp_veltrack.

### amp_veltrack_random

**Version:** ARIA

### amp_velcurve_N

User-defined amplifier velocity curve.

**Version:** SFZ v1

**Type:** `float`
**Default:** `Standard curve (see <a href='5-sfz-performance_parameters.md#amp_veltrack'>amp_veltrack</a>)`
**Range:** `0` to `1`

### amp_random

Random volume for the region, in decibels.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `24`
**Unit:** dB

### rt_decay

Applies only to regions that triggered through trigger=release. The volume decrease (in decibels) per seconds after the corresponding attack region was triggered.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `200`
**Unit:** dB

### rt_decayN

Applies only to regions that triggered through trigger=release. The volume decrease (in decibels) per seconds after the corresponding attack region was triggered, for decrease curve segment number N.

**Version:** ARIA

**Type:** `float`
**Default:** `0`
**Range:** `0` to `200`
**Unit:** dB

### rt_decayN_time

The duration of release sample volue decrease curve segment number N.

**Version:** ARIA

**Type:** `float`
**Unit:** seconds

### xf_cccurve

MIDI controllers crossfade curve for the region.

**Version:** SFZ v1

**Type:** `string`
**Default:** `power`

### xf_keycurve

Keyboard crossfade curve for the region.

**Version:** SFZ v1

**Type:** `string`
**Default:** `power`

### xf_velcurve

Velocity crossfade curve for the region.

**Version:** SFZ v1

**Type:** `string`
**Default:** `power`

### xfin_loccN

Fade in control based on MIDI CC.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### xfin_hiccN

Fade in control based on MIDI CC.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### xfout_loccN

Fade out control based on MIDI CC.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### xfout_hiccN

Fade out control based on MIDI CC.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### xfin_lokey

Fade in control based on MIDI note (keyboard position).

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### xfin_hikey

Fade in control based on MIDI note (keyboard position).

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### xfout_lokey

Fade out control based on MIDI note number (keyboard position).

**Version:** SFZ v1

**Type:** `integer`
**Default:** `127`
**Range:** `0` to `127`

### xfout_hikey

Fade out control based on MIDI note number (keyboard position).

**Version:** SFZ v1

**Type:** `integer`
**Default:** `127`
**Range:** `0` to `127`

### xfin_lovel

Fade in control based on velocity.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### xfin_hivel

Fade in control based on velocity.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### xfout_lovel

Fade out control, based on velocity.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `127`
**Range:** `0` to `127`

### xfout_hivel

Fade out control, based on velocity.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `127`
**Range:** `0` to `127`

### phase

If invert is set, the region is played with inverted phase.

**Version:** SFZ v2

**Type:** `string`
**Default:** `normal`

### amplitude

Amplitude for the specified region in percentage of full amplitude.

**Version:** ARIA

**Type:** `float`
**Default:** `100`
**Range:** `0` to `100`
**Unit:** %

#### Modulation
**MIDI CC Modulation:**
- `amplitude_onccN`: 
- `amplitude_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate amplitude.
- `amplitude_smoothccN`: 

### global_amplitude

ARIA extension, like <a href='5-sfz-performance_parameters.md#amplitude'>amplitude</a>, but affecting everything when set under the &lt;<a href='0-sfz-headers.md#global'>global</a>&gt; header.

**Version:** ARIA

**Type:** `float`
**Default:** `100`
**Range:** `0` to `100`
**Unit:** %

### master_amplitude

ARIA extension, like <a href='5-sfz-performance_parameters.md#amplitude'>amplitude</a>, but affecting everything when set under the &lt;<a href='0-sfz-headers.md#master'>master</a>&gt; header.

**Version:** ARIA

**Type:** `float`
**Default:** `100`
**Range:** `0` to `100`
**Unit:** %

### group_amplitude

ARIA extension, like <a href='5-sfz-performance_parameters.md#amplitude'>amplitude</a>, but affecting everything when set under the &lt;<a href='0-sfz-headers.md#group'>group</a>&gt; header.

**Version:** ARIA

**Type:** `float`
**Default:** `100`
**Range:** `0` to `100`
**Unit:** %

### pan_law

Sets the pan law to be used.

**Version:** ARIA

**Type:** `string`

### pan_keycenter

Center key for pan keyboard tracking.

**Version:** SFZ v2

**Type:** `integer`
**Default:** `60`
**Range:** `0` to `127`

### pan_keytrack

The amount by which the panning of a note is shifted with each key.

**Version:** SFZ v2

**Type:** `float`
**Default:** `0`
**Range:** `-100` to `100`
**Unit:** %

### pan_veltrack

The effect of note velocity on panning.

**Version:** SFZ v2

**Type:** `float`
**Default:** `0`
**Range:** `-100` to `100`
**Unit:** %

### global_volume

ARIA extension, like <a href='5-sfz-performance_parameters.md#volume'>volume</a>, but affecting everything when set under the &lt;<a href='0-sfz-headers.md#global'>global</a>&gt; header.

**Version:** ARIA

**Type:** `float`
**Default:** `0`
**Range:** `-144` to `6`
**Unit:** dB

### master_volume

ARIA extension, like <a href='5-sfz-performance_parameters.md#volume'>volume</a>, but affecting everything when set under the &lt;<a href='0-sfz-headers.md#master'>master</a>&gt; header.

**Version:** ARIA

**Type:** `float`
**Default:** `0`
**Range:** `-144` to `6`
**Unit:** dB

### group_volume

ARIA extension, like <a href='5-sfz-performance_parameters.md#volume'>volume</a>, but affecting everything when set under the &lt;<a href='0-sfz-headers.md#group'>group</a>&gt; header.

**Version:** ARIA

**Type:** `float`
**Default:** `0`
**Range:** `-144` to `6`
**Unit:** dB

## EQ
### eqN_bw

Bandwidth of the equalizer band, in octaves.

**Version:** SFZ v1

**Type:** `float`
**Default:** `1`
**Range:** `0.001` to `4`
**Unit:** octaves

#### Modulation
**MIDI CC Modulation:**
- `eqN_bwccX`: 

### eqN_freq

Frequency of the equalizer band, in Hertz.

**Version:** SFZ v1

**Type:** `float`
**Default:** `eq1_freq=50<br>eq2_freq=500<br>eq3_freq=5000`
**Range:** `0` to `30000`
**Unit:** Hz

#### Modulation
**MIDI CC Modulation:**
- `eqN_freqccX`: 

### eqN_gain

Gain of the equalizer band, in decibels.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `-96` to `24`
**Unit:** dB

#### Modulation
**MIDI CC Modulation:**
- `eqN_gainccX`: 

### eqN_dynamic

Specifies when EQ is recalculated.

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `1`

### eqN_type

Sets the type of EQ filter.

**Version:** SFZ v2

**Type:** `string`
**Default:** `peak`

## Filter
### cutoff

Sets the cutoff frequency (Hz) of the <a href='5-sfz-performance_parameters.md'>filters</a>.

**Version:** SFZ v1

**Type:** `float`
**Default:** `filter disabled`
**Range:** `0` to `SampleRate / 2`
**Unit:** Hz

#### Modulation
**MIDI CC Modulation:**
- `cutoff_ccN`: The variation in the cutoff frequency when MIDI continuous controller N is received.
- `cutoff_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate cutoff.
- `cutoff_smoothccN`: 
- `cutoff_stepccN`: 
- `cutoff_chanaft`: The variation in the cutoff frequency when MIDI channel aftertouch messages are received, in cents.
- `cutoff_polyaft`: The variation in the cutoff frequency when MIDI polyphonic aftertouch messages are received, in cents.

### fil_gain

Gain for lsh, hsh and peq filter types.

**Version:** ARIA

**Type:** `float`
**Default:** `0`
**Unit:** dB

#### Modulation
**MIDI CC Modulation:**
- `fil_gain_onccN`: 

### fil_keycenter

Center key for filter keyboard tracking.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `60`
**Range:** `0` to `127`

### fil_keytrack

Filter keyboard tracking (change on cutoff for each key) in cents.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `1200`
**Unit:** cents

### fil_random

Random value added to the filter cutoff for the region, in cents.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `9600`
**Unit:** cents

### fil_type

Filter type.

**Version:** SFZ v1

**Type:** `string`
**Default:** `lpf_2p`

#### See Also
- [delay_filter](8-sfz-effects.md#delay_filter)
- [filter_type](8-sfz-effects.md#filter_type)
- [static_filter](8-sfz-effects.md#static_filter)

### fil_veltrack

Filter velocity tracking, the amount by which the cutoff changes with incoming note velocity, in cents.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `-9600` to `9600`
**Unit:** cents

### resonance

The filter cutoff resonance value, in decibels.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `40`
**Unit:** dB

#### Modulation
**MIDI CC Modulation:**
- `resonance_onccN`: 
- `resonance_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate resonance.
- `resonance_smoothccN`: 
- `resonance_stepccN`: 

### resonance_random

Filter cutoff resonance random value, in decibels.

**Version:** ARIA

**Type:** `float`
**Default:** `0`
**Range:** `0` to `40`
**Unit:** dB

### resonance2_random

Filter#2 cutoff resonance random value, in decibels.

**Version:** ARIA

**Type:** `float`
**Default:** `0`
**Range:** `0` to `40`
**Unit:** dB

### noise_filter

**Version:** SFZ v2

**Type:** `string`

### noise_stereo

**Version:** SFZ v2

**Type:** `string`

### noise_level

**Version:** SFZ v2

**Type:** `float`
**Range:** `-96` to `24`
**Unit:** dB

#### Modulation
**MIDI CC Modulation:**
- `noise_level_onccN`: 
- `noise_level_smoothccN`: 

### noise_step

**Version:** SFZ v2

**Type:** `integer`
**Range:** `0` to `100`

#### Modulation
**MIDI CC Modulation:**
- `noise_step_onccN`: 

### noise_tone

**Version:** SFZ v2

**Type:** `integer`
**Range:** `0` to `100`

#### Modulation
**MIDI CC Modulation:**
- `noise_tone_onccN`: 

## Pitch
### bend_up

Pitch bend range when Bend Wheel or Joystick is moved up, in cents.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `200`
**Range:** `-9600` to `9600`
**Unit:** cents

### bend_down

Pitch bend range when Bend Wheel or Joystick is moved down, in cents.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `-200`
**Range:** `-9600` to `9600`
**Unit:** cents

### bend_smooth

Pitch bend smoothness. Adds “inertia” to pitch bends, so fast movements of the pitch bend wheel will have a delayed effect on the pitch change.

**Version:** SFZ v2

**Type:** `float`
**Default:** `0`
**Unit:** ms

### bend_step

Pitch bend step, in cents.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `1`
**Range:** `1` to `1200`
**Unit:** cents

### tune

The fine tuning for the sample, in cents.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `-100` to `100`
**Unit:** cents

#### Modulation
**MIDI CC Modulation:**
- `pitch_onccN`: 
- `pitch_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate pitch.
- `pitch_smoothccN`: 
- `pitch_stepccN`: 

### group_tune

ARIA extension, like <a href='5-sfz-performance_parameters.md#tune'>tune</a>, but affecting everything when set under the &lt;<a href='0-sfz-headers.md#group'>group</a>&gt; header.

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `-9600` to `9600`
**Unit:** cents

### master_tune

ARIA extension, like <a href='5-sfz-performance_parameters.md#tune'>tune</a>, but affecting everything when set under the &lt;<a href='0-sfz-headers.md#master'>master</a>&gt; header.

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `-9600` to `9600`
**Unit:** cents

### global_tune

ARIA extension, like <a href='5-sfz-performance_parameters.md#tune'>tune</a>, but affecting everything when set under the &lt;<a href='0-sfz-headers.md#global'>global</a>&gt; header.

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `-9600` to `9600`
**Unit:** cents

### pitch_keycenter

Root key for the <a href='2-sfz-sound_source.md#sample'>sample</a>.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `60`
**Range:** `0` to `127`

#### See Also
- [key](4-sfz-region_logic.md#key)

### pitch_keytrack

Within the region, this value defines how much the pitch changes with every note.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `100`
**Range:** `-1200` to `1200`
**Unit:** cents

### pitch_random

Random tuning for the region, in cents.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `9600`
**Unit:** cents

### pitch_veltrack

Pitch velocity tracking, represents how much the pitch changes with incoming note velocity, in cents.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `-9600` to `9600`
**Unit:** cents

### transpose

The transposition value for this region which will be applied to the sample.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `-127` to `127`

### bend_stepup

Pitch bend step, in cents, applied to upwards bends only.

**Version:** SFZ v2

**Type:** `integer`
**Default:** `1`
**Range:** `1` to `1200`
**Unit:** cents

### bend_stepdown

Pitch bend step, in cents, for downward pitch bends.

**Version:** SFZ v2

**Type:** `integer`
**Default:** `1`
**Range:** `1` to `1200`
**Unit:** cents
