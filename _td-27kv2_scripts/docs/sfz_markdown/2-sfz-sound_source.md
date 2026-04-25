# Sound Source

Defines the nature of the voice generated. It could be samples or oscillators

## Sample Playback

Sample Playback opcodes defines the parameters of the sound generation.

### count

The number of times the sample will be played.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `4294967296`

### delay

Region delay time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

#### Modulation
**MIDI CC Modulation:**
- `delay_ccN`: Region delay time after MIDI continuous controller N messages are received. If the region receives a note-off message before delay time, the region won't play.
- `delay_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate delay.

### delay_random

Region random delay time.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `100`
**Unit:** seconds

### delay_samples

Allows the region playback to be postponed for the specified time, measured in samples (and therefore dependent on current sample rate).

**Version:** SFZ v2

**Type:** `integer`
**Unit:** sample units

#### Modulation
**MIDI CC Modulation:**
- `delay_samples_onccN`: 

### end

The endpoint of the sample. If unspecified, the entire sample will play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `unspecified`
**Range:** `0` to `4294967296`
**Unit:** sample units

### loop_count

The number of times a loop will repeat.

**Version:** SFZ v2

**Type:** `integer`

### loop_crossfade

Loop cross fade.

**Version:** SFZ v2

**Type:** `float`
**Unit:** seconds

### loop_end

The loop end point, in samples.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `4294967296`
**Unit:** sample units

#### Modulation
**MIDI CC Modulation:**
- `loop_lengthccN`: Change of loop end point.

### loop_mode

Allows playing samples with loops defined in the unlooped mode.

**Version:** SFZ v1

**Type:** `string`
**Default:** `<b>no_loop</b> for samples without a loop defined, <br><b>loop_continuous</b> for samples with defined loop(s).`

### loop_start

The loop start point, in samples.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `4294967296`
**Unit:** sample units

#### Modulation
**MIDI CC Modulation:**
- `loop_startccN`: Change of loop start point.

### loop_tune

Tuning for only the loop segment.

**Version:** SFZ v2

**Type:** `float`
**Default:** `0`
**Unit:** cents

### loop_type

Defines the looping mode.

**Version:** SFZ v2

**Type:** `string`
**Default:** `forward`

### offset

The offset used to play the sample.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `4294967296`
**Unit:** sample units

#### Modulation
**MIDI CC Modulation:**
- `offset_ccN`: The offset used to play the sample according to last position of MIDI continuous controller N.

### offset_random

Random offset added to the region offset.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `4294967296`
**Unit:** sample units

### offset_mode

Defines whether offset is measured in samples or percentage of sample length.

**Version:** ARIA

**Type:** `string`
**Default:** `samples`

### sample

Defines which sample file the region will play.

**Version:** SFZ v1

**Type:** `string`

### sample_fadeout

Number of seconds before the end of sample playback that the player should begin a realtime fadeout.

**Version:** SFZ v2

**Type:** `float`
**Unit:** seconds

### sample_dyn_paramN

ARIA-specific nameless destination for plugin modulations.

**Version:** ARIA

**Type:** `float`

#### Modulation
**MIDI CC Modulation:**
- `sample_dyn_paramN_onccX`: 

### sync_beats

Region playing synchronization to host position.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `32`
**Unit:** beats

### sync_offset

Region playing synchronization to host position offset.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `32`
**Unit:** beats

### delay_beats

Delays the start of the region until a certain amount of musical beats are passed.

**Version:** SFZ v2

**Type:** `float`
**Unit:** beats

#### Modulation
**MIDI CC Modulation:**
- `delay_beats_onccN`: 
- `delay_beats_curveccN`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC N uses to modulate delay_beats.

### delay_beats_random

Delays the start of the region after a random amount of musical beats.

**Version:** ARIA

**Type:** `float`
**Unit:** beats

### stop_beats

Stops a region after a certain amount of beats have played.

**Version:** SFZ v2

**Type:** `float`
**Unit:** beats

### direction

The direction in which the sample is to be played.

**Version:** SFZ v2

**Type:** `string`
**Default:** `forward`

### md5

Calculates the <a href='https://en.wikipedia.org/wiki/MD5'>MD5</a> digital fingerprint hash of a sample file, represented as a sequence of 32 hexadecimal digits.

**Version:** SFZ v2

**Type:** `string`
**Default:** `null`

### reverse_loccN

If MIDI CC N is between <code>reverse_loccN</code> and <code>reverse_hiccN</code>, the region plays reversed.

**Version:** SFZ v2

**Type:** `integer`
**Range:** `0` to `127`

### reverse_hiccN

If MIDI CC N is between <code>reverse_loccN</code> and <code>reverse_hiccN</code>, the region plays reversed.

**Version:** SFZ v2

**Type:** `integer`
**Range:** `0` to `127`

### waveguide

Enables waveguide synthesis for the region.

**Version:** SFZ v2

**Type:** `string`
