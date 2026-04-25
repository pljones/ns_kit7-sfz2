# Region Logic

Region Logic opcodes define the conditions under which a voice plays or stops.

## MIDI Conditions
### lovel

If a note with velocity value equal to or higher than <code>lovel</code> AND equal to or lower than <code>hivel</code> is played, the region will play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `1`
**Range:** `1` to `127`

### hivel

If a note with velocity value equal to or higher than <code>lovel</code> AND equal to or lower than <code>hivel</code> is played, the region will play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `127`
**Range:** `1` to `127`

### lochan

If incoming notes have a MIDI channel between <code>lochan</code> and <code>hichan</code>, the region will play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `1`
**Range:** `1` to `16`

### hichan

If incoming notes have a MIDI channel between <code>lochan</code> and <code>hichan</code>, the region will play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `16`
**Range:** `1` to `16`

### loccN

Defines the range of the last MIDI controller N required for the region to play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### hiccN

Defines the range of the last MIDI controller N required for the region to play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `127`
**Range:** `0` to `127`

### lobend

Defines the range of the last Pitch Bend message required for the region to play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `-8192`
**Range:** `-8192` to `8192`

### hibend

Defines the range of the last Pitch Bend message required for the region to play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `8192`
**Range:** `-8192` to `8192`

### lochanaft

Defines the range of last Channel Aftertouch message required for the region to play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### hichanaft

Defines the range of last Channel Aftertouch message required for the region to play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `127`
**Range:** `0` to `127`

### lopolyaft

Defines the range of last Polyphonic Aftertouch message required for the region to play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### hipolyaft

Defines the range of last Polyphonic Aftertouch message required for the region to play.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `127`
**Range:** `0` to `127`

### sostenuto_cc

Reassigns the sostenuto pedal CC to a non-standard value.

**Version:** ARIA

**Type:** `integer`
**Default:** `66`
**Range:** `0` to `127`

### sostenuto_lo

Sets the minimum point at which the sostenuto pedal (MIDI CC 66) is considered 'down'.

**Version:** ARIA

**Type:** `float`
**Default:** `0.5`
**Range:** `0` to `127`

### sostenuto_sw

Turns the sostenuto switch on or off.

**Version:** SFZ v2

**Type:** `string`

### sustain_cc

Reassigns the sustain pedal CC to a non-standard value.

**Version:** ARIA

**Type:** `integer`
**Default:** `64`
**Range:** `0` to `127`

### sustain_lo

Sets the minimum point at which the sustain pedal (MIDI CC 64) is considered 'down'.

**Version:** ARIA

**Type:** `float`
**Default:** `0.5`
**Range:** `0` to `127`

### sustain_sw

Turns the sustain switch on or off.

**Version:** SFZ v2

**Type:** `string`

### sw_lokey

Defines the range of the keyboard to be used as trigger selectors for the <a href='4-sfz-region_logic.md#sw_last'>sw_last</a> opcode.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### sw_hikey

Defines the range of the keyboard to be used as trigger selectors for the <a href='4-sfz-region_logic.md#sw_last'>sw_last</a> opcode.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `127`
**Range:** `0` to `127`

### sw_last

Enables the region to play if the last key pressed in the range specified by <a href='4-sfz-region_logic.md#sw_lokey'>sw_lokey and sw_hikey</a> is equal to the <code>sw_last</code> value.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### sw_down

Enables the region to play if the key equal to <code>sw_down</code> value is depressed. Key has to be in the range specified by <a href='4-sfz-region_logic.md#sw_lokey'>sw_lokey and sw_hikey</a>.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### sw_up

Enables the region to play if the key equal to <code>sw_up</code> value is not depressed.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### sw_previous

Previous note value. The region will play if last note-on message was equal to <code>sw_previous</code> value.

**Version:** SFZ v1

**Type:** `integer`
**Range:** `0` to `127`

### sw_vel

Allows overriding the velocity for the region with the velocity of the previous note.

**Version:** SFZ v1

**Type:** `string`
**Default:** `current`

### loprog

The region plays when the MIDI program number is between <code>loprog</code> and <code>hiprog</code>.

**Version:** SFZ v2

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### hiprog

The region plays when the MIDI program number is between <code>loprog</code> and <code>hiprog</code>.

**Version:** SFZ v2

**Type:** `integer`
**Default:** `127`
**Range:** `0` to `127`

### lohdccN

Like <a href='4-sfz-region_logic.md#loccn'>loccN</a> but with floating point MIDI CCs

**Version:** ARIA

**Type:** `float`
**Default:** `0`
**Range:** `0` to `1`

### hihdccN

Like <a href='4-sfz-region_logic.md#hiccn'>hiccN</a> but with floating point MIDI CCs

**Version:** ARIA

**Type:** `float`
**Default:** `1`
**Range:** `0` to `1`

### sw_default

Define keyswitch 'power on default' so that you hear something when a patch loads.

**Version:** SFZ v2

**Type:** `integer`
**Range:** `0` to `127`

### sw_label

Label for activated keyswitch on GUI.

**Version:** ARIA

**Type:** `string`

### sw_lolast

Like <a href='4-sfz-region_logic.md#sw_last'>sw_last</a>, but allowing a region to be triggered across a range of keyswitches.

**Version:** ARIA

**Type:** `integer`
**Range:** `0` to `127`

### sw_hilast

Like <a href='4-sfz-region_logic.md#sw_last'>sw_last</a>, but allowing a region to be triggered across a range of keyswitches.

**Version:** ARIA

**Type:** `integer`
**Range:** `0` to `127`

### varNN_mod

Specifies the method used to calculate variable number NN from MIDI CCs.

**Version:** ARIA

**Type:** `string`

#### Modulation
**MIDI CC Modulation:**
- `varNN_onccX`: Specifies the method used to calculate variable number NN from MIDI CCs.
- `varNN_curveccX`: Specifies the &lt;<a href='7-sfz-curves.md'>curve</a>&gt; number which MIDI CC X uses to modulate varNN.

#### See Also
- [*_mod](3-sfz-instrument_settings.md#_mod)

### varNN_*

Specifies the target for variable NN to modulate.

**Version:** ARIA

## Internal Conditions
### lobpm

Host tempo value.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `500`
**Unit:** bpm

### hibpm

Host tempo value.

**Version:** SFZ v1

**Type:** `float`
**Default:** `500`
**Range:** `0` to `500`
**Unit:** bpm

### lorand

The region will play if the random number is equal to or higher than <code>lorand</code>, and lower than <code>hirand</code>.

**Version:** SFZ v1

**Type:** `float`
**Default:** `0`
**Range:** `0` to `1`

### hirand

The region will play if the random number is equal to or higher than <code>lorand</code>, and lower than <code>hirand</code>.

**Version:** SFZ v1

**Type:** `float`
**Default:** `1`
**Range:** `0` to `1`

### seq_length

Sequence length, used together with <a href='4-sfz-region_logic.md#seq_position'>seq_position</a> to use samples as round robins.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `1`
**Range:** `1` to `100`

### seq_position

Sequence position. The region will play if the internal sequence counter is equal to <code>seq_position</code>.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `1`
**Range:** `1` to `100`

### lotimer

Region plays if the time passed since the last sample in the same group played is between <code>lotimer</code> and <code>hitimer</code>.

**Version:** SFZ v2

**Type:** `float`

### hitimer

Region plays if timer is between <code>lotimer</code> and <code>hitimer</code>.

**Version:** SFZ v2

**Type:** `float`

## Triggers
### key

Equivalent to using <a href='4-sfz-region_logic.md#lokey'>lokey</a>, <a href='4-sfz-region_logic.md#hikey'>hikey</a> and <a href='5-sfz-performance_parameters.md#pitch_keycenter'>pitch_keycenter</a> and setting them all to the same note value.

**Version:** SFZ v1

**Type:** `integer`
**Range:** `0` to `127`

#### See Also
- [pitch_keycenter](5-sfz-performance_parameters.md#pitch_keycenter)

### lokey

Determine the low boundary of a certain <a href='0-sfz-headers.md#region'>region</a>.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `127`

### hikey

Determine the high boundary of a certain <a href='0-sfz-headers.md#region'>region</a>.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `127`
**Range:** `0` to `127`

### trigger

Sets the trigger which will be used for the sample to play.

**Version:** SFZ v1

**Type:** `string`
**Default:** `attack`

### on_loccN

If a MIDI control message with a value between <code>on_loccN</code> and <code>on_hiccN</code> is received, the region will play. Default value is -1, it means unassigned.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `-1`
**Range:** `0` to `127`

### on_hiccN

If a MIDI control message with a value between <code>on_loccN</code> and <code>on_hiccN</code> is received, the region will play. Default value is -1, it means unassigned.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `-1`
**Range:** `0` to `127`

### on_lohdccN

Like <a href='4-sfz-region_logic.md#on_loccn'>on_loccN</a> but with floating point MIDI CCs.

**Version:** ARIA

**Type:** `float`
**Default:** `-1`
**Range:** `0` to `1`

### on_hihdccN

Like <a href='4-sfz-region_logic.md#on_hiccn'>on_hiccN</a> but with floating point MIDI CCs.

**Version:** ARIA

**Type:** `float`
**Default:** `-1`
**Range:** `0` to `1`

### stop_loccN

If a MIDI control message with a value between <code>stop_loccN</code> and <code>stop_hiccN</code> is received, the region will stop playing. Default value is -1, it means unassigned.

**Version:** SFZ v2

**Type:** `integer`
**Default:** `-1`
**Range:** `0` to `127`

### stop_hiccN

If a MIDI control message with a value between <code>stop_loccN</code> and <code>stop_hiccN</code> is received, the region will stop playing. Default value is -1, it means unassigned.

**Version:** SFZ v2

**Type:** `integer`
**Default:** `-1`
**Range:** `0` to `127`

### stop_lohdccN

Like <a href='4-sfz-region_logic.md#stop_loccn'>stop_loccN</a> but with floating point MIDI CCs.

**Version:** ARIA

**Type:** `float`
**Default:** `-1`
**Range:** `0` to `1`

### stop_hihdccN

Like <a href='4-sfz-region_logic.md#stop_hiccn'>stop_hiccN</a> but with floating point MIDI CCs.

**Version:** ARIA

**Type:** `float`
**Default:** `-1`
**Range:** `0` to `1`
