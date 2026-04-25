# Modulation

Modulation opcodes comprise of all the LFO and EG controls.

## Envelope Generators
### ampeg_attack

EG attack time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `ampeg_attackccN`: 
- `ampeg_attack_curveccN`: 

### ampeg_decay

EG decay time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `ampeg_decayccN`: 
- `ampeg_decay_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate ampeg_decay.

### ampeg_delay

EG delay time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `ampeg_delayccN`: 
- `ampeg_delay_curveccN`: 

### ampeg_hold

EG hold time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `ampeg_holdccN`: 
- `ampeg_hold_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate ampeg_hold.

### ampeg_release

EG release time (after note release).

**Version:** SFZ v1

**Type:** `float`
**Default:** `0.001`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `ampeg_releaseccN`: 
- `ampeg_release_curveccN`: 

### ampeg_sustain

EG sustain level, in percentage.

**Version:** SFZ v1

**Type:** `float`
**Default:** `100`
**Range:** `0` to `100`
**Unit:** %

#### Modulation
**MIDI CC Modulation:**
- `ampeg_sustainccN`: 
- `ampeg_sustain_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate ampeg_sustain.

### ampeg_start

Envelope start level, in percentage.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** %

#### Modulation
**MIDI CC Modulation:**
- `ampeg_startccN`: 
- `ampeg_start_curveccN`: 

### ampeg_attack_shape

Specifies the curvature of attack stage of the envelope.

**Version:** ARIA

**Type:** `float`
**Default:** `0`

### ampeg_decay_shape

Specifies the curvature of decay stage of the envelope.

**Version:** ARIA

**Type:** `float`
**Default:** `-10.3616`

### ampeg_decay_zero

Specifies how decay time is calculated.

**Version:** ARIA

**Type:** `integer`
**Default:** `1`
**Range:** `0` to `1`

### ampeg_dynamic

Specifies when envelope durations are recalculated.

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `1`

### ampeg_release_shape

Specifies the curvature of release stage of the envelope.

**Version:** ARIA

**Type:** `float`
**Default:** `-10.3616`

### ampeg_release_zero

Specifies how release time is calculated.

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `1`

### fileg_attack_shape

Specifies the curvature of attack stage of the envelope.

**Version:** ARIA

**Type:** `float`
**Default:** `0`

### fileg_decay_shape

Specifies the curvature of decay stage of the envelope.

**Version:** ARIA

**Type:** `float`
**Default:** `0`

### fileg_decay_zero

Specifies how decay time is calculated.

**Version:** ARIA

**Type:** `integer`
**Default:** `1`
**Range:** `0` to `1`

### fileg_release_shape

Specifies the curvature of release stage of the envelope.

**Version:** ARIA

**Type:** `float`
**Default:** `0`

### fileg_release_zero

Specifies how release time is calculated.

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `1`

### fileg_dynamic

Specifies when envelope durations are recalculated.

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `1`

### pitcheg_attack_shape

Specifies the curvature of attack stage of the envelope.

**Version:** ARIA

**Type:** `float`
**Default:** `0`

### pitcheg_decay_shape

Specifies the curvature of decay stage of the envelope.

**Version:** ARIA

**Type:** `float`
**Default:** `0`

### pitcheg_decay_zero

Specifies how decay time is calculated.

**Version:** ARIA

**Type:** `integer`
**Default:** `1`
**Range:** `0` to `1`

### pitcheg_release_shape

Specifies the curvature of release stage of the envelope.

**Version:** ARIA

**Type:** `float`
**Default:** `0`

### pitcheg_release_zero

Specifies how release time is calculated.

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `1`

### pitcheg_dynamic

Specifies when envelope durations are recalculated.

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `1`

### fileg_attack

EG attack time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `fileg_attack_onccN`: 
- `fileg_attack_curveccN`: 

### fileg_decay

EG decay time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `fileg_decay_onccN`: 
- `fileg_decay_curveccN`: 

### fileg_delay

EG delay time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `fileg_delay_onccN`: 
- `fileg_delay_curveccN`: 

### fileg_depth

Envelope depth.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `-12000` to `12000`
**Unit:** cents

#### Modulation
**MIDI CC Modulation:**
- `fileg_depth_onccN`: 
- `fileg_depth_curveccN`: 

### fileg_hold

EG hold time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `fileg_hold_onccN`: 
- `fileg_hold_curveccN`: 

### fileg_release

EG release time (after note release).

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `fileg_release_onccN`: 
- `fileg_release_curveccN`: 

### fileg_start

Envelope start level, in percentage.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** %

#### Modulation
**MIDI CC Modulation:**
- `fileg_start_onccN`: 
- `fileg_start_curveccN`: 

### fileg_sustain

EG sustain level, in percentage.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** %

#### Modulation
**MIDI CC Modulation:**
- `fileg_sustain_onccN`: 
- `fileg_sustain_curveccN`: 

### pitcheg_attack

EG attack time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `pitcheg_attack_onccN`: 
- `pitcheg_attack_curveccN`: 

### pitcheg_decay

EG decay time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `pitcheg_decay_onccN`: 
- `pitcheg_decay_curveccN`: 

### pitcheg_delay

EG delay time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `pitcheg_delay_onccN`: 
- `pitcheg_delay_curveccN`: 

### pitcheg_depth

Envelope depth.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `-12000` to `12000`
**Unit:** cents

#### Modulation
**MIDI CC Modulation:**
- `pitcheg_depth_onccN`: 
- `pitcheg_depth_curveccN`: 

### pitcheg_hold

EG hold time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `pitcheg_hold_onccN`: 
- `pitcheg_hold_curveccN`: 

### pitcheg_release

EG release time (after note release).

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `pitcheg_release_onccN`: 
- `pitcheg_release_curveccN`: 

### pitcheg_start

Envelope start level, in percentage.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** %

#### Modulation
**MIDI CC Modulation:**
- `pitcheg_start_onccN`: 
- `pitcheg_start_curveccN`: 

### pitcheg_sustain

EG sustain level, in percentage.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** %

#### Modulation
**MIDI CC Modulation:**
- `pitcheg_sustain_onccN`: 
- `pitcheg_sustain_curveccN`: 

### egN_points

**Version:** SFZ v2

### egN_timeX

**Version:** SFZ v2

**Type:** `float`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `egN_timeX_onccY`: 

### egN_levelX

Sets the envelope level at a specific point in envelope number N.

**Version:** SFZ v2

**Type:** `float`
**Default:** `0`
**Range:** `-1` to `1`

#### Modulation
**MIDI CC Modulation:**
- `egN_levelX_onccY`: 

### egN_ampeg

**Version:** ARIA

### egN_dynamic

Specifies when envelope durations are recalculated.

**Version:** ARIA

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `1`

### egN_shapeX

**Version:** SFZ v2

**Type:** `float`
**Default:** `0`

### egN_curveX

Instructs the player to use a curve shape defined under a curve header for the specified envelope segment.

**Version:** SFZ v2

### egN_sustain

**Version:** SFZ v2

### egN_loop

**Version:** SFZ v2

### egN_loop_count

**Version:** SFZ v2

### egN_volume

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_volume_onccX`: 

### egN_amplitude

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_amplitude_onccX`: 

### egN_pan

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_pan_onccX`: 

### egN_width

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_width_onccX`: 

### egN_pan_curve

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_pan_curveccX`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC X uses to modulate egN_pan.

### egN_freq_lfoX

Allows egN to shape a change to lfoX's frequency

**Version:** SFZ v2

**Type:** `float`
**Default:** `0`
**Unit:** Hz

### egN_depth_lfoX

Allows egN to scale lfoX's effect on its targets

**Version:** SFZ v2

**Type:** `float`
**Default:** `100`
**Unit:** %

### egN_depthadd_lfoX

**Version:** SFZ v2

### egN_pitch

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_pitch_onccX`: 

### egN_cutoff

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_cutoff_onccX`: 

### egN_cutoff2

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_cutoff2_onccX`: 

### egN_resonance

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_resonance_onccX`: 

### egN_resonance2

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_resonance2_onccX`: 

### egN_eqXfreq

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_eqXfreq_onccY`: 

### egN_eqXbw

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_eqXbw_onccY`: 

### egN_eqXgain

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_eqXgain_onccY`: 

### egN_decim

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_decim_onccX`: 

### egN_bitred

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_bitred_onccX`: 

### egN_rectify

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_rectify_onccX`: 

### egN_ringmod

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_ringmod_onccX`: 

### egN_noiselevel

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_noiselevel_onccX`: 

### egN_noisestep

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_noisestep_onccX`: 

### egN_noisetone

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_noisetone_onccX`: 

### egN_driveshape

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `egN_driveshape_onccX`: 

### egN_sample_dyn_paramX

ARIA-specific nameless destination for plugin envelope modulations.

**Version:** ARIA

#### Modulation
**MIDI CC Modulation:**
- `egN_sample_dyn_paramX_onccY`: 

## LFO

Low Frequency Oscillator.

### amplfo_delay

The time before the LFO starts oscillating.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

### amplfo_depth

LFO depth.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `-10` to `10`
**Unit:** dB

#### Modulation
**MIDI CC Modulation:**
- `amplfo_depthccN`: 
- `amplfo_depthchanaft`: LFO depth when channel aftertouch MIDI messages are received.
- `amplfo_depthpolyaft`: LFO depth when polyphonic aftertouch MIDI messages are received.

### amplfo_fade

LFO fade-in effect time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

### amplfo_freq

LFO frequency, in hertz.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `20`
**Unit:** Hz

#### Modulation
**MIDI CC Modulation:**
- `amplfo_freqccN`: 
- `amplfo_freqchanaft`: LFO frequency change when channel aftertouch MIDI messages are received, in Hertz.
- `amplfo_freqpolyaft`: LFO frequency change when polyphonic aftertouch MIDI messages are received, in Hertz.

### fillfo_delay

The time before the LFO starts oscillating.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

### fillfo_depth

LFO depth.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `-1200` to `1200`
**Unit:** cents

#### Modulation
**MIDI CC Modulation:**
- `fillfo_depthccN`: 
- `fillfo_depthchanaft`: LFO depth when channel aftertouch MIDI messages are received.
- `fillfo_depthpolyaft`: LFO depth when polyphonic aftertouch MIDI messages are received.

### fillfo_fade

LFO fade-in effect time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

### fillfo_freq

LFO frequency, in hertz.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `20`
**Unit:** Hz

#### Modulation
**MIDI CC Modulation:**
- `fillfo_freqccN`: 
- `fillfo_freqchanaft`: LFO frequency change when channel aftertouch MIDI messages are received, in Hertz.
- `fillfo_freqpolyaft`: LFO frequency change when polyphonic aftertouch MIDI messages are received, in Hertz.

### pitchlfo_delay

The time before the LFO starts oscillating.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

### pitchlfo_depth

LFO depth.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `-1200` to `1200`
**Unit:** cents

#### Modulation
**MIDI CC Modulation:**
- `pitchlfo_depthccN`: 
- `pitchlfo_depthchanaft`: LFO depth when channel aftertouch MIDI messages are received.
- `pitchlfo_depthpolyaft`: LFO depth when polyphonic aftertouch MIDI messages are received.

### pitchlfo_fade

LFO fade-in effect time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

### pitchlfo_freq

LFO frequency, in hertz.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `20`
**Unit:** Hz

#### Modulation
**MIDI CC Modulation:**
- `pitchlfo_freqccN`: 
- `pitchlfo_freqchanaft`: LFO frequency change when channel aftertouch MIDI messages are received, in Hertz.
- `pitchlfo_freqpolyaft`: LFO frequency change when polyphonic aftertouch MIDI messages are received, in Hertz.

### lfoN_freq

The base frequency of LFO number N, in Hertz.

**Version:** SFZ v2

**Type:** `float`
**Unit:** Hz

#### Modulation
**MIDI CC Modulation:**
- `lfoN_freq_onccX`: 
- `lfoN_freq_smoothccX`: 
- `lfoN_freq_stepccX`: 

#### See Also
- [lfoN_delay](6-sfz-modulation.md#lfon_delay)
- [lfoN_fade](6-sfz-modulation.md#lfon_fade)
- [lfoN_offset](6-sfz-modulation.md#lfon_offset)
- [lfoN_ratio](6-sfz-modulation.md#lfon_ratio)
- [lfoN_scale](6-sfz-modulation.md#lfon_scale)
- [lfoN_wave](6-sfz-modulation.md#lfon_wave)

### lfoN_delay

Onset delay for LFO number N.

**Version:** SFZ v2

**Type:** `float`
**Default:** `0`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `lfoN_delay_onccX`: 

#### See Also
- [lfoN_fade](6-sfz-modulation.md#lfon_fade)
- [lfoN_freq](6-sfz-modulation.md#lfon_freq)
- [lfoN_offset](6-sfz-modulation.md#lfon_offset)
- [lfoN_ratio](6-sfz-modulation.md#lfon_ratio)
- [lfoN_scale](6-sfz-modulation.md#lfon_scale)
- [lfoN_wave](6-sfz-modulation.md#lfon_wave)

### lfoN_fade

Fade-in time for LFO number N.

**Version:** SFZ v2

**Type:** `float`

#### Modulation
**MIDI CC Modulation:**
- `lfoN_fade_onccX`: 

#### See Also
- [lfoN_delay](6-sfz-modulation.md#lfon_delay)
- [lfoN_freq](6-sfz-modulation.md#lfon_freq)
- [lfoN_offset](6-sfz-modulation.md#lfon_offset)
- [lfoN_ratio](6-sfz-modulation.md#lfon_ratio)
- [lfoN_scale](6-sfz-modulation.md#lfon_scale)
- [lfoN_wave](6-sfz-modulation.md#lfon_wave)

### lfoN_phase

Initial phase shift for LFO number N.

**Version:** SFZ v2

**Type:** `float`
**Default:** `0`
**Range:** `0` to `1`

#### Modulation
**MIDI CC Modulation:**
- `lfoN_phase_onccX`: 

### lfoN_count

Number of LFO repetitions for LFO N before the LFO stops.

**Version:** SFZ v2

**Type:** `integer`

### lfoN_wave

LFO waveform selection.

**Version:** SFZ v2

**Type:** `integer`
**Default:** `1`

#### Modulation
**MIDI CC Modulation:**
- `lfoN_wave_onccX`: 

#### See Also
- [lfoN_delay](6-sfz-modulation.md#lfon_delay)
- [lfoN_fade](6-sfz-modulation.md#lfon_fade)
- [lfoN_freq](6-sfz-modulation.md#lfon_freq)
- [lfoN_offset](6-sfz-modulation.md#lfon_offset)
- [lfoN_ratio](6-sfz-modulation.md#lfon_ratio)
- [lfoN_scale](6-sfz-modulation.md#lfon_scale)

### lfoN_steps

Number of steps in LFO step sequencer.

**Version:** SFZ v2

**Type:** `integer`

### lfoN_stepX

Level of the step number X in LFO step sequencer.

**Version:** SFZ v2

**Type:** `float`
**Range:** `-100` to `100`
**Unit:** percent

#### Modulation
**MIDI CC Modulation:**
- `lfoN_stepX_onccY`: 

### lfoN_smooth

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_smooth_onccX`: 

### lfoN_volume

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_volume_onccX`: 
- `lfoN_volume_smoothccX`: 
- `lfoN_volume_stepccX`: 

### lfoN_amplitude

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_amplitude_onccX`: 
- `lfoN_amplitude_smoothccX`: 
- `lfoN_amplitude_stepccX`: 

### lfoN_pan

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_pan_onccX`: 
- `lfoN_pan_smoothccX`: 
- `lfoN_pan_stepccX`: 

### lfoN_width

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_width_onccX`: 
- `lfoN_width_smoothccX`: 
- `lfoN_width_stepccX`: 

### lfoN_freq_lfoX

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_freq_lfoX_onccY`: 

### lfoN_depth_lfoX

**Version:** SFZ v2

### lfoN_depthadd_lfoX

**Version:** SFZ v2

### lfoN_pitch

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_pitch_curveccX`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC X uses to modulate lfoN_pitch.
- `lfoN_pitch_onccX`: 
- `lfoN_pitch_smoothccX`: 
- `lfoN_pitch_stepccX`: 

### lfoN_cutoff

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_cutoff_onccX`: 
- `lfoN_cutoff_smoothccX`: 
- `lfoN_cutoff_stepccX`: 

### lfoN_resonance

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_resonance_onccX`: 
- `lfoN_resonance_smoothccX`: 
- `lfoN_resonance_stepccX`: 

### lfoN_eqXfreq

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_eqXfreq_onccY`: 
- `lfoN_eqXfreq_smoothccY`: 
- `lfoN_eqXfreq_stepccY`: 

### lfoN_eqXbw

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_eqXbw_onccY`: 
- `lfoN_eqXbw_smoothccY`: 
- `lfoN_eqXbw_stepccY`: 

### lfoN_eqXgain

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_eqXgain_onccY`: 
- `lfoN_eqXgain_smoothccY`: 
- `lfoN_eqXgain_stepccY`: 

### lfoN_decim

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_decim_onccX`: 
- `lfoN_decim_smoothccX`: 
- `lfoN_decim_stepccX`: 

### lfoN_bitred

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_bitred_onccX`: 
- `lfoN_bitred_smoothccX`: 
- `lfoN_bitred_stepccX`: 

### lfoN_noiselevel

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_noiselevel_onccX`: 
- `lfoN_noiselevel_smoothccX`: 
- `lfoN_noiselevel_stepccX`: 

### lfoN_noisestep

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_noisestep_onccX`: 
- `lfoN_noisestep_smoothccX`: 
- `lfoN_noisestep_stepccX`: 

### lfoN_noisetone

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_noisetone_onccX`: 
- `lfoN_noisetone_smoothccX`: 
- `lfoN_noisetone_stepccX`: 

### lfoN_drive

**Version:** SFZ v2

#### Modulation
**MIDI CC Modulation:**
- `lfoN_drive_onccX`: 
- `lfoN_drive_smoothccX`: 
- `lfoN_drive_stepccX`: 

### lfoN_offset

DC offset - Add to LFO output; not affected by scale.

**Version:** ARIA

**Type:** `float`

#### See Also
- [lfoN_delay](6-sfz-modulation.md#lfon_delay)
- [lfoN_fade](6-sfz-modulation.md#lfon_fade)
- [lfoN_freq](6-sfz-modulation.md#lfon_freq)
- [lfoN_ratio](6-sfz-modulation.md#lfon_ratio)
- [lfoN_scale](6-sfz-modulation.md#lfon_scale)
- [lfoN_wave](6-sfz-modulation.md#lfon_wave)

### lfoN_ratio

Sets the ratio between the specified sub waveform and the main waveform.

**Version:** ARIA

**Type:** `float`

#### See Also
- [lfoN_delay](6-sfz-modulation.md#lfon_delay)
- [lfoN_fade](6-sfz-modulation.md#lfon_fade)
- [lfoN_freq](6-sfz-modulation.md#lfon_freq)
- [lfoN_offset](6-sfz-modulation.md#lfon_offset)
- [lfoN_scale](6-sfz-modulation.md#lfon_scale)
- [lfoN_wave](6-sfz-modulation.md#lfon_wave)

### lfoN_scale

Sets the scaling between the specified sub waveform and the main waveform.

**Version:** ARIA

**Type:** `float`

#### See Also
- [lfoN_delay](6-sfz-modulation.md#lfon_delay)
- [lfoN_fade](6-sfz-modulation.md#lfon_fade)
- [lfoN_freq](6-sfz-modulation.md#lfon_freq)
- [lfoN_offset](6-sfz-modulation.md#lfon_offset)
- [lfoN_ratio](6-sfz-modulation.md#lfon_ratio)
- [lfoN_wave](6-sfz-modulation.md#lfon_wave)

### lfoN_sample_dyn_paramX

ARIA-specific nameless destination for plugin LFO modulations.

**Version:** ARIA

#### Modulation
**MIDI CC Modulation:**
- `lfoN_sample_dyn_paramX_onccY`: 
