# SFZ Headers

SFZ headers define structural sections within SFZ files. Each header contains related opcodes and parameters.

## region

The basic component of an instrument. An instrument is defined by one or more regions.

**Version:** SFZ v1

## group

Multiple regions can be arranged in a group. Groups allow entering common parameters for multiple regions.

**Version:** SFZ v1

## control

**Version:** SFZ v2

## global

Allows entering parameters which are common for all regions.

**Version:** SFZ v2

## curve

A header for defining curves for MIDI CC controls.

**Version:** SFZ v2

## effect

SFZ v2 header for effects controls.

**Version:** SFZ v2

## master

An intermediate level in the header hierarchy, between global and group.

**Version:** ARIA

## midi

ARIA extension, was added for MIDI pre-processor effects. From ARIA v1.0.8.0+ an &lt;<a href='8-sfz-effects.md'>effect<a>&gt; section with a <a href='8-sfz-effects.md#bus'>bus</a>=midi can be used instead.

**Version:** ARIA

⚠️ **Deprecated**

## sample

Allows to embed sample data directly in SFZ files (Rapture).

**Version:** SFZ v2
