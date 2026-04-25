# SFZ Markdown Documentation Index

Generated index for SFZ docs, source relationships, and consistency checks.

## Source Files

- `syntax.yml` - Core SFZ headers/opcodes and version tags
- `see_also.yml` - Cross-reference mapping
- `engines.yml` - Engine to format support mapping
- `formats.yml` - Canonical audio format list
- `software.yml` - Software catalog
- `engines/aria.yml` - ARIA overlay
- `engines/linuxsampler.yml` - LinuxSampler overlay

## Generated File Inventory

- `0-sfz-headers.md`
- `1-sfz-real_time_instrument_script.md`
- `10-sfz-wavetable_oscillator.md`
- `12-engine-compatibility.md`
- `14-software-catalog.md`
- `15-aria-extensions.md`
- `16-linuxsampler-guide.md`
- `2-sfz-sound_source.md`
- `3-sfz-instrument_settings.md`
- `4-sfz-region_logic.md`
- `5-sfz-performance_parameters.md`
- `6-sfz-modulation.md`
- `7-sfz-curves.md`
- `8-sfz-effects.md`
- `9-sfz-loading.md`
- `sfz-index.md`

## Engine/Format Relationship

- Formats in `formats.yml`: AIFF, FLAC, MP3, Ogg, WAV, WavPack
- Engines in `engines.yml`: ARIA, Calfbox, sfizz
- Software entries in `software.yml`: 60

## Consistency Checks

- Syntax versions: ARIA, Calfbox, LinuxSampler, SFZ v1, SFZ v2, sfizz
- Overlap with known engines: ARIA, Calfbox, LinuxSampler, sfizz
- Syntax versions without direct engine match: SFZ v1, SFZ v2
- Engines without per-engine overlay file: Calfbox, sfizz
