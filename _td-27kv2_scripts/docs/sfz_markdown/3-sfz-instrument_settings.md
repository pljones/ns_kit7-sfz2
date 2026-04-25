# Instrument Settings

Opcodes used under the <control> header.

## Voice Lifecycle
### group

Exclusive group number for this region.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `-2147483648` to `2147483647`

### off_by

Region off group.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `-2147483648` to `2147483647`

### off_mode

Region off mode.

**Version:** SFZ v1

**Type:** `string`
**Default:** `fast`

### output

The stereo output number for this region.

**Version:** SFZ v1

**Type:** `integer`
**Default:** `0`
**Range:** `0` to `1024`

### polyphony

Polyphony voice limit.

**Version:** SFZ v2

**Type:** `integer`

### note_polyphony

Polyphony limit for playing the same note repeatedly.

**Version:** SFZ v2

**Type:** `integer`

### polyphony_stealing

**Version:** ARIA

**Type:** `integer`

#### See Also
- `SFZ test`

### note_selfmask

Controls note-stealing behavior for a single pitch, when using <a href='3-sfz-instrument_settings.md#note_polyphony'>note_polyphony</a>.

**Version:** SFZ v2

**Type:** `string`
**Default:** `on`

### rt_dead

Controls whether a release sample should play if its sustain sample has ended, or not.

**Version:** SFZ v2

**Type:** `string`
**Default:** `off`

### off_curve

When <a href='3-sfz-instrument_settings.md#off_mode'>off_mode</a> is set to time, this specifies the math to be used to fade out the regions being muted by voice-stealing.

**Version:** ARIA

**Type:** `integer`
**Default:** `10`
**Range:** `-2` to `10`

#### See Also
- [off_shape](3-sfz-instrument_settings.md#off_shape)
- [off_time](3-sfz-instrument_settings.md#off_time)

### off_shape

The coefficient used by <a href='3-sfz-instrument_settings.md#off_curve'>off_curve</a>.

**Version:** ARIA

**Type:** `float`
**Default:** `-10.3616`

#### See Also
- [off_curve](3-sfz-instrument_settings.md#off_curve)
- [off_time](3-sfz-instrument_settings.md#off_time)

### off_time

When <a href='3-sfz-instrument_settings.md#off_mode'>off_mode</a> is set to time, this specifies the fadeout time for regions being muted by voice-stealing.

**Version:** ARIA

**Type:** `float`
**Default:** `0.006`

#### See Also
- [off_curve](3-sfz-instrument_settings.md#off_curve)
- [off_shape](3-sfz-instrument_settings.md#off_shape)
