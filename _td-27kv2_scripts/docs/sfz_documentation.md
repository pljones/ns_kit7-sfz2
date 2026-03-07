# SFZ Syntax Documentation

**Format Version:** 2

**Supported Versions:** ARIA, Calfbox, LinuxSampler, SFZ v1, SFZ v2, sfizz

---

## Headers
The following headers define the hierarchy of an SFZ instrument:

| Header | Version | Description |
| :--- | :--- | :--- |
| `<region>` | SFZ v1 | The basic component of an instrument. An instrument is defined by one or more regions. |
| `<group>` | SFZ v1 | Multiple regions can be arranged in a group. Groups allow entering common parameters for multiple regions. |
| `<control>` | SFZ v2 |  |
| `<global>` | SFZ v2 | Allows entering parameters which are common for all regions. |
| `<curve>` | SFZ v2 | A header for defining curves for MIDI CC controls. |
| `<effect>` | SFZ v2 | SFZ v2 header for effects controls. |
| `<master>` | ARIA | An intermediate level in the header hierarchy, between global and group. |
| `<midi>` | ARIA | ARIA extension, was added for MIDI pre-processor effects. From ARIA v1.0.8.0+ an &lt;<a href='/headers/effect'>effect<a>&gt; section with a <a href='/opcodes/bus'>bus</a>=midi can be used instead. |
| `<sample>` | SFZ v2 | Allows to embed sample data directly in SFZ files (Rapture). |

---

## Opcodes by Category

### Real-Time Instrument Script
* **ID:** `scr`
* **URL:** http://doc.linuxsampler.org/Instrument_Scripts/
* **script**: Allows to load real-time instrument scripts for SFZ instruments. (Version: LinuxSampler; Type: string)

### Sound Source
* **URL:** /misc/categories#sound-source

Defines the nature of the voice generated. It could be samples or oscillators

#### Sample Playback
* **Type ID:** `spl`

Sample Playback opcodes defines the parameters of the sound generation.

* **count**: The number of times the sample will be played. (Version: SFZ v1; Type: integer, Range: 0 to 4294967296, Default: 0)
* **delay**: Region delay time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **delay_random**: Region random delay time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **delay_samples**: Allows the region playback to be postponed for the specified time, measured in samples (and therefore dependent on current sample rate). (Version: SFZ v2; Type: integer)
* **end**: The endpoint of the sample. If unspecified, the entire sample will play. (Version: SFZ v1; Type: integer, Range: 0 to 4294967296, Default: unspecified)
* **loop_count**: The number of times a loop will repeat. (Version: SFZ v2; Type: integer)  
  *Aliases: `loopcount`*
* **loop_crossfade**: Loop cross fade. (Version: SFZ v2; Type: float)
* **loop_end**: The loop end point, in samples. (Version: SFZ v1; Type: integer, Range: 0 to 4294967296, Default: 0)  
  *Aliases: `loopend`*
* **loop_mode**: Allows playing samples with loops defined in the unlooped mode. (Version: SFZ v1; Type: string, Default: <b>no_loop</b> for samples without a loop defined, <br><b>loop_continuous</b> for samples with defined loop(s).)  
  *Aliases: `loopmode`*
* **loop_start**: The loop start point, in samples. (Version: SFZ v1; Type: integer, Range: 0 to 4294967296, Default: 0)  
  *Aliases: `loopstart`*
* **loop_tune**: Tuning for only the loop segment. (Version: SFZ v2; Type: float, Default: 0)  
  *Aliases: `looptune`*
* **loop_type**: Defines the looping mode. (Version: SFZ v2; Type: string, Default: forward)  
  *Aliases: `looptype`*
* **offset**: The offset used to play the sample. (Version: SFZ v1; Type: integer, Range: 0 to 4294967296, Default: 0)
* **offset_random**: Random offset added to the region offset. (Version: SFZ v1; Type: integer, Range: 0 to 4294967296, Default: 0)
* **offset_mode**: Defines whether offset is measured in samples or percentage of sample length. (Version: ARIA; Type: string, Default: samples)
* **sample**: Defines which sample file the region will play. (Version: SFZ v1; Type: string)
* **sample_fadeout**: Number of seconds before the end of sample playback that the player should begin a realtime fadeout. (Version: SFZ v2; Type: float)
* **sample_dyn_paramN**: ARIA-specific nameless destination for plugin modulations. (Version: ARIA; Type: float)
* **sync_beats**: Region playing synchronization to host position. (Version: SFZ v1; Type: float, Range: 0 to 32, Default: 0)
* **sync_offset**: Region playing synchronization to host position offset. (Version: SFZ v1; Type: float, Range: 0 to 32, Default: 0)
* **delay_beats**: Delays the start of the region until a certain amount of musical beats are passed. (Version: SFZ v2; Type: float)
* **delay_beats_random**: Delays the start of the region after a random amount of musical beats. (Version: ARIA; Type: float)
* **stop_beats**: Stops a region after a certain amount of beats have played. (Version: SFZ v2; Type: float)
* **direction**: The direction in which the sample is to be played. (Version: SFZ v2; Type: string, Default: forward)
* **md5**: Calculates the <a href='https://en.wikipedia.org/wiki/MD5'>MD5</a> digital fingerprint hash of a sample file, represented as a sequence of 32 hexadecimal digits. (Version: SFZ v2; Type: string, Default: null)
* **reverse_loccN**: If MIDI CC N is between <code>reverse_loccN</code> and <code>reverse_hiccN</code>, the region plays reversed. (Version: SFZ v2; Type: integer, Range: 0 to 127)
* **reverse_hiccN**: If MIDI CC N is between <code>reverse_loccN</code> and <code>reverse_hiccN</code>, the region plays reversed. (Version: SFZ v2; Type: integer, Range: 0 to 127)
* **waveguide**: Enables waveguide synthesis for the region. (Version: SFZ v2; Type: string)

### Instrument Settings
* **ID:** `ins`
* **URL:** /misc/categories#instrument-settings

Opcodes used under the <control> header.

* **#define**: Creates a variable and gives it a value. (Version: SFZ v2; Type: string)
* **default_path**: Default file path. (Version: SFZ v2; Type: string)
* **note_offset**: MIDI note transpose; tells the SFZ player to offset all incoming MIDI notes by the specified number of semitones. (Version: SFZ v2; Type: integer, Range: -127 to 127, Default: 0)
* **octave_offset**: MIDI octave transpose; tells the SFZ player to offset all incoming MIDI notes by the specified number of octaves. (Version: SFZ v2; Type: integer, Range: -10 to 10, Default: 0)
* **label_ccN**: Creates a label for the MIDI CC. (Version: ARIA; Type: string)
* **label_keyN**: Creates a label for a key. (Version: sfizz; Type: string)
* **label_outputN**: Creates a label for the <a href='/opcodes/output'>output</a> N. (Version: Calfbox; Type: string)
* **set_ccN**: Sets a default initial value for MIDI CC number N, when the instrument is initially loaded. (Version: SFZ v2; Type: integer, Range: 0 to 127)
* **#include**: A special directive, which allows using SFZ files as building blocks for creating larger, more complex SFZ files. (Version: ARIA; Type: string)
* **hint_***: Its a 'hint' to the ARIA engine, others implementations don't have to follow. (Version: ARIA)
* ***_mod**: Determines whether a parameter is modulated by addition or multiplication. (Version: ARIA; Type: string)
* **set_hdccN**: Like <a href='/opcodes/set_ccN'>set_ccN</a> but with floating point MIDI CCs. (Version: ARIA; Type: float, Range: 0 to 1)  
  *Aliases: `set_realccN`*
* **sw_note_offset**: Follows the same logic as SFZ 2.0’s <a href='/opcodes/note_offset'>note_offset</a> but for key switches. (Version: ARIA; Type: integer)
* **sw_octave_offset**: Follows the same logic as SFZ 2.0’s <a href='/opcodes/octave_offset'>octave_offset</a> but for key switches. (Version: ARIA; Type: integer)
* **loop_end_offset**: Subtracts 1 from sample numbers in file metadata, as a workaround for incorrectly generated loop points. (Version: ARIA; Type: integer, Range: -1 to 0, Default: 0)
* **global_label**: An ARIA extension which sets what is displayed in the default info tab of Sforzando. (Version: ARIA; Type: string)
* **master_label**: An ARIA extension which sets what is displayed in the default info tab of Sforzando. (Version: ARIA; Type: string)
* **group_label**: An ARIA extension which sets what is displayed in the default info tab of Sforzando. (Version: ARIA; Type: string)
* **region_label**: An ARIA extension which sets what is displayed in the default info tab of Sforzando. (Version: ARIA; Type: string)

#### Voice Lifecycle
* **Type ID:** `vlc`
* **group**: Exclusive group number for this region. (Version: SFZ v1; Type: integer, Range: -2147483648 to 2147483647, Default: 0)  
  *Aliases: `polyphony_group`*
* **off_by**: Region off group. (Version: SFZ v1; Type: integer, Range: -2147483648 to 2147483647, Default: 0)  
  *Aliases: `offby`*
* **off_mode**: Region off mode. (Version: SFZ v1; Type: string, Default: fast)
* **output**: The stereo output number for this region. (Version: SFZ v1; Type: integer, Range: 0 to 1024, Default: 0)
* **polyphony**: Polyphony voice limit. (Version: SFZ v2; Type: integer)
* **note_polyphony**: Polyphony limit for playing the same note repeatedly. (Version: SFZ v2; Type: integer)
* **polyphony_stealing**:  (Version: ARIA; Type: integer)
* **note_selfmask**: Controls note-stealing behavior for a single pitch, when using <a href='/opcodes/note_polyphony'>note_polyphony</a>. (Version: SFZ v2; Type: string, Default: on)
* **rt_dead**: Controls whether a release sample should play if its sustain sample has ended, or not. (Version: SFZ v2; Type: string, Default: off)
* **off_curve**: When <a href='/opcodes/off_mode'>off_mode</a> is set to time, this specifies the math to be used to fade out the regions being muted by voice-stealing. (Version: ARIA; Type: integer, Range: -2 to 10, Default: 10)
* **off_shape**: The coefficient used by <a href='/opcodes/off_curve'>off_curve</a>. (Version: ARIA; Type: float, Default: -10.3616)
* **off_time**: When <a href='/opcodes/off_mode'>off_mode</a> is set to time, this specifies the fadeout time for regions being muted by voice-stealing. (Version: ARIA; Type: float, Default: 0.006)

### Region Logic
* **URL:** /misc/categories#region-logic

Region Logic opcodes define the conditions under which a voice plays or stops.

#### Key Mapping
* **Type ID:** `map`
* **key**: Equivalent to using <a href='/opcodes/lokey'>lokey</a>, <a href='/opcodes/hikey'>hikey</a> and <a href='/opcodes/pitch_keycenter'>pitch_keycenter</a> and setting them all to the same note value. (Version: SFZ v1; Type: integer, Range: 0 to 127)
* **lokey**: Determine the low boundary of a certain <a href='/headers/region'>region</a>. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **hikey**: Determine the high boundary of a certain <a href='/headers/region'>region</a>. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 127)
* **lovel**: If a note with velocity value equal to or higher than <code>lovel</code> AND equal to or lower than <code>hivel</code> is played, the region will play. (Version: SFZ v1; Type: integer, Range: 1 to 127, Default: 1)
* **hivel**: If a note with velocity value equal to or higher than <code>lovel</code> AND equal to or lower than <code>hivel</code> is played, the region will play. (Version: SFZ v1; Type: integer, Range: 1 to 127, Default: 127)

#### MIDI Conditions
* **Type ID:** `mid`
* **lochan**: If incoming notes have a MIDI channel between <code>lochan</code> and <code>hichan</code>, the region will play. (Version: SFZ v1; Type: integer, Range: 1 to 16, Default: 1)
* **hichan**: If incoming notes have a MIDI channel between <code>lochan</code> and <code>hichan</code>, the region will play. (Version: SFZ v1; Type: integer, Range: 1 to 16, Default: 16)
* **loccN**: Defines the range of the last MIDI controller N required for the region to play. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **hiccN**: Defines the range of the last MIDI controller N required for the region to play. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 127)
* **lobend**: Defines the range of the last Pitch Bend message required for the region to play. (Version: SFZ v1; Type: integer, Range: -8192 to 8192, Default: -8192)
* **hibend**: Defines the range of the last Pitch Bend message required for the region to play. (Version: SFZ v1; Type: integer, Range: -8192 to 8192, Default: 8192)
* **sostenuto_cc**: Reassigns the sostenuto pedal CC to a non-standard value. (Version: ARIA; Type: integer, Range: 0 to 127, Default: 66)
* **sostenuto_lo**: Sets the minimum point at which the sostenuto pedal (MIDI CC 66) is considered 'down'. (Version: ARIA; Type: float, Range: 0 to 127, Default: 0.5)
* **sostenuto_sw**: Turns the sostenuto switch on or off. (Version: SFZ v2; Type: string)
* **sustain_cc**: Reassigns the sustain pedal CC to a non-standard value. (Version: ARIA; Type: integer, Range: 0 to 127, Default: 64)
* **sustain_lo**: Sets the minimum point at which the sustain pedal (MIDI CC 64) is considered 'down'. (Version: ARIA; Type: float, Range: 0 to 127, Default: 0.5)
* **sustain_sw**: Turns the sustain switch on or off. (Version: SFZ v2; Type: string)
* **sw_lokey**: Defines the range of the keyboard to be used as trigger selectors for the <a href='/opcodes/sw_last'>sw_last</a> opcode. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: -1)
* **sw_hikey**: Defines the range of the keyboard to be used as trigger selectors for the <a href='/opcodes/sw_last'>sw_last</a> opcode. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: -1)
* **sw_last**: Enables the region to play if the last key pressed in the range specified by <a href='/opcodes/sw_lokey'>sw_lokey and sw_hikey</a> is equal to the <code>sw_last</code> value. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: -1)
* **sw_down**: Enables the region to play if the key equal to <code>sw_down</code> value is depressed. Key has to be in the range specified by <a href='/opcodes/sw_lokey'>sw_lokey and sw_hikey</a>. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: -1)
* **sw_up**: Enables the region to play if the key equal to <code>sw_up</code> value is not depressed. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: -1)
* **sw_previous**: Previous note value. The region will play if last note-on message was equal to <code>sw_previous</code> value. (Version: SFZ v1; Type: integer, Range: 0 to 127)
* **sw_vel**: Allows overriding the velocity for the region with the velocity of the previous note. (Version: SFZ v1; Type: string, Default: current)
* **loprog**: The region plays when the MIDI program number is between <code>loprog</code> and <code>hiprog</code>. (Version: SFZ v2; Type: integer, Range: 0 to 127, Default: 0)
* **hiprog**: The region plays when the MIDI program number is between <code>loprog</code> and <code>hiprog</code>. (Version: SFZ v2; Type: integer, Range: 0 to 127, Default: 127)
* **lohdccN**: Like <a href='/opcodes/loccN'>loccN</a> but with floating point MIDI CCs (Version: ARIA; Type: float, Range: 0 to 1, Default: 0)
* **hihdccN**: Like <a href='/opcodes/hiccN'>hiccN</a> but with floating point MIDI CCs (Version: ARIA; Type: float, Range: 0 to 1, Default: 1)
* **sw_default**: Define keyswitch 'power on default' so that you hear something when a patch loads. (Version: SFZ v2; Type: integer, Range: 0 to 127)
* **sw_label**: Label for activated keyswitch on GUI. (Version: ARIA; Type: string)
* **sw_lolast**: Like <a href='/opcodes/sw_last'>sw_last</a>, but allowing a region to be triggered across a range of keyswitches. (Version: ARIA; Type: integer, Range: 0 to 127)
* **sw_hilast**: Like <a href='/opcodes/sw_last'>sw_last</a>, but allowing a region to be triggered across a range of keyswitches. (Version: ARIA; Type: integer, Range: 0 to 127)
* **varNN_mod**: Specifies the method used to calculate variable number NN from MIDI CCs. (Version: ARIA; Type: string)
* **varNN_***: Specifies the target for variable NN to modulate. (Version: ARIA)

#### Internal Conditions
* **Type ID:** `int`
* **lobpm**: Host tempo value. (Version: SFZ v1; Type: float, Range: 0 to 500, Default: 0)
* **hibpm**: Host tempo value. (Version: SFZ v1; Type: float, Range: 0 to 500, Default: 500)
* **lochanaft**: Defines the range of last Channel Aftertouch message required for the region to play. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **hichanaft**: Defines the range of last Channel Aftertouch message required for the region to play. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 127)
* **lopolyaft**: Defines the range of last Polyphonic Aftertouch message required for the region to play. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **hipolyaft**: Defines the range of last Polyphonic Aftertouch message required for the region to play. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 127)
* **lorand**: The region will play if the random number is equal to or higher than <code>lorand</code>, and lower than <code>hirand</code>. (Version: SFZ v1; Type: float, Range: 0 to 1, Default: 0)
* **hirand**: The region will play if the random number is equal to or higher than <code>lorand</code>, and lower than <code>hirand</code>. (Version: SFZ v1; Type: float, Range: 0 to 1, Default: 1)
* **seq_length**: Sequence length, used together with <a href='/opcodes/seq_position'>seq_position</a> to use samples as round robins. (Version: SFZ v1; Type: integer, Range: 1 to 100, Default: 1)
* **seq_position**: Sequence position. The region will play if the internal sequence counter is equal to <code>seq_position</code>. (Version: SFZ v1; Type: integer, Range: 1 to 100, Default: 1)
* **lotimer**: Region plays if the time passed since the last sample in the same group played is between <code>lotimer</code> and <code>hitimer</code>. (Version: SFZ v2; Type: float)
* **hitimer**: Region plays if timer is between <code>lotimer</code> and <code>hitimer</code>. (Version: SFZ v2; Type: float)

#### Triggers
* **Type ID:** `trg`
* **trigger**: Sets the trigger which will be used for the sample to play. (Version: SFZ v1; Type: string, Default: attack)
* **on_loccN**: If a MIDI control message with a value between <code>on_loccN</code> and <code>on_hiccN</code> is received, the region will play. Default value is -1, it means unassigned. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: -1)  
  *Aliases: `start_loccN`*
* **on_hiccN**: If a MIDI control message with a value between <code>on_loccN</code> and <code>on_hiccN</code> is received, the region will play. Default value is -1, it means unassigned. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: -1)  
  *Aliases: `start_hiccN`*
* **on_lohdccN**: Like <a href='/opcodes/on_loccN'>on_loccN</a> but with floating point MIDI CCs. (Version: ARIA; Type: float, Range: 0 to 1, Default: -1)  
  *Aliases: `start_lohdccN`*
* **on_hihdccN**: Like <a href='/opcodes/on_hiccN'>on_hiccN</a> but with floating point MIDI CCs. (Version: ARIA; Type: float, Range: 0 to 1, Default: -1)  
  *Aliases: `start_hihdccN`*
* **stop_loccN**: If a MIDI control message with a value between <code>stop_loccN</code> and <code>stop_hiccN</code> is received, the region will stop playing. Default value is -1, it means unassigned. (Version: SFZ v2; Type: integer, Range: 0 to 127, Default: -1)
* **stop_hiccN**: If a MIDI control message with a value between <code>stop_loccN</code> and <code>stop_hiccN</code> is received, the region will stop playing. Default value is -1, it means unassigned. (Version: SFZ v2; Type: integer, Range: 0 to 127, Default: -1)
* **stop_lohdccN**: Like <a href='/opcodes/stop_loccN'>stop_loccN</a> but with floating point MIDI CCs. (Version: ARIA; Type: float, Range: 0 to 1, Default: -1)
* **stop_hihdccN**: Like <a href='/opcodes/stop_hiccN'>stop_hiccN</a> but with floating point MIDI CCs. (Version: ARIA; Type: float, Range: 0 to 1, Default: -1)

### Performance Parameters
* **URL:** /misc/categories#performance-parameters

Performance Parameters are all sound modifiers.

#### Amplifier
* **Type ID:** `amp`
* **pan**: The panoramic position for the region. (Version: SFZ v1; Type: float, Range: -100 to 100, Default: 0)
* **pan_random**: Random panoramic position for the region. (Version: ARIA; Type: float, Range: -100 to 100, Default: 0)
* **position**: Only operational for stereo samples, <code>position</code> defines the position in the stereo field of a stereo signal, after channel mixing as defined in the <a href='/opcodes/width'>width</a> opcode. (Version: SFZ v1; Type: float, Range: -100 to 100, Default: 0)
* **position_random**:  (Version: ARIA; Type: float, Range: -100 to 100, Default: 0)
* **position_keycenter**:  (Version: ARIA)
* **position_keytrack**:  (Version: ARIA)
* **position_veltrack**:  (Version: ARIA; Type: integer, Range: -200 to 200, Default: 0)
* **volume**: The volume for the region, in decibels. (Version: SFZ v1; Type: float, Range: -144 to 6, Default: 0)
* **width**: Only operational for stereo samples, width defines the amount of channel mixing applied to play the sample. (Version: SFZ v1; Type: float, Range: -100 to 100, Default: 100)
* **amp_keycenter**: Center key for amplifier keyboard tracking. In this key, the amplifier keyboard tracking will have no effect. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 60)
* **amp_keytrack**: Amplifier keyboard tracking (change in amplitude per key) in decibels. (Version: SFZ v1; Type: float, Range: -96 to 12, Default: 0)
* **amp_veltrack**: Amplifier velocity tracking, represents how much the amplitude changes with incoming note velocity. (Version: SFZ v1; Type: float, Range: -100 to 100, Default: 100)
* **amp_veltrack_random**:  (Version: ARIA)
* **amp_velcurve_N**: User-defined amplifier velocity curve. (Version: SFZ v1; Type: float, Range: 0 to 1, Default: Standard curve (see <a href='/opcodes/amp_veltrack'>amp_veltrack</a>))
* **amp_random**: Random volume for the region, in decibels. (Version: SFZ v1; Type: float, Range: 0 to 24, Default: 0)  
  *Aliases: `gain_random`*
* **rt_decay**: Applies only to regions that triggered through trigger=release. The volume decrease (in decibels) per seconds after the corresponding attack region was triggered. (Version: SFZ v1; Type: float, Range: 0 to 200, Default: 0)
* **rt_decayN**: Applies only to regions that triggered through trigger=release. The volume decrease (in decibels) per seconds after the corresponding attack region was triggered, for decrease curve segment number N. (Version: ARIA; Type: float, Range: 0 to 200, Default: 0)
* **rt_decayN_time**: The duration of release sample volue decrease curve segment number N. (Version: ARIA; Type: float)
* **xf_cccurve**: MIDI controllers crossfade curve for the region. (Version: SFZ v1; Type: string, Default: power)
* **xf_keycurve**: Keyboard crossfade curve for the region. (Version: SFZ v1; Type: string, Default: power)
* **xf_velcurve**: Velocity crossfade curve for the region. (Version: SFZ v1; Type: string, Default: power)
* **xfin_loccN**: Fade in control based on MIDI CC. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **xfin_hiccN**: Fade in control based on MIDI CC. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **xfout_loccN**: Fade out control based on MIDI CC. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **xfout_hiccN**: Fade out control based on MIDI CC. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **xfin_lokey**: Fade in control based on MIDI note (keyboard position). (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **xfin_hikey**: Fade in control based on MIDI note (keyboard position). (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **xfout_lokey**: Fade out control based on MIDI note number (keyboard position). (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 127)
* **xfout_hikey**: Fade out control based on MIDI note number (keyboard position). (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 127)
* **xfin_lovel**: Fade in control based on velocity. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **xfin_hivel**: Fade in control based on velocity. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 0)
* **xfout_lovel**: Fade out control, based on velocity. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 127)
* **xfout_hivel**: Fade out control, based on velocity. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 127)
* **phase**: If invert is set, the region is played with inverted phase. (Version: SFZ v2; Type: string, Default: normal)
* **amplitude**: Amplitude for the specified region in percentage of full amplitude. (Version: ARIA; Type: float, Range: 0 to 100, Default: 100)
* **global_amplitude**: ARIA extension, like <a href='/opcodes/amplitude'>amplitude</a>, but affecting everything when set under the &lt;<a href='/headers/global'>global</a>&gt; header. (Version: ARIA; Type: float, Range: 0 to 100, Default: 100)
* **master_amplitude**: ARIA extension, like <a href='/opcodes/amplitude'>amplitude</a>, but affecting everything when set under the &lt;<a href='/headers/master'>master</a>&gt; header. (Version: ARIA; Type: float, Range: 0 to 100, Default: 100)
* **group_amplitude**: ARIA extension, like <a href='/opcodes/amplitude'>amplitude</a>, but affecting everything when set under the &lt;<a href='/headers/group'>group</a>&gt; header. (Version: ARIA; Type: float, Range: 0 to 100, Default: 100)
* **pan_law**: Sets the pan law to be used. (Version: ARIA; Type: string)
* **pan_keycenter**: Center key for pan keyboard tracking. (Version: SFZ v2; Type: integer, Range: 0 to 127, Default: 60)
* **pan_keytrack**: The amount by which the panning of a note is shifted with each key. (Version: SFZ v2; Type: float, Range: -100 to 100, Default: 0)
* **pan_veltrack**: The effect of note velocity on panning. (Version: SFZ v2; Type: float, Range: -100 to 100, Default: 0)
* **global_volume**: ARIA extension, like <a href='/opcodes/volume'>volume</a>, but affecting everything when set under the &lt;<a href='/headers/global'>global</a>&gt; header. (Version: ARIA; Type: float, Range: -144 to 6, Default: 0)
* **master_volume**: ARIA extension, like <a href='/opcodes/volume'>volume</a>, but affecting everything when set under the &lt;<a href='/headers/master'>master</a>&gt; header. (Version: ARIA; Type: float, Range: -144 to 6, Default: 0)
* **group_volume**: ARIA extension, like <a href='/opcodes/volume'>volume</a>, but affecting everything when set under the &lt;<a href='/headers/group'>group</a>&gt; header. (Version: ARIA; Type: float, Range: -144 to 6, Default: 0)

#### EQ
* **Type ID:** `eq`
* **eqN_bw**: Bandwidth of the equalizer band, in octaves. (Version: SFZ v1; Type: float, Range: 0.001 to 4, Default: 1)
* **eqN_freq**: Frequency of the equalizer band, in Hertz. (Version: SFZ v1; Type: float, Range: 0 to 30000, Default: eq1_freq=50<br>eq2_freq=500<br>eq3_freq=5000)
* **eqN_gain**: Gain of the equalizer band, in decibels. (Version: SFZ v1; Type: float, Range: -96 to 24, Default: 0)
* **eqN_dynamic**: Specifies when EQ is recalculated. (Version: ARIA; Type: integer, Range: 0 to 1, Default: 0)
* **eqN_mode**: Specifies whether EQ frequency modulation is in cents or Hertz. Valid values are hz and cents. (Version: ARIA; Type: string, Default: hz)
* **eqN_type**: Sets the type of EQ filter. (Version: SFZ v2; Type: string, Default: peak)

#### Filter
* **Type ID:** `flt`
* **cutoff**: Sets the cutoff frequency (Hz) of the <a href='/misc/categories#performance-parameters'>filters</a>. (Version: SFZ v1; Type: float, Range: 0 to SampleRate / 2, Default: filter disabled)  
  *Aliases: `cutoff2`*
* **fil_gain**: Gain for lsh, hsh and peq filter types. (Version: ARIA; Type: float, Default: 0)  
  *Aliases: `fil2_gain`*
* **fil_keycenter**: Center key for filter keyboard tracking. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 60)  
  *Aliases: `fil2_keycenter`*
* **fil_keytrack**: Filter keyboard tracking (change on cutoff for each key) in cents. (Version: SFZ v1; Type: integer, Range: 0 to 1200, Default: 0)  
  *Aliases: `fil2_keytrack`*
* **fil_mode**: Specifies whether filter modulation is in cents or Hertz. Valid values are cents and hz (Version: ARIA; Type: string, Default: cents)  
  *Aliases: `fil2_mode`*
* **fil_random**: Random value added to the filter cutoff for the region, in cents. (Version: SFZ v1; Type: integer, Range: 0 to 9600, Default: 0)  
  *Aliases: `cutoff_random`, `cutoff2_random`*
* **fil_type**: Filter type. (Version: SFZ v1; Type: string, Default: lpf_2p)  
  *Aliases: `filtype`, `fil2_type`*
* **fil_veltrack**: Filter velocity tracking, the amount by which the cutoff changes with incoming note velocity, in cents. (Version: SFZ v1; Type: integer, Range: -9600 to 9600, Default: 0)  
  *Aliases: `fil2_veltrack`*
* **resonance**: The filter cutoff resonance value, in decibels. (Version: SFZ v1; Type: float, Range: 0 to 40, Default: 0)  
  *Aliases: `resonance2`*
* **resonance_random**: Filter cutoff resonance random value, in decibels. (Version: ARIA; Type: float, Range: 0 to 40, Default: 0)
* **resonance2_random**: Filter#2 cutoff resonance random value, in decibels. (Version: ARIA; Type: float, Range: 0 to 40, Default: 0)
* **noise_filter**:  (Version: SFZ v2; Type: string)
* **noise_stereo**:  (Version: SFZ v2; Type: string)
* **noise_level**:  (Version: SFZ v2; Type: float, Range: -96 to 24)
* **noise_step**:  (Version: SFZ v2; Type: integer, Range: 0 to 100)
* **noise_tone**:  (Version: SFZ v2; Type: integer, Range: 0 to 100)

#### Pitch
* **Type ID:** `ptc`
* **bend_up**: Pitch bend range when Bend Wheel or Joystick is moved up, in cents. (Version: SFZ v1; Type: integer, Range: -9600 to 9600, Default: 200)  
  *Aliases: `bendup`*
* **bend_down**: Pitch bend range when Bend Wheel or Joystick is moved down, in cents. (Version: SFZ v1; Type: integer, Range: -9600 to 9600, Default: -200)  
  *Aliases: `benddown`*
* **bend_smooth**: Pitch bend smoothness. Adds “inertia” to pitch bends, so fast movements of the pitch bend wheel will have a delayed effect on the pitch change. (Version: SFZ v2; Type: float, Default: 0)
* **bend_step**: Pitch bend step, in cents. (Version: SFZ v1; Type: integer, Range: 1 to 1200, Default: 1)  
  *Aliases: `bendstep`*
* **tune**: The fine tuning for the sample, in cents. (Version: SFZ v1; Type: integer, Range: -100 to 100, Default: 0)  
  *Aliases: `pitch`*
* **group_tune**: ARIA extension, like <a href='/opcodes/tune'>tune</a>, but affecting everything when set under the &lt;<a href='/headers/group'>group</a>&gt; header. (Version: ARIA; Type: integer, Range: -9600 to 9600, Default: 0)
* **master_tune**: ARIA extension, like <a href='/opcodes/tune'>tune</a>, but affecting everything when set under the &lt;<a href='/headers/master'>master</a>&gt; header. (Version: ARIA; Type: integer, Range: -9600 to 9600, Default: 0)
* **global_tune**: ARIA extension, like <a href='/opcodes/tune'>tune</a>, but affecting everything when set under the &lt;<a href='/headers/global'>global</a>&gt; header. (Version: ARIA; Type: integer, Range: -9600 to 9600, Default: 0)
* **pitch_keycenter**: Root key for the <a href='/opcodes/sample'>sample</a>. (Version: SFZ v1; Type: integer, Range: 0 to 127, Default: 60)
* **pitch_keytrack**: Within the region, this value defines how much the pitch changes with every note. (Version: SFZ v1; Type: integer, Range: -1200 to 1200, Default: 100)  
  *Aliases: `tune_keytrack`*
* **pitch_random**: Random tuning for the region, in cents. (Version: SFZ v1; Type: integer, Range: 0 to 9600, Default: 0)  
  *Aliases: `tune_random`*
* **pitch_veltrack**: Pitch velocity tracking, represents how much the pitch changes with incoming note velocity, in cents. (Version: SFZ v1; Type: integer, Range: -9600 to 9600, Default: 0)  
  *Aliases: `tune_veltrack`*
* **transpose**: The transposition value for this region which will be applied to the sample. (Version: SFZ v1; Type: integer, Range: -127 to 127, Default: 0)
* **bend_stepup**: Pitch bend step, in cents, applied to upwards bends only. (Version: SFZ v2; Type: integer, Range: 1 to 1200, Default: 1)
* **bend_stepdown**: Pitch bend step, in cents, for downward pitch bends. (Version: SFZ v2; Type: integer, Range: 1 to 1200, Default: 1)

### Modulation
* **URL:** /misc/categories#modulation

Modulation opcodes comprise of all the LFO and EG controls.

#### Envelope Generators
* **Type ID:** `eg`
* **ampeg_attack**: EG attack time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `amp_attack`*
* **ampeg_decay**: EG decay time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `amp_decay`*
* **ampeg_delay**: EG delay time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `amp_delay`*
* **ampeg_hold**: EG hold time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `amp_hold`*
* **ampeg_release**: EG release time (after note release). (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0.001)  
  *Aliases: `amp_release`*
* **ampeg_sustain**: EG sustain level, in percentage. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 100)  
  *Aliases: `amp_sustain`*
* **ampeg_start**: Envelope start level, in percentage. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **ampeg_attack_shape**: Specifies the curvature of attack stage of the envelope. (Version: ARIA; Type: float, Default: 0)
* **ampeg_decay_shape**: Specifies the curvature of decay stage of the envelope. (Version: ARIA; Type: float, Default: -10.3616)
* **ampeg_decay_zero**: Specifies how decay time is calculated. (Version: ARIA; Type: integer, Range: 0 to 1, Default: 1)
* **ampeg_dynamic**: Specifies when envelope durations are recalculated. (Version: ARIA; Type: integer, Range: 0 to 1, Default: 0)
* **ampeg_release_shape**: Specifies the curvature of release stage of the envelope. (Version: ARIA; Type: float, Default: -10.3616)
* **ampeg_release_zero**: Specifies how release time is calculated. (Version: ARIA; Type: integer, Range: 0 to 1, Default: 0)
* **fileg_attack_shape**: Specifies the curvature of attack stage of the envelope. (Version: ARIA; Type: float, Default: 0)
* **fileg_decay_shape**: Specifies the curvature of decay stage of the envelope. (Version: ARIA; Type: float, Default: 0)
* **fileg_decay_zero**: Specifies how decay time is calculated. (Version: ARIA; Type: integer, Range: 0 to 1, Default: 1)
* **fileg_release_shape**: Specifies the curvature of release stage of the envelope. (Version: ARIA; Type: float, Default: 0)
* **fileg_release_zero**: Specifies how release time is calculated. (Version: ARIA; Type: integer, Range: 0 to 1, Default: 0)
* **fileg_dynamic**: Specifies when envelope durations are recalculated. (Version: ARIA; Type: integer, Range: 0 to 1, Default: 0)
* **pitcheg_attack_shape**: Specifies the curvature of attack stage of the envelope. (Version: ARIA; Type: float, Default: 0)
* **pitcheg_decay_shape**: Specifies the curvature of decay stage of the envelope. (Version: ARIA; Type: float, Default: 0)
* **pitcheg_decay_zero**: Specifies how decay time is calculated. (Version: ARIA; Type: integer, Range: 0 to 1, Default: 1)
* **pitcheg_release_shape**: Specifies the curvature of release stage of the envelope. (Version: ARIA; Type: float, Default: 0)
* **pitcheg_release_zero**: Specifies how release time is calculated. (Version: ARIA; Type: integer, Range: 0 to 1, Default: 0)
* **pitcheg_dynamic**: Specifies when envelope durations are recalculated. (Version: ARIA; Type: integer, Range: 0 to 1, Default: 0)
* **fileg_attack**: EG attack time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `fil_attack`*
* **fileg_decay**: EG decay time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `fil_decay`*
* **fileg_delay**: EG delay time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `fil_delay`*
* **fileg_depth**: Envelope depth. (Version: SFZ v1; Type: integer, Range: -12000 to 12000, Default: 0)  
  *Aliases: `fil_depth`*
* **fileg_hold**: EG hold time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `fil_hold`*
* **fileg_release**: EG release time (after note release). (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `fil_release`*
* **fileg_start**: Envelope start level, in percentage. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **fileg_sustain**: EG sustain level, in percentage. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `fil_sustain`*
* **pitcheg_attack**: EG attack time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `pitch_attack`*
* **pitcheg_decay**: EG decay time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `pitch_decay`*
* **pitcheg_delay**: EG delay time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `pitch_delay`*
* **pitcheg_depth**: Envelope depth. (Version: SFZ v1; Type: integer, Range: -12000 to 12000, Default: 0)  
  *Aliases: `pitch_depth`*
* **pitcheg_hold**: EG hold time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `pitch_hold`*
* **pitcheg_release**: EG release time (after note release). (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `pitch_release`*
* **pitcheg_start**: Envelope start level, in percentage. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **pitcheg_sustain**: EG sustain level, in percentage. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)  
  *Aliases: `pitch_sustain`*
* **egN_points**:  (Version: SFZ v2)
* **egN_timeX**:  (Version: SFZ v2; Type: float)
* **egN_levelX**: Sets the envelope level at a specific point in envelope number N. (Version: SFZ v2; Type: float, Range: -1 to 1, Default: 0)
* **egN_ampeg**:  (Version: ARIA)
* **egN_dynamic**: Specifies when envelope durations are recalculated. (Version: ARIA; Type: integer, Range: 0 to 1, Default: 0)
* **egN_shapeX**:  (Version: SFZ v2; Type: float, Default: 0)
* **egN_curveX**: Instructs the player to use a curve shape defined under a curve header for the specified envelope segment. (Version: SFZ v2)
* **egN_sustain**:  (Version: SFZ v2)
* **egN_loop**:  (Version: SFZ v2)
* **egN_loop_count**:  (Version: SFZ v2)
* **egN_volume**:  (Version: SFZ v2)
* **egN_amplitude**:  (Version: SFZ v2)
* **egN_pan**:  (Version: SFZ v2)
* **egN_width**:  (Version: SFZ v2)
* **egN_pan_curve**:  (Version: SFZ v2)
* **egN_freq_lfoX**: Allows egN to shape a change to lfoX's frequency (Version: SFZ v2; Type: float, Default: 0)
* **egN_depth_lfoX**: Allows egN to scale lfoX's effect on its targets (Version: SFZ v2; Type: float, Default: 100)
* **egN_depthadd_lfoX**:  (Version: SFZ v2)
* **egN_pitch**:  (Version: SFZ v2)
* **egN_cutoff**:  (Version: SFZ v2)
* **egN_cutoff2**:  (Version: SFZ v2)
* **egN_resonance**:  (Version: SFZ v2)
* **egN_resonance2**:  (Version: SFZ v2)
* **egN_eqXfreq**:  (Version: SFZ v2)
* **egN_eqXbw**:  (Version: SFZ v2)
* **egN_eqXgain**:  (Version: SFZ v2)
* **egN_decim**:  (Version: SFZ v2)
* **egN_bitred**:  (Version: SFZ v2)
* **egN_rectify**:  (Version: SFZ v2)
* **egN_ringmod**:  (Version: SFZ v2)
* **egN_noiselevel**:  (Version: SFZ v2)
* **egN_noisestep**:  (Version: SFZ v2)
* **egN_noisetone**:  (Version: SFZ v2)
* **egN_driveshape**:  (Version: SFZ v2)
* **egN_sample_dyn_paramX**: ARIA-specific nameless destination for plugin envelope modulations. (Version: ARIA)

#### LFO
* **Type ID:** `lfo`

Low Frequency Oscillator.

* **amplfo_delay**: The time before the LFO starts oscillating. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **amplfo_depth**: LFO depth. (Version: SFZ v1; Type: float, Range: -10 to 10, Default: 0)
* **amplfo_fade**: LFO fade-in effect time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **amplfo_freq**: LFO frequency, in hertz. (Version: SFZ v1; Type: float, Range: 0 to 20, Default: 0)
* **fillfo_delay**: The time before the LFO starts oscillating. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **fillfo_depth**: LFO depth. (Version: SFZ v1; Type: float, Range: -1200 to 1200, Default: 0)
* **fillfo_fade**: LFO fade-in effect time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **fillfo_freq**: LFO frequency, in hertz. (Version: SFZ v1; Type: float, Range: 0 to 20, Default: 0)
* **pitchlfo_delay**: The time before the LFO starts oscillating. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **pitchlfo_depth**: LFO depth. (Version: SFZ v1; Type: float, Range: -1200 to 1200, Default: 0)
* **pitchlfo_fade**: LFO fade-in effect time. (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **pitchlfo_freq**: LFO frequency, in hertz. (Version: SFZ v1; Type: float, Range: 0 to 20, Default: 0)
* **lfoN_freq**: The base frequency of LFO number N, in Hertz. (Version: SFZ v2; Type: float)
* **lfoN_delay**: Onset delay for LFO number N. (Version: SFZ v2; Type: float, Default: 0)
* **lfoN_fade**: Fade-in time for LFO number N. (Version: SFZ v2; Type: float)
* **lfoN_phase**: Initial phase shift for LFO number N. (Version: SFZ v2; Type: float, Range: 0 to 1, Default: 0)
* **lfoN_count**: Number of LFO repetitions for LFO N before the LFO stops. (Version: SFZ v2; Type: integer)
* **lfoN_wave**: LFO waveform selection. (Version: SFZ v2; Type: integer, Default: 1)  
  *Aliases: `lfoN_waveX`*
* **lfoN_steps**: Number of steps in LFO step sequencer. (Version: SFZ v2; Type: integer)
* **lfoN_stepX**: Level of the step number X in LFO step sequencer. (Version: SFZ v2; Type: float, Range: -100 to 100)
* **lfoN_smooth**:  (Version: SFZ v2)
* **lfoN_volume**:  (Version: SFZ v2)
* **lfoN_amplitude**:  (Version: SFZ v2)
* **lfoN_pan**:  (Version: SFZ v2)
* **lfoN_width**:  (Version: SFZ v2)
* **lfoN_freq_lfoX**:  (Version: SFZ v2)
* **lfoN_depth_lfoX**:  (Version: SFZ v2)
* **lfoN_depthadd_lfoX**:  (Version: SFZ v2)
* **lfoN_pitch**:  (Version: SFZ v2)
* **lfoN_cutoff**:  (Version: SFZ v2)  
  *Aliases: `lfoN_cutoff2`*
* **lfoN_resonance**:  (Version: SFZ v2)  
  *Aliases: `lfoN_resonance2`*
* **lfoN_eqXfreq**:  (Version: SFZ v2)
* **lfoN_eqXbw**:  (Version: SFZ v2)
* **lfoN_eqXgain**:  (Version: SFZ v2)
* **lfoN_decim**:  (Version: SFZ v2)
* **lfoN_bitred**:  (Version: SFZ v2)
* **lfoN_noiselevel**:  (Version: SFZ v2)
* **lfoN_noisestep**:  (Version: SFZ v2)
* **lfoN_noisetone**:  (Version: SFZ v2)
* **lfoN_drive**:  (Version: SFZ v2)
* **lfoN_offset**: DC offset - Add to LFO output; not affected by scale. (Version: ARIA; Type: float)  
  *Aliases: `lfoN_offsetX`*
* **lfoN_ratio**: Sets the ratio between the specified sub waveform and the main waveform. (Version: ARIA; Type: float)  
  *Aliases: `lfoN_ratioX`*
* **lfoN_scale**: Sets the scaling between the specified sub waveform and the main waveform. (Version: ARIA; Type: float)  
  *Aliases: `lfoN_scaleX`*
* **lfoN_sample_dyn_paramX**: ARIA-specific nameless destination for plugin LFO modulations. (Version: ARIA)

### Curves
* **ID:** `crv`
* **URL:** /headers/curve
* **curve_index**: Curve definition ID. (Version: ARIA; Type: integer, Range: 0 to 255)
* **vNNN**: Defines a point in a custom curve definition. (Version: SFZ v2; Type: float, Range: -1 to 1)

### Effects
* **ID:** `efx`
* **URL:** /headers/effect
* **apan_depth**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **apan_dry**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **apan_freq**:  (Version: SFZ v2; Type: float)
* **apan_phase**:  (Version: SFZ v2; Type: float, Range: 0 to 180)
* **apan_waveform**: LFO wave number. (Version: SFZ v2)
* **apan_wet**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **bitred**: Bit reduction. (Version: SFZ v2; Type: , Range: 0 to 100)
* **bus**: The target bus for the effect. (Version: SFZ v2; Type: string, Default: main)
* **bypass_onccN**: Sets up a bypass controller for the effect. (Version: SFZ v2; Type: float)
* **comp_attack**:  (Version: SFZ v2; Type: float)
* **comp_gain**:  (Version: SFZ v2)
* **comp_ratio**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **comp_release**:  (Version: SFZ v2; Type: float)
* **comp_stlink**:  (Version: SFZ v2; Type: string)
* **comp_threshold**:  (Version: SFZ v2; Type: float)
* **decim**: Decimator. (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_cutoff**:  (Version: SFZ v2; Type: float)
* **delay_damphi**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_damplo**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_dry**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_feedback**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_filter**: Name of filter type. (Version: SFZ v2; Type: string)
* **delay_input**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_levelc**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_levell**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_levelr**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_lfofreq**:  (Version: SFZ v2; Type: float)
* **delay_moddepth**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_mode**:  (Version: SFZ v2; Type: string)
* **delay_panc**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_panl**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_panr**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_resonance**:  (Version: SFZ v2)
* **delay_spread**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **delay_syncc_onccN**:  (Version: SFZ v2)
* **delay_syncl_onccN**:  (Version: SFZ v2)
* **delay_syncr_onccN**:  (Version: SFZ v2)
* **delay_time_tap**:  (Version: SFZ v2)
* **delay_timec**:  (Version: SFZ v2)
* **delay_timel**:  (Version: SFZ v2)
* **delay_timer**:  (Version: SFZ v2)
* **delay_wet**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **directtomain**: Gain of the main bus into the output. (Version: SFZ v2; Type: float, Range: 0 to 100, Default: 100)
* **disto_depth**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **disto_dry**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **disto_stages**:  (Version: SFZ v2)
* **disto_tone**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **disto_wet**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **dsp_order**: Signal flow type in Rapture's DSP block. (Version: SFZ v2; Type: integer, Range: 0 to 14)
* **effect1**: Level of effect1 send, in percentage (reverb in Cakewalk sfz). (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **effect2**: Level of effect2 send, in percentage (chorus in Cakewalk sfz). (Version: SFZ v1; Type: float, Range: 0 to 100, Default: 0)
* **effect3**: Gain of the region's send into the 3rd effect bus. (Version: SFZ v2; Type: float, Range: 0 to 100, Default: 0)
* **effect4**: Gain of the region's send into the 4th effect bus. (Version: SFZ v2; Type: float, Range: 0 to 100, Default: 0)
* **eq_bw**:  (Version: SFZ v2)
* **eq_freq**:  (Version: SFZ v2)
* **eq_gain**:  (Version: SFZ v2)
* **eq_type**:  (Version: SFZ v2)
* **filter_cutoff**:  (Version: SFZ v2)
* **filter_resonance**:  (Version: SFZ v2)
* **filter_type**: Name of filter type. (Version: SFZ v2; Type: string)
* **fxNtomain**: Gain of the Nth effect bus into the output. (Version: SFZ v2; Type: float, Range: 0 to 100, Default: 0)
* **fxNtomix**: Gain of the Nth effect bus into the Mix node. (Version: SFZ v2; Type: float, Range: 0 to 100, Default: 0)
* **gate_onccN**: Gate manual control. (Version: SFZ v2)
* **gate_attack**:  (Version: SFZ v2)
* **gate_release**:  (Version: SFZ v2)
* **gate_stlink**:  (Version: SFZ v2; Type: string)
* **gate_threshold**:  (Version: SFZ v2)
* **internal**: Cakewalk internal features switch. (Version: SFZ v2; Type: string, Default: off)
* **param_offset**: Adds a number to the parameter numbers of built-in or vendor-specific effects. (Version: ARIA; Type: integer)
* **phaser_depth**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **phaser_feedback**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **phaser_freq**:  (Version: SFZ v2; Type: float)
* **phaser_phase_onccN**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **phaser_stages**:  (Version: SFZ v2)
* **phaser_waveform**: LFO wave number. (Version: SFZ v2)
* **phaser_wet**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **reverb_damp**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **reverb_dry**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **reverb_input**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **reverb_predelay**:  (Version: SFZ v2; Type: float)
* **reverb_size**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **reverb_tone**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **reverb_type**:  (Version: SFZ v2; Type: string)
* **reverb_wet**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **static_cyclic_level**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **static_cyclic_time**:  (Version: SFZ v2; Type: float)
* **static_filter**: Name of filter type. (Version: SFZ v2; Type: string)
* **static_level**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **static_random_level**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **static_random_maxtime**:  (Version: SFZ v2; Type: float)
* **static_random_mintime**:  (Version: SFZ v2; Type: float)
* **static_stereo**:  (Version: SFZ v2)
* **static_tone**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **strings_number**: Number of synthesized resonant strings. (Version: SFZ v2)
* **strings_wet_onccN**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **tdfir_dry**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **tdfir_gain**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **tdfir_impulse**:  (Version: SFZ v2)
* **tdfir_wet**:  (Version: SFZ v2; Type: , Range: 0 to 100)
* **type**: Effect type or vendor-specific effect name. Varies across SFZ players. (Version: SFZ v2; Type: string)
* **vendor_specific**: Defines vendor-specific effects, for example Garritan-specific stage depth effect in ARIA. (Version: ARIA; Type: string)

### Loading
* **ID:** `ldg`
* **URL:** /opcodes/?c=ldg
* **load_mode**:  (Version: SFZ v2; Type: integer, Range: 0 to 1)
* **load_start**:  (Version: SFZ v2; Type: integer)
* **load_end**:  (Version: SFZ v2; Type: integer)
* **sample_quality**: Sample playback quality settings. (Version: SFZ v2; Type: integer, Range: 1 to 10)
* **image**: Sets the background image of the instrument. (Version: SFZ v2; Type: string)

### Wavetable Oscillator
* **ID:** `wos`
* **URL:** opcodes/?c=wos
* **oscillator**:  (Version: SFZ v2; Type: string)
* **oscillator_detune**:  (Version: SFZ v2)
* **oscillator_mode**: The modulation type. (Version: SFZ v2; Type: integer, Range: 0 to 2, Default: 0)
* **oscillator_mod_depth**:  (Version: SFZ v2)
* **oscillator_multi**: Configure a region to use more than one oscillator. (Version: SFZ v2; Type: integer, Range: 1 to 9, Default: 1)
* **oscillator_phase**: Oscillator phase. Negative values for random phase. (Version: SFZ v2; Type: float, Range: -1 to 360)
* **oscillator_quality**:  (Version: SFZ v2; Type: integer, Range: 0 to 3)
* **oscillator_table_size**:  (Version: SFZ v2)

