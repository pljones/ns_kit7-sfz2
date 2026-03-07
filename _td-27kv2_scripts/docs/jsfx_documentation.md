## REAPER | JSFX Programming

## JSFX Programming
* Introduction
* JSFX file structure
* Basic code reference
* Operator reference
* Simple math functions
* Loops
* Time functions
* Special Variables
* MIDI Functions
* MIDI Bus Support
* File I/O and Serialization
* Memory/FFT/MDCT Functions
* Host Interaction Functions
* Strings
* String functions
* Graphics
* User defined functions and namespace pseudo-objects
* EEL2 Preprocessor
* Compile-time user-configurable JSFX settings

---

top
 **Introduction***

This is a reference guide to programming JSFX audio-oriented effects
for REAPER. JSFX are written in EEL2, a scripting language that is compiled
on the fly and allows you to modify and/or generate audio and MIDI,
as well as draw custom vector based UI and analysis displays.

JSFX are simple text files, which become
full featured plug-ins when loaded into REAPER.
Because they are distributed in source form, you can edit existing
JSFX to suit your needs, or you can write new JSFX from scratch.
(If editing an existing JSFX, we recommend that
you save it as something with a new name, so that you
do not lose your changes when upgrading REAPER).

This guide will offer an outline of the structure of the JSFX text file,
the syntax for writing code, and a list of all
functions and special variables available for use.

---

top
 **JSFX file structure***

JSFX are text files that are composed of some description lines followed by one or more code sections.

The description lines that can be specified are:
* desc: **Effect Description**

This line should be specified once and only once, and defines the name of the effect which will be displayed to the user.
Ideally this line should be the first line of the file, so that it can be quickly identified as a JSFX file.

* tags: **space delimited list of tags**

You can specify a list of tags that this plug-in should be (eventually) categorized with. In REAPER v6.74+, including "instrument" will cause it to appear in the "Instruments" list.

* slider **1: **5< **0, **10, **1> **slider description*

You can specify up to 256 of these lines to specify parameters that the user can control using standard
UI controls (typically a fader and text input, but this can vary, see below). These parameters are also automatable from REAPER.

In the above example, the first **1 specifies the first parameter, **5 is the default value of the parameter, **0 is***
the minimum value, **10 is the maximum value, and **1 is the change increment. **slider description***
is what is displayed to the user.

 **Extended slider options:***
* slider **1:variable_name= **5< **0, **10, **1> **slider description * -- REAPER 5.0+*

A variable_name= prefix may be specified for the default value, in which case the slider should be accessed via the variable_name variable, rather than sliderX. This can be combined with any of the other syntaxes below.

* slider1:0< **0,5, **1{ **zerolabel,onelabel,twolabel,threelabel,fourlabel,fivelabel}>some setting***

This will show this parameter with a list of options from "zerolabel" to "fivelabel". Note that these parameters should be set to
start at 0 and have a change increment of 1, as shown above.

* slider1: **/some_path: **default_value:slider description*

In the above example, the **/some_path specifies a subdirectory of the REAPER\Data path, which will be scanned for .wav, .txt, .ogg, or .raw files. **default_value defines a default filename. If this is used, the script will generally use file_open(slider1) in the @serialize code section to read the contents of the selected file.*

* slider1:0<0,127,1> **-Hidden parameter**

You can also hide sliders by prefixing their names with "-". Such parameters will not be visible in the plug-in UI but still be active, automatable, etc.

* 
slider **1: **5< **0, **10, **0.1:log> **slider description * -- REAPER 6.74+*

slider **1: **5< **0, **10, **0.1:log=2> **slider description*

slider **1: **5< **0, **10, **0.1:sqr> **slider description*

slider **1: **5< **0, **10, **0.1:sqr=3> **slider description*

slider **1: **5< **0, **10, **0.1:log!> **slider description*

Appending :log or :sqr to the change increment causes the slider to use log/exponential shaping or polynomial shaping. 

If you use :log=X, X will be the midpoint of the slider scale. If you use :sqr=X, X will be the exponent of the polynomial (2 is the default).

Note that changing the type of shaping (or the X of :log=X mode) of the slider may affect existing projects that automate the parameter. If you use :log! or :sqr! or :log!=X or :sqr!=X, then the parameter shaping will not affect automation (and compatibility will be preserved).

* in_pin: **name_1**
in_pin: **name_2***
out_pin: **none***

These optional lines export names for each of the JSFX pins (effect channels), for display in REAPER's plug-in pin connector dialog.

If the only named in_pin or out_pin is labeled "none", REAPER will know that the effect has no audio inputs and/or outputs, which enables some processing optimizations. MIDI-only FX should specify in_pin:none and out_pin:none.

* filename: **0, **filename.wav*

These lines can be used to specify filenames which can be used by code later.
These definitions include **0 (the index) and a filename. The indices must be listed in order without gaps -- i.e. the first should always be 0, the second (if any) always should be 1, and so on.***

To use for generic data files, the files should be located in the REAPER\Data directory, and these can be opened with file_open(), passing the filename index.

You may also specify a PNG file. If you specify a file ending in .png, it will be opened from the same directory as the effect, and you can use the filename index as a parameter to gfx_blit(). * -- REAPER 2.018+

* options: **option_dependent_syntax**

This line can be used to specify JSFX options (use spaces to separate multiple options):

* options:gmem=someUniquelyNamedSpace

This option allows plugins to allocate their own global shared buffer, see gmem[].

* options:want_all_kb

Enables the "Send all keyboard input to plug-in" option for new instances of the plug-in, see gfx_getchar().

* options:maxmem=XYZ

Requests that the maximum memory available to the plug-in be limited to the slots specified. By default this is about 8 million slots, and the maximum amount is currently 32 million. The script can check the memory availble using __memtop().

* options:no_meter

Requests that the plug-in has no meters.

* options:gfx_idle *-- REAPER 6.44+

If specified, @gfx will be called periodically (though possibly at a reduced rate) even when the UI is closed. In this case gfx_ext_flags will have 2 set.

* options:gfx_idle_only *-- REAPER 6.44+

If specified, @gfx will ONLY be called periodically and a UI will not be displayed. Useful for plug-ins that do not have a custom UI but want to do some idle processing from the UI thread.

* options:gfx_hz=60 *-- REAPER 6.44+

If specified, the @gfx section may be run at a rate closer to the frequency specified (note that the update frequencies should not be relied on, code should use audio sample accounting or time_precise() to draw framerate independently.

* import **filename * -- REAPER v4.25+**

You can specify a filename to import (this filename will be searched within the JS effect directory). Importing files via this directive will have any functions defined in their @init sections available to the local effect. Additionally, if the imported file implements other sections (such as @sample, etc), and the importing file does not implement those sections, the imported version of those sections will be used.

Note that files that are designed for import only (such as function libraries) should ideally be named xyz.jsfx-inc, as these will be ignored in the user FX list in REAPER.

Following the description lines, there should be code sections. All of the code sections are optional (though an effect without any would likely have limited use). Code sections are declared by a single line, then followed by as much code as needed until the end of the file, or until the next code section. Each code section can only be defined once. The following code sections are currently used:
* **@init**

The code in the @init section gets executed on effect load, on samplerate changes, and on start of playback. If you wish this code to not execute on start of playback or samplerate changes, you can set ext_noinit to 1.0. 

All memory and variables are zero on load, and are re-zeroed before calling @init. To avoid this behavior, a script can define a non-empty (it can be trivial code that has no side effect) @serialize code section, which will prevent memory/variables from being cleared on @init.

* **@slider**

The code in the @slider section gets executed following an @init, or when a parameter (slider) changes. Ideally code in here should detect when a slider has changed, and adapt to the new parameters (ideally avoiding clicks or glitches). The parameters defined with sliderX: can be read using the variables sliderX.

* **@block**

The code in the @block section is executed before processing each sample block. Typically a block is whatever length as defined by the audio hardware, or anywhere from 128-2048 samples. In this code section the samplesblock variable will be valid (and set to the size of the upcoming block).

* **@sample**

The code in the @sample section is executed for every PCM audio sample. This code can analyze, process, or synthesize, by reading, modifying, or writing to the variables spl0, spl1, ... spl63.

* **@serialize**

The code in the @serialize section is executed when the plug-in needs to load or save some extended state. The sliderX parameters are saved automatically, but if there are internal state variables or memory that should be saved, they should be
saved/restored here using file_var() or file_mem() (passing an argument of 0 for the file handle). (If the code needs to detect whether it is saving or loading, it can do so with file_avail() (file_avail(0) will return <0 if it is writing).

Note when saving the state of variables or memory, they are stored in a more compact 32 bit representation, so a slight precision loss is possible. Note also that you should not clear any variables saved/loaded by @serialize in @init, as sometimes @init will be called following @serialize.

* **@gfx [width] [height]**

The @gfx section gets executed around 30 times a second when the plug-ins GUI is open. You can do whatever processing you like in this (Typically using gfx_*()). Note that this code runs in a separate thread from the audio processing, so you may have both running simultaneously which could leave certain variables/RAM in an unpredictable state.

The @gfx section has two optional parameters, which can specify the desired width/height of the graphics area. Set either of these to 0 (or omit them) to specify that the code doesn't care what size it gets. Note that these are simply
hints to request this size -- you may not always get the specified size. Your code in this section should use the gfx_w, gfx_h variables to actually determine drawing dimensions.

Note also that if no drawing occurs in @gfx, then no update will occur (plug-ins should ideally detect when no update is necessary and do nothing in @gfx if an update would be superfluous).

## REAPER | JSFX Programming Reference - Language Essentialsback to main JSFX reference page

## JSFX Programming Reference - Language Essentials
* Basic code reference
* Operator reference
* Simple math functions
* Loops
* Time functions

---

top
 **Basic code reference***

The core of JSFX is custom code written in a simple language (called EEL2), which has many similarities to C. Code is written in one or more of the numerous code sections. Some basic features of this language are:
* Variables do not need to be declared, are by default global to the effect, and are all double-precision floating point.

* Variable names are NOT case sensitive, so a and A refer to the same variable.

* Variable names may begin with a _, a-z, or A-Z, and can contain numbers after one of those characters.

* The maximum variable name length is 127 characters.

* Variable names can also contain . characters, though this is used for namespaced pseudo-objects.

* There are a few predefined constant variables: $pi, $phi, and $e.

* Basic operations including addition (+), subtraction (-), multiplication (*), division (/), and exponential (^)

* Bitwise operations including OR (|), AND (&), XOR (~), shift-left (<<), and shift-right-sign-extend (>>). These all convert to integer for calculation.

* Parentheses "(" and ")" can be used to clarify precedence, contain parameters for functions, and collect multiple statements into a single statement.

* A semicolon ";" is used to separate statements from eachother (including within parentheses).

* A virtual local address space of about 8 million words, which can be accessed via brackets "[" and "]".

* A shared global address space of about 1 million words, accessed via gmem[]. These words are shared between all JSFX plug-in instances.

* Shared global named variables, accessible via the "_global." prefix. These variables are shared between all JSFX plug-in instances.

* User definable functions, which can define private variables, parameters, and also can optionally access namespaced instance variables.

* Numbers are in normal decimal, however if you prefix an '$x' to them, they will be hexadecimal (i.e. $x90, $xDEADBEEF, etc). * -- (REAPER v4.25+ can also take traditional C syntax, i.e. 0x90)
* You may specify the ASCII value of a character using $'c' (where c is the character).

* If you wish to generate a mask of 1 bits in integer, you can use $~X, for example $~7 is 127, $~8 is 255, $~16 is 65535, etc. * -- REAPER 4.25+.
* Comments can be specified using:
* // comments to end of line

* /* comments block of code that span lines or be part of a line */

---

top
 **Operator reference***

Listed from highest precedence to lowest (but one should use parentheses whenever there is doubt!):
* **[ ]**

```eel2
z=x[y];
 x[y]=z;
```

 You may use brackets to index into memory that is local to your effect. Your effect has approximately 8 million (8,388,608) slots of memory
 and you may access them either with fixed offsets (i.e. 16811[0]) or with variables (myBuffer[5]). The sum of the value to the left of the brackets and the value within the brackets is used to index memory. If a value in the brackets is omitted then only the value to the left of the brackets is used.

 *Note: due to legacy reasons, the summed address is rounded unconventionally (value + 0.00001, truncated to integer). If using fractional values to index a array, you may wish to manually truncate them to integer, e.g.:*

```eel2
x[y|0] = z
```

... *if y is not an integer.*

If 'gmem' is specified as the left parameter to the brackets, then the global shared buffer is used, which by default is approximately 1 million (1,048,576) slots that are shared across all instances of all JSFX effects:

```eel2
z=gmem[y];
 gmem[y]=z;
```

The plug-in can also specify a line (before code sections):

```eel2
options:gmem=someUniquelyNamedSpace
```

which will make gmem[] refer to a larger shared buffer, accessible by any plugin that uses options:gmem=<the same name>. So, if you have a single plug-in, or a few plug-ins that access the shared namespace, they can communicate without having to worry about other plug-ins. This option also increases the size of gmem[] to be 8 million entries (from the default 1 million). * -- REAPER 4.6+

* **!value -- returns the logical NOT of the parameter (if the parameter is 0.0, returns 1.0, otherwise returns 0.0).**

* **-value -- returns value with a reversed sign (-1 * value).**

* **+value -- returns value unmodified.**

* **base ^ exponent -- returns the first parameter raised to the power of the second parameter. This is also available the function pow(x,y) ***

* **numerator % denominator -- converts the absolute values of numerator and denominator to integers (may be 32-bit or 64-bit integers depending on platform/OS/etc), returns the remainder of numerator divided by denominator.**

* **value << shift_amt -- converts both values to 32 bit integers, bitwise left shifts the first value by the second. Note that shifts by more than 32 or less than 0 produce undefined results. * -- REAPER 4.111+**

* **value >> shift_amt -- converts both values to 32 bit integers, bitwise right shifts the first value by the second, with sign-extension (negative values of y produce non-positive results). Note that shifts by more than 32 or less than 0 produce undefined results. * -- REAPER 4.111+**

* **value / divisor -- divides two values and returns the quotient.**

* **value * another_value -- multiplies two values and returns the product.**

* **value - another_value -- subtracts two values and returns the difference.**

* **value + another_value -- adds two values and returns the sum.**

* *Note: the relative precedence of |, &, and ~ are equal, meaning a mix of these operators is evaluated left-to-right (which is different from other languages and may not be as expected). Use parentheses when mixing these operators.
* **a | b -- converts both values to integers (may be 32-bit or 64-bit integers depending on platform/OS/etc), and returns bitwise OR of values.**

* **a & b -- converts both values to integers (may be 32-bit or 64-bit integers depending on platform/OS/etc), and returns bitwise AND of values.**

* **a ~ b -- converts both values to integers (may be 32-bit or 64-bit integers depending on platform/OS/etc), bitwise XOR the values. * -- REAPER 4.25+**

* **value1 == value2 -- compares two values, returns 1 if difference is less than 0.00001, 0 if not.**

* **value1 === value2 -- compares two values, returns 1 if exactly equal, 0 if not. * -- REAPER 4.53+**
* **value1 != value2 -- compares two values, returns 0 if difference is less than 0.00001, 1 if not.**

* **value1 !== value2 -- compares two values, returns 0 if exactly equal, 1 if not. * -- REAPER 4.53+**
* **value1 < value2 -- compares two values, returns 1 if first parameter is less than second.**

* **value1 > value2 -- compares two values, returns 1 if first parameter is greater than second.**

* **value1 <= value2 -- compares two values, returns 1 if first is less than or equal to second.**

* **value1 >= value2 -- compares two values, returns 1 if first is greater than or equal to second.**

* *Note: the relative precedence of || and && are equal, meaning a mix of these operators is evaluated left-to-right (which is different from other languages and may not be as expected). Use parentheses when mixing these operators.
* **y || z -- returns logical OR of values. If 'y' is nonzero, 'z' is not evaluated.**

* **y && z -- returns logical AND of values. If 'y' is zero, 'z' is not evaluated.**

* **y ? z * -- how conditional branching is done -- similar to C's if/else**
 **y ? z : x***

 If y is non-zero, executes and returns z, otherwise executes and returns x (or 0.0 if *': x' is not specified).*
 

 Note that the expressions used can contain multiple statements within parentheses, such as:

```eel2
x % 5 ? (
 f += 1;
 x *= 1.5;*
 ) : (
 f=max(3,f);
 x=0;
 );
```

* **y = z -- assigns the value of 'z' to 'y'. 'z' can be a variable or an expression.**

* **y *= z -- multiplies two values and stores the product back into 'y'.***

* **y /= divisor -- divides two values and stores the quotient back into 'y'.**

* **y %= divisor -- converts the absolute values of y and divisor to integers (may be 32-bit or 64-bit integers depending on platform/OS/etc), returns and sets y to the remainder of y divided by divisor.**

* **base ^= exponent -- raises first parameter to the second parameter-th power, saves back to 'base'**

* **y += z -- adds two values and stores the sum back into 'y'.**

* **y -= z -- subtracts 'z' from 'y' and stores the difference into 'y'.**

* **y |= z -- converts both values to integer, and stores the bitwise OR into 'y'**

* **y &= z -- converts both values to integer, and stores the bitwise AND into 'y'**

* **y ~= z -- converts both values to integer, and stores the bitwise XOR into 'y' * -- REAPER 4.25+**

Some key notes about the above, especially for C programmers:
* ( and ) (vs { } ) -- enclose multiple statements, and the value of that expression is the last statement within the block:
 

```eel2
z = (
 a = 5;
 b = 3;
 a+b;
 ); // z will be set to 8, for example
```

* Conditional branching is done using the ? or ? : operator, rather than if()/else.

```eel2
a < 5 ? b = 6; // if a is less than 5, set b to 6
 a < 5 ? b = 6 : c = 7; // if a is less than 5, set b to 6, otherwise set c to 7
 a < 5 ? ( // if a is less than 5, set b to 6 and c to 7
 b = 6;
 c = 7;
 );
```

* The ? and ?: operators can also be used as the lvalue of expressions:

```eel2
(a < 5 ? b : c) = 8; // if a is less than 5, set b to 8, otherwise set c to 8
```

---

top
 **Simple math functions***

* **sin(angle) -- returns the Sine of the angle specified (specified in radians -- to convert from degrees to radians, multiply by $pi/180, or 0.017453)**

* **cos(angle) -- returns the Cosine of the angle specified (specified in radians).**

* **tan(angle) -- returns the Tangent of the angle specified (specified in radians).**

* **asin(x) -- returns the Arc Sine of the value specified (return value is in radians).**

* **acos(x) -- returns the Arc Cosine of the value specified (return value is in radians).**

* **atan(x) -- returns the Arc Tangent of the value specified (return value is in radians).**

* **atan2(x,y) -- returns the Arc Tangent of x divided by y (return value is in radians).**

* **sqr(x) -- returns the square of the parameter (similar to x*x, though only evaluating x once).**

* **sqrt(x) -- returns the square root of the parameter.**

* **pow(x,y) -- returns the first parameter raised to the second parameter-th power. Identical in behavior and performance to the ^ operator.**

* **exp(x) -- returns the number e (approx 2.718) raised to the parameter-th power. This function is significantly faster than pow() or the ^ operator**
* **log(x) -- returns the natural logarithm (base e) of the parameter.**

* **log10(x) -- returns the logarithm (base 10) of the parameter.**

* **abs(x) -- returns the absolute value of the parameter.**

* **min(x,y) -- returns the minimum value of the two parameters.**

* **max(x,y) -- returns the maximum value of the two parameters.**

* **sign(x) -- returns the sign of the parameter (-1, 0, or 1).**

* **rand(x) -- returns a psuedorandom number between 0 and the parameter.**

* **floor(x) -- rounds the value to the lowest integer possible (floor(3.9)==3, floor(-3.1)==-4).**

* **ceil(x) -- rounds the value to the highest integer possible (ceil(3.1)==4, ceil(-3.9)==-3).**

* **invsqrt(x) -- returns a fast inverse square root (1/sqrt(x)) approximation of the parameter.**

---

top
 **Loops***

Looping is supported in JSFX via the following functions:
* **loop(count,code)**

```eel2
loop(32,
 r += b;
 b = var * 1.5;
 );
```

 Evaluates the first parameter once in order to determine a loop count. If the loop count is less than 1, the second parameter is not evaluated.
 

 Be careful with specifying large values for the first parameter -- it is possible to hang your effect for long periods of time. In the interest of avoiding common runtime hangs, the loop count will be limited to approximately 1,000,000: if you need a loop with more iterations, you may wish to reconsider your design (or as a last resort, nest loops).
 

 The first parameter is only evaluated once (so modifying it within the code will have no effect on the number of loops). For a loop of indeterminate length, see while() below.
 

* **while(code)**

```eel2
while(
 a += b;
 b *= 1.5;*
 a < 1000; // as long as a is below 1000, we go again.
 );
```

 Evaluates the first parameter until the last statement in the code block evaluates to zero. 

 In the interest of avoiding common runtime hangs, the loop count will be limited to approximately 1,000,000: if you need a loop with more iterations, you may wish to reconsider your design (or as a last resort, nest loops).

* **while(condition) ( code ) * -- REAPER 4.59+**

```eel2
while ( a < 1000 ) (
 a += b;
 b *= 1.5;*
 );
```

 Evaluates the parameter, and if nonzero, evaluates the following code block, and repeats. This is similar to a C style while() construct. 

 In the interest of avoiding common runtime hangs, the repeat count will be limited to approximately 1,000,000: if you need a loop with more iterations, you may wish to reconsider your design (or as a last resort, nest loops).

---

top
 **Time functions***

* **time([v]) * -- REAPER 4.60+**

Returns the current time as seconds since January 1, 1970. 1 second granularity. If a parameter is specified, it will be set to the timestamp.

* **time_precise([v]) * -- REAPER 4.60+**

Returns a system-specific timestamp in seconds. Granularity is system-defined, but generally much less than 1 millisecond. Useful for benchmarking. If a parameter is specified, it will be set to the timestamp.

## REAPER | JSFX Programming Reference - Special Variablesback to main JSFX reference page

## JSFX Programming Reference - Special Variables
* Special Variables

---

top
 **Special Variables***

 **Basic Functionality:***
* **spl0, spl1 ... spl63**

 Context: @sample only

 Usage: read/write

 The variables spl0 and spl1 represent the current left and right samples in @sample code.
 

 The normal +0dB range is -1.0 .. 1.0, but overs are allowed (and will eventually be clipped if not reduced by a later effect).
 

 On a very basic level, these values represent the speaker position at the point in time, but if you need more information you should do more research on PCM audio.
 

 If the effect is operating on a track that has more than 2 channels, then spl2..splN will be set with those channels values as well. If you do not modify a splX variable, it will be passed through unmodified.
 

 See also spl(x) below, though splX is generally slightly faster than spl(X)

* **spl(channelindex) * -- REAPER 2.018+**

 Context: @sample only

If you wish to programmatically choose which sample to access, use this function (rather than splX). This is slightly slower than splX, however has the advantage that you can do spl(variable) (enabling easily configurable channel mappings). Valid syntaxes include:

```eel2
spl(channelindex)=somevalue;
 spl(5)+=spl(3);
```

* **slider1, slider2, ... sliderX**

 Context: available everywhere

 Usage: read/write

 The variables slider1, slider2, ... allow interaction between the
 user and the effect, allowing the effects parameters to be adjusted by the
 user and likewise allow the effect to modify the parameters shown to the
 user (if you modify sliderX in a context other than @slider then you should call sliderchange(sliderX) to notify JS to refresh the control).
 

 The values of these sliders are purely effect-defined, and will be shown to the user, as well as tweaked by the user.

* **slider(sliderindex) * -- REAPER 3.11+**

 Context: available everywhere

If you wish to programmatically choose which slider to access, use this function (rather than sliderX). Valid syntaxes include:

```eel2
val = slider(sliderindex);
 slider(i) = 1;
```

* **slider_next_chg(sliderindex,nextval) * -- REAPER 5.0+**

 Context: @block, @sample

 Used for sample-accurate automation. Each call will return a sample offset, and set nextval to the value at that sample offset. Returns a non-positive value if no changes (or no more changes) are available. Notes:
* If the value of the parameter is constant for the audio block, then the all calls to slider_next_chg() will return -1.
 
* If the audio block is entirely a linear (or bezier) transition, slider_next_chg() will return samplesblock-1 (and set the value of the second parameter to the value at the END of the audio block).
 
* If the audio block contains an inflection point, e.g. a square point, or a linear point that causes the slope to change, then slider_next_chg() will return the sample-position of the first inflection point. Calling slider_next_chg() again will return the sample-position of the NEXT inflection point, and so on until returning samplesblock-1, followed by -1 (no more inflection points).
 

* **trigger**

 Context: @block, @sample

 Usage: read/write

 The trigger variable provides a facility for triggering effects. 

 If this variable is used in an effect, the UI will show 10 trigger buttons, which when checked will result in the appropriate bit being set in this variable.

 For example, to check for trigger 5 (triggered also by the key '5' on the keyboard):
 

```eel2
isourtrig = trigger & (2^5);
```

 Conversely, to set trigger 5:
 

```eel2
trigger |= 2^5;
```

 Or, to clear trigger 5:
 

```eel2
trigger & (2^5) ? trigger -= 2^5;
```

 It is recommended that you use this variable in @block, but only
 sparingly in @sample.

 **Audio and transport state:***
* **srate**

 Context: available everywhere

 Usage: read-only

 The srate variable is set by the system to whatever the current sampling
 frequency is set to (usually 44100 to 192000). Generally speaking your
 @init code section will be called when
 this changes, though it's probably a good idea not to depend too much on
 that.

* **num_ch**

 Context: most contexts (see comments)

 Usage: read-only

 Specifies the number of channels available (usually 2). Note however splXX are still available even if this count is less, their inputs/outputs are just ignored. You can change the channel count available via in_pin:/out_pin: lines.
 

* **samplesblock**

 Context: most contexts (see comments)

 Usage: read-only

 The samplesblock variable can be used within @block code to see how many samples will come before the next @block call. It may also be valid in other contexts (though your code should handle invalid values in other contexts with grace).

* **tempo**

 Context: @block, @sample

 Usage: read-only

 The current project tempo, in "bpm". An example value would be 120.0.

* **play_state**

 Context: @block, @sample

 Usage: read-only

 The current playback state of REAPER (0=stopped, <0=error, 1=playing,
 2=paused, 5=recording, 6=record paused).

* **play_position**

 Context: @block, @sample

 Usage: read-only

 The current playback position in REAPER (as of last @block), in seconds.

* **beat_position**

 Context: @block, @sample

 Usage: read-only
 The current playback position (as of last @block) in REAPER, in beats (beats = quarternotes in /4 time signatures).

* **ts_num**

 Context: @block, @sample

 Usage: read-only
 The current time signature numerator, i.e. 3.0 if using 3/4 time.

* **ts_denom**

 Context: @block, @sample

 Usage: read-only
 The current time signature denominator, i.e. 4.0 if using 3/4 time.

 **Extended Functionality:***
* **ext_noinit**

 Context: @init only

 Set this variable to 1.0 in your @init section if you do not wish for @init to be called (and variables/RAM to be possibly cleared) on every transport start. Note that in this case, srate may not be correct in @init, and the JSFX code should check for srate changes in @block or @slider.

* **ext_nodenorm**

 Context: @init only

 Set this variable to 1.0 in your @init section if you do not wish to have anti-denormal noise added to input.

* **ext_tail_size * -- REAPER 6.71+**

 Context: @init, @slider

 Set to nonzero if the plug-in produces silence from silence. If positive, specifies length in samples that the plug-in should keep processing after silence (either the output tail length, or the number of samples needed for the plug-in state to settle). If set to -1, REAPER will use automatic output silence detection and let plug-in state settle. If set to -2, then REAPER will assume the plug-in has no tail and no inter-sample state.

* **ext_gr_meter * -- REAPER 7.0+**

 Context: @init, @block

 Used by FX that wish to report gain reduction to the host. Set to 0 in @init, then update with negative values in @block with current gain reduction. set to 10000.0 to disable GR metering.

* **reg00-reg99**

 Context: available everywhere

 Usage: read/write

 The 100 variables reg00, reg01, reg02, .. reg99 are shared across all
 effects and can be used for inter-effect communication. Their use should
 be documented in the effect descriptions to avoid collisions with other
 effects. regXX aliases to _global.regXX.

* **_global.* -- * -- REAPER 4.5+**

 Context: available everywhere

 Usage: read/write

 Like regXX, _global.* are variables shared between all instances of all effects.

 **Delay Compensation (PDC):***
* **pdc_delay**

 Context: @block, @slider

 Usage: read-write

 The current delay added by the plug-in, in samples. Note that you shouldnt
change this too often. This specifies the amount of the delay that should be compensated, however you need to set the pdc_bot_ch and pdc_top_ch below to tell JS which channels should be compensated.

* **pdc_bot_ch, pdc_top_ch**

 Context: @block, @slider

 Usage: read-write

 The channels that are delayed by pdc_delay. For example:

```eel2
pdc_bot_ch=0; pdc_top_ch=2; // delays the first two channels (spl0/spl1).
 pdc_bot_ch=2; pdc_top_ch=5; // delays channels spl2,spl3, and spl4.
```

 (this is provided so that channels you dont delay can be properly
 synchronized by the host).

* **pdc_midi**

 Context: @block, @slider

 Usage: read-write

 If set to 1.0, this will delay compensate MIDI as well as any specified audio channels.
 

 **Graphics and Mouse:***
* gfx_* and mouse_* are also defined for use in @gfx code.

 **MIDI Bus Support:***
* There are also variables defined for accessing MIDI Buses.

## REAPER | JSFX Programming Reference - MIDIback to main JSFX reference page

## JSFX Programming Reference - MIDI
* MIDI Functions
* MIDI Bus Support

---

top
 **MIDI Functions***
It is highly recommended that any MIDI event processing take place in @block, but sending MIDI events can also take place in @sample.

* **midisend(offset,msg1,msg2)**
 **midisend(offset,msg1,msg2 + (msg3 * 256))***
 **midisend(offset,msg1,msg2,msg3) * -- REAPER 4.60+***

```eel2
midisend(0, $x90, 69, 127); // send note 69 to channel 0 at velocity 127 (new syntax)
 midisend(0, $x90, 69+(127*256)); // send note 69 to channel 0 at velocity 127 (old synatx)
 midisend(10,$xD4,50); // set channel pressure on channel 4 to 50, at 10 samples into current block
```

Sends a 2 or 3 byte MIDI message. If only three parameters are specified, the second lowest byte of the third parameter will be used as a third byte in the MIDI message. Returns 0 on failure, otherwise msg1.

* **midisend_buf(offset,buf, len) * -- REAPER 4.60+**

```eel2
buf = 100000;
 buf[0] = $x90;
 buf[1] = 69;
 buf[2] = 127;
 midisend_buf(10,buf,3); // send (at sample offset 10) note-on channel 0, note 69, velocity 127

 buf[0] = $xf0;
 buf[1] = $x01;
 ...
 buf[n] = $xf7;
 midisend_buf(0,buf,n+1); // send sysex f0 01 .. f7
```

Sends a variable length MIDI message. Can be used to send normal MIDI messages, or SysEx messages. When sending SysEx, logic is used to automatically add leading 0xf0 and trailing 0xf7 bytes, if necessary, but if you are sending sysEx and in doubt you should include those bytes (particularly if sending very short SysEx messages). Returns the length sent, or 0 on error.

This function is very similar to midisyx, but preferable in that it can be used to send non-SysEx messages and has no restrcitions relating to the alignment of the buffer being sent.

* **midisend_str(offset,string) * -- REAPER 4.60+**

```eel2
midisend_str(10,"\x90\x11\x7f"); // send at sample offset 10, note-on, note 17, velocity 127
```

Sends a variable length MIDI message from a string. Can be used to send normal MIDI messages, or SysEx messages. When sending SysEx, logic is used to automatically add leading 0xf0 and trailing 0xf7 bytes, if necessary, but if you are sending sysEx and in doubt you should include those bytes (particularly if sending very short SysEx messages). Returns the length sent, or 0 on error.

* **midirecv(offset,msg1,msg23)**
 **midirecv(offset,msg1,msg2,msg3) * -- REAPER 4.60+***

```eel2
@block
 while (midirecv(offset,msg1,msg2,msg3)) ( // REAPER 4.59+ syntax while()
 msg1==$x90 && msg3!=0 ? (
 noteon_cnt+=1; // count note-ons
 ) : (
 midisend(offset,msg1,msg2,msg3); // passthrough other events
 )
 );
```

 The above example will filter all noteons on channel 0, passing through other events. The construct above is commonly used -- if any of the midirecv*() functions are called, one must always get all events and send any events desired to be passed through.
 

 If only three parameters are passed to midirecv, the third parameter will receive both the second and third bytes of a MIDI message (second byte + (third byte * 256)).
 

 Calling midirecv() will automatically passthrough any SysEx events encountered; if you wish to process SysEx events, please use midirecv_buf() instead.

* **midirecv_buf(offset,buf, maxlen) * -- REAPER 4.60+**

Receives a message to a buffer, including any SysEx messages whose length is not more than maxlen.

```eel2
@block
 buf = 10000;
 maxlen = 65536;
 while ((recvlen = midirecv_buf(offset,buf,maxlen)) > 0) (
 recvlen <= 3 && buf[0] == $x90 && buf[2] !=0 ? (
 noteon_cnt+=1; // count note-ons
 ) : (
 midisend_buf(offset,buf,recvlen); // passthrough other events
 )
 );
```

 The above example will filter all noteons on channel 0, passing through other events. The construct above is commonly used -- if any of the midirecv*() functions, one must always get all events and send any events desired to be passed through.

 If maxlen is smaller than the length of the MIDI message, the MIDI message will automatically be passed through.

 For one and two byte MIDI messages (such as channel pressure), the length returned may or may not be 2 or 3.

* **midirecv_str(offset, string) * -- REAPER 4.60+**

Receives a MIDI or SysEx message to a string.

```eel2
@block
 while (midirecv_str(offset,#str)) (
 strlen(#str) <= 3 && str_getchar(#str,0) == $x90 && str_getchar(#str,2) != 0 ? (
 noteon_cnt+=1; // count note-ons
 ) : (
 midisend_str(offset,#str);
 )
 );
```

 The above example will filter all noteons on channel 0, passing through other events. The construct above is commonly used -- if any of the midirecv*() functions, one must always get all events and send any events desired to be passed through.

 midirecv_str() will return the length of the message on success, or 0 on failure. On failure (no more messages), the value of the string passed in is undefined. strlen(#str) may be 1,2 or 3 for one or two byte MIDI messages.

* **midisyx(offset,msgptr,len) * -- deprecated in REAPER 4.60+**

```eel2
buf[0] = $x01;
 buf[1] = $x02;
 midisyx(offset,buf,2); // send sysex: f0 01 02 f7
```

Sends a SysEx message -- if the message does not begin with F0 and end with F7, these will be automatically added. If the message crosses any 64k boundaries, it will be sent as multiple messages. This function is deprecated, midisend_buf() should probably be used instead.

---

top
 **MIDI Bus Support***
REAPER supports multiple MIDI buses, JSFX plug-ins can (but do not by default) access all 16 buses.

* **ext_midi_bus * -- REAPER 4.16+**

 Set to 1.0 in @init to enable support for MIDI buses (by default buses other than bus 0 will be passed through).

* **midi_bus * -- REAPER 4.16+**

 If ext_midi_bus is set, this will be set by midirecv() to the MIDI bus of the event, and will be used by midisend() et al to route the MIDI event accordingly. Valid values are 0..15.

## REAPER | JSFX Programming Reference - File I/O and Serializationback to main JSFX reference page

## JSFX Programming Reference - File I/O and Serialization
* File I/O and Serialization

---

top
 **File I/O and Serialization***

The following functions can be used in the @serialize section or in other sections.

 **Using with @serialize:***

Pass 0 as a handle to various file_*() functions, but do not call file_open() or file_close(). Simple @serialize code will often appear the same for read and write, as file_var(0,x) will read/write x depending on the mode. If you want to have different logic per mode, you can check file_avail(0)>=0 to determine if it is in read mode.

 **Using in other sections:***

file_open() and file_close() can be used to open files for reading in any section.

* **file_open(index or slider)**

 Example: 

```eel2
filename:0,myfile.wav
 handle = file_open(0);
```

 Example: 

```eel2
slider1:/mydata:mydef.wav:WAV File
 handle = file_open(slider1);
```

 Example ( * REAPER 4.59+): 

```eel2
handle = file_open(string);
```

 Opens a file from either the effect filename list or from a file slider, or from a string ( *REAPER 4.59+).*
 Once open, you may use all of the file functions available. Be sure to
 close the file handle when done with it, using file_close(). The search path for finding files depends on the method used, but generally speaking in 4.59+ it will look
 in the same path as the current effect, then in the JS Data/ directory.
 

 *REAPER v6.17+: string can be an absolute path to a file.*
 

 If file_open() fails, it will return < 0 (usually -1).

* **file_close(handle)**

 Example: 

```eel2
file_close(handle);
```

 Closes a file opened with file_open().

* **file_rewind(handle)**

 Example: 

```eel2
file_rewind(handle);
```

 Use this to rewind the current file to the beginning, to re-read the file etc.

* **file_var(handle,variable)**

 Example: 

```eel2
file_var(handle,myVar);
```

 This reads (or writes if in a @serialize write) the variable from(to) the current file.

* **file_mem(handle,offset, length)**

 Example: 

```eel2
amt=file_mem(handle,offset,len);
```

 This reads (or writes) the block of local memory from(to) the current file.
 Returns the actual number of items read (or written).

* **file_avail(handle)**

 Example:

```eel2
len=file_avail(handle);
```

 Returns the number of items remaining in the file, if it is in read
 mode. Returns < 0 if in write mode. If the file is in text mode
 (file_text(handle) returns TRUE), then the return value is simply
 0 if EOF, 1 if not EOF.

* **file_riff(handle,nch,samplrate)**

 Example:

```eel2
file_riff(handle,nch,samplrate);
 nch ? file_mem(handle,0,file_avail(0));
```

 If the file was a media file (.wav, .ogg, etc), this will set the first parameter to the number of channels, and the second to the samplerate.
 

 *REAPER 6.29+: if the caller sets nch to 'rqsr' and samplerate to a valid samplerate, the file will be resampled to the desired samplerate (this must ONLY be called before any file_var() or file_mem() calls and will change the value returned by file_avail())*

* **file_text(handle,istext)**

 Example:

```eel2
istext=file_text(handle);
 istext ? use_diff_avail syntax;
```

 If the file was a text file (and ended in .txt), this will
 return 1. If you need to use different file_avail() logic
 for text files (you often will), you can query it this way.

 **Text file notes***

 Note that if in an extended file-slider code section, and the extension of the
 file is .txt, it will read a series of tokens (see below) delimited by newlines or commas.
 Comments can be specified with a ; or # which makes the rest of the line ignored.
 

 Note that file_avail() should be called to check for EOF
 after each read, and if it returns 0, the last file_var() should be ignored.
 

 You can also use file_mem(offs,bignum) and it will read the maximum available.
 

 The format of each newline or comma delimited record can be:
* a floating point number
 
* a binary number beginning with 'b', i.e. b0101010111
 
* a hexadecimal number beginning with 'x', i.e. xDEADF000.
 
* a combination of numbers or symbolic values using basic +. -, |, & and parentheses.
 
* an assignment (e.g. NAME = 1.0) to create a symbolic constants (this does not count as a record and is otherwise ignored)
 

* **file_string(handle,str) * -- REAPER 4.59+**

Reads or writes a string from/to the file handle. If operating on a normal file, the string will be a line of text (possibly including newline or other characters). If in @serialize, the string will be encoded as a blob with length, which means that it is binary-safe (you can include NUL characters within the string etc).

## REAPER | JSFX Programming Reference - Memory/Slider/FFT/MDCT Functionsback to main JSFX reference page

## JSFX Programming Reference - Memory/Slider/FFT/MDCT Functions
* Memory/FFT/MDCT Functions
* Host Interaction Functions

---

top
 **Memory/FFT/MDCT Functions***

 **FFT/MDCT/Convolution***
* **mdct(start_index, size), imdct(start_index, size)**

Example:

```eel2
mdct(0, 512);
```

 Performs a modified DCT (or inverse in the case of imdct()) on the data
 in the local memory buffer at the offset specified by the first parameter.
 The second parameter controls the size of the MDCT, and it MUST be one of
 the following: 64, 128, 256, 512, 1024, 2048, or 4096. The MDCT takes the number of
 inputs provided, and replaces the first half of them with the results. The
 IMDCT takes size/2 inputs, and gives size results.

 Note that the MDCT must NOT cross a 65,536 item boundary, so be sure to
 specify the offset accordingly.

 The MDCT/IMDCT provided also provide windowing, so your code is not required
 to window the overlapped results, but simply add them. See the example
 effects for more information.

* **fft(start_index, size), ifft(start_index, size)**
 **fft_real(start_index, size), ifft_real(start_index, size)***
 **fft_permute(index,size), fft_ipermute(index,size)***

 Example:

```eel2
buffer=0;
 fft(buffer, 512);
 fft_permute(buffer, 512);
 buffer[32]=0;
 fft_ipermute(buffer, 512);
 ifft(buffer, 512);
 // need to scale output by 1/512.0, too.
```

 Performs a FFT (or inverse in the case of ifft()) on the data in the local
 memory buffer at the offset specified by the first parameter.
 The size of the FFT is specified by the second parameter, which must be
 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, or 32768. The outputs
 are permuted, so if you plan to use them in-order, call **fft_permute(buffer, size)***
 before and **fft_ipermute(buffer,size) after your in-order use.***
 Your inputs or outputs will need to be scaled down by 1/size, if used.
 

 Note that the FFT/IFFT require real/imaginary input pairs (so a
 256 point FFT actually works with 512 items).
 

 Note that the FFT/IFFT must NOT cross a 65,536 item boundary, so be sure to
 specify the offset accordingly.
 

 The fft_real()/ifft_real() variants operate on a set of size real inputs, and produce size/2 complex
 outputs. The first output pair is DC,nyquist. Normally this is used with fft_permute(buffer,size/2).
 

* **convolve_c(dest,src,size)**

 Used to convolve two buffers, typically after FFTing them.
 convolve_c works with complex numbers. The sizes specify number
 of items (the number of complex number pairs).
 

 Note that the convolution must NOT cross a 65,536 item boundary,
 so be sure to specify the offset accordingly.
 **Memory Utility***
* **freembuf(top)**

 The freembuf() function provides a facility for you to notify the memory
 manager that you are no longer using a portion of the local memory buffer.
 

 For example, if the user changed a parameter on your effect halving your
 memory requirements, you should use the lowest indices possible, and call
 this function with the highest index you are using plus 1, i.e. if you are
 using 128,000 items, you should call freembuf(128001); If you are no longer
 using any memory, you should call freembuf(0);
 

 Note that calling this does not guarantee that the memory is freed or
 cleared, it just provides a hint that it is OK to free it.

* **memcpy(dest,source,length)**

 The memcpy() function provides the ability to quickly copy regions of the
 local memory buffer. If the buffers overlap and either buffer crosses a 65,536 item boundary, the
 results may be undefined.
 

* **memset(dest,value,length)**

 The memset() function provides the ability to quickly set a region of the
 local memory buffer to a particular value.
 

* **mem_set_values(buf, ...) * -- REAPER 5.28+**

 Writes values to memory starting at buf from variables specified. Slower than regular memory writes for less than a few variables, faster for more than a few. Undefined behavior if used with more than 32767 variables.
 

* **mem_get_values(buf, ...) * -- REAPER 5.28+**

 Reads values from memory starting at buf into variables specified. Slower than regular memory reads for less than a few variables, faster for more than a few. Undefined behavior if used with more than 32767 variables.
 

* **mem_multiply_sum(buf1,buf2,length) * -- REAPER 6.74+**

 Sums the products of length items of buf1 and buf2. If buf1 is exactly -1, then sums the squares of items in buf2. If buf1 is exactly -2 then sums the absolute values of buf2. If buf1 is exactly -3 then sums the values of buf2. If buf1 is another negative value, the result is undefined.
 

* **mem_insert_shuffle(buf,len,value) * -- REAPER 6.74+**

 Shuffles buf to the right by one element, inserting value as buf[0], and returning the previous buf[len-1].
 

* **__memtop()**

 Returns the total number of memory slots available to the plug-in.

 **Stack***

A small (approximately 4096 item) user stack is available for use in code ( *REAPER 4.25+):*

* **stack_push(value)**

 Pushes value onto the user stack, returns a reference to the value.
 

* **stack_pop(value)**

 Pops a value from the user stack into value, or into a temporary buffer if value is not specified, and returns a reference to where the stack was popped. Note that no checking is done to determine if the stack is empty, and as such stack_pop() will never fail.

* **stack_peek(index)**

 Returns a reference to the item on the top of the stack (if index is 0), or to the Nth item on the stack if index is greater than 0.
 

* **stack_exch(value)**

 Exchanges a value with the top of the stack, and returns a reference to the parameter (with the new value).
 

 **Atomic Variable Access***

Guaranteed-atomic updates/accesses of values across contexts (specifically @gfx and other contexts). Normally these are unnecessary, but they are provided for the discriminating JSFX user -- *REAPER 4.5+:*

* **atomic_setifequal(dest,value,newvalue)**

Sets dest to newvalue if dest equals value. Returns the old value of dest. On Windows this is known as InterlockedCompareExchange().

* **atomic_exch(val1,val2)**

Exchanges val1 and val2, returns the new value of val1.

* **atomic_add(dest_val1,val2)**

Adds val2 to dest_val1, returns the value of dest_val1.

* **atomic_set(dest_val1,val2)**

Sets dest_val1 to val2, returns the value of dest_val1.

* **atomic_get(val)**

Returns the value of val.

---

top
 **Host Interaction Functions***

 **Slider Functions***

 For these functions, the parameter can be the variables slider1-sliderN, in
 which case that slider is refreshed. Otherwise, it can be a bitmask of which
 sliders have changed, where 1 would be the first slider, 2 would be the
 second, 4 would be the third, 32768 being the 16th slider, and so on.
* **sliderchange(mask or sliderX)**

 Example: 

```eel2
sliderchange(slider4);
```

 or

```eel2
sliderchange(2 ^ sliderindex);
```

 The sliderchange() function provides a facility for you to notify REAPER/JS
 that you have changed a sliderX variable from code
 so that it can update any embedded displays.

 This function does not send automation notifications to the host -- use slider_automate() if that is desired.

 If sliderchange() is called from @gfx with -1.0 as a parameter, REAPER will add a new undo point. This is useful if internal state changes due to user interaction in @gfx.

* **slider_automate(mask or sliderX[, end_touch]) * -- end_touch requires REAPER 6.74+**

 Example: 

```eel2
slider_automate(slider4);
```

 or

```eel2
slider_automate(2 ^ sliderindex);
```

 The slider_automate() function provides a facility for you to notify REAPER/JS
 that you have changed a sliderX variable so that
 it can update the display, and record the move as automation. This function is not
 necessary to call from the @slider code section,
 it is provided so that other code sections can write programmatic automation messages.

 In REAPER 6.74+, you can call slider_automate(mask, 1) in order to end a touch automation recording session.

* **slider_show(mask or sliderX[, value]) *-- REAPER 6.30+***

Queries (if value is omitted) or sets the visibility of one or more sliders. If value is -1, toggles visibility, value of 0 hides, 1 shows. Returns the mask of requested visible sliders.
 **Media Export***

* **export_buffer_to_project(buffer,length_samples,nch,srate,track_index[,flags,tempo,planar_pitch]) -- *REAPER 6.05+***

Writes the audio contents of buffer(s) to an audio file and inserts into project. This may only be called from the @gfx section, it should not be called from any other context.
* buffer: a pointer to the first sample of the first channel of audio data
 
* length_samples: number of samples (or sample-pairs etc) of audio data to write
 
* nch: number of channels to write
 
* srate: samplerate to write
 
* track_index: track index to insert media
 
* (optional) flags: bitmask:
* 4: stretch/loop item to fit time selection
 
* 8: tempo match to project 1x
 
* 16: tempo match to project 0.5x
 
* 32: tempo match to project 2x
 
* 64: do not preserve pitch when matching tempo
 
* 256: force loop of item regardless of preference of default item looping
 
* 0x10000: move edit cursor to end of project
 
* 0x20000: set tempo from tempo parameter
 
* (optional) tempo: ignored if flags does not have 0x20000 set, otherwise sets the project tempo to this value at the insertion point
 
* (optional) planar_pitch: if 0 or not specified, then multichannel exports are interleaved samples. If nonzero, then each channel is a separate buffer, and buffer[] is the first channel, (buffer+planar_pitch)[] is the second channel, (buffer+planar_pitch*2)[] is the third channel, etc. * -- REAPER 6.30+ **Pin Mapper Functions**
 *REAPER 6.27+ - these functions allow interacting with REAPER's pin mapper in advanced ways:*

* **get_host_numchan()**

Get the number of track or media item take channels

* **set_host_numchan(numchan)**

Set the number of track or media item take channels. only valid in @gfx section

* **get_pin_mapping(inout,pin,startchan,chanmask)**

Get a bitfield (maximum 32 bits) representing the channel mappings for this pin

* **set_pin_mapping(inout,pin,startchan,chanmask,mapping)**

Set the channel mappings for this pin/startchan/chanmask. only valid in @gfx section

* **get_pinmapper_flags(no parameters)**

Get the pinmapper flags for this fx. !&1=pass through unmapped output channels, &1=zero out unmapped output channels

* **set_pinmapper_flags(flags)**

Set the pinmapper flags for this fx. see get_pinmapper_flags. only valid in @gfx section
 **Host Placement Functions***

* **get_host_placement([chain_pos, flags]) * -- REAPER 6.74+**

Returns track index, or -1 for master track, or -2 for hardware output FX. chain_pos will be position in chain. flags will have 1 set if takeFX, 2 set if record input, 4 set if in inactive project.

## REAPER | JSFX Programming Reference - Stringsback to main JSFX reference page

## JSFX Programming Reference - Strings
* Strings
* String functions

---

top
 **Strings***

 *Note: the functionality available in this section requires REAPER 4.59+*

Strings can be specified as literals using quotes, such as "This is a test string". Much of the syntax mirrors that of C: you must escape quotes with backslashes to put them in strings ("He said \"hello, world\" to me"), multiple literal strings will be automatically concatenated by the compiler. Unlike C, quotes can span multiple lines. There is a soft limit on the size of each string: attempts to grow a string past about 16KB will result in the string not being modified.

Strings are always refered to by a number, so one can reference a string using a normal JS variable:

```eel2
x = "hello world";
 gfx_drawstr(x);
```

Literal strings are immutable (meaning they cannot be modified). If you wish to have mutable strings, you have three choices:
* You can use the fixed values of 0-1023:

```eel2
x = 50; // string slot 50
 strcpy(x, "hello ");
 strcat(x, "world");
 gfx_drawstr(x);
```

This mode is useful if you need to build or load a table of strings.

* You can use # to get an instance of a temporary string:

```eel2
x = #;
 strcpy(x, "hello ");
 strcat(x, "world");
 gfx_drawstr(x);
```

Note that the scope of these temporary instances is very limited and unpredictable, and their initial values are undefined.

* Finally, you can use named strings, which are the equivalent of normal variables:

```eel2
x = #myString;
 strcpy(x, "hello world");
```

The value of named strings is defined to be empty at script load, and to persist throughout the life of your script. There is also a shortcut to assign/append to named strings:

```eel2
#myString = "hello "; // same as strcpy(#myString, "hello ");
 #myString += "world"; // same as strcat(#myString, "world");
```

---

top
 **String functions***

* **strlen(str) -- returns length of string**

* **strcpy(str, srcstr) -- copies srcstr into str, returns str**

* **strcat(str, srcstr) -- appends srcstr to str, returns str**

* **strcmp(str, str2) -- compares str to str2, case sensitive, returns -1, 0, or 1**

* **stricmp(str, str2) -- compares str to str2, ignoring case, returns -1, 0, or 1**

* **strncmp(str, str2, maxlen) -- compares str to str2 up to maxlen bytes, case sensitive, returns -1, 0, or 1**

* **strnicmp(str, str2, maxlen) -- compares str to str2 up to maxlen bytes, ignoring case, returns -1, 0, or 1**

* **strncpy(str, srcstr, maxlen) -- copies srcstr into str, but stops after maxlen bytes. returns str**

* **strncat(str, srcstr, maxlen) -- appends srcstr to str, but stops after maxlen bytes of srcstr have been read. returns str**

* **strcpy_from(str,srcstr, offset) -- copies srcstr to str, starting offset bytes into srcstr. returns str.**

* **strcpy_substr(str,srcstr, offset, maxlen) -- copies srcstr to str, starting offset bytes into srcstr, and up to maxlen bytes. if offset is less than 0, offset is from end of source string. If maxlen is less than 0, length is limited to output string length shortened by maxlen. returns str.**

* **str_getchar(str, offset[, type]) -- returns the data at byte-offset offset of str. if offset is negative, position is relative to end of string. Type defaults to signed char, but can be specified to read raw binary data in other formats (note the single quotes, these are single/multi-byte characters):**
* 'c' - signed char

* 'cu' - unsigned char

* 's' - signed short

* 'S' - signed short, big endian

* 'su' - unsigned short

* 'Su' - unsigned short, big endian

* 'i' - signed int

* 'I' - signed int, big endian

* 'iu' - unsigned int

* 'Iu' - unsigned int, big endian

* 'f' - float

* 'F' - float, big endian

* 'd' - double

* 'D' - double, big endian

* **str_setchar(str, offset, value[, type]) -- sets the value at byte-offset "offset" of str to value (which may be one or more bytes of data). If offset is negative, then offset is relative to end of the string. If offset is the length of the string, or between (-0.5,0.0), then the character (or multibyte value if type is specified) will be appended to the string.**

* **strcpy_fromslider(str, slider) -- gets the filename if a file-slider, or the string if the slider specifies string translations, otherwise gets an empty string. slider can be either an index, or the sliderX variable directly. returns str.**

* **sprintf(str,format, ...) -- copies format to str, converting format strings:**
* %% = %
 
* %s = string from parameter
 
* %d = parameter as integer
 
* %i = parameter as integer
 
* %u = parameter as unsigned integer
 
* %x = parameter as hex (lowercase) integer
 
* %X = parameter as hex (uppercase) integer
 
* %c = parameter as character
 
* %f = parameter as floating point
 
* %e = parameter as floating point (scientific notation, lowercase)
 
* %E = parameter as floating point (scientific notation, uppercase)
 
* %g = parameter as floating point (shortest representation, lowercase)
 
* %G = parameter as floating point (shortest representation, uppercase)

Many standard C printf() modifiers can be used, including:
* %.10s = string, but only print up to 10 characters
 
* %-10s = string, left justified to 10 characters
 
* %10s = string, right justified to 10 characters
 
* %+f = floating point, always show sign
 
* %.4f = floating point, minimum of 4 digits after decimal point
 
* %10d = integer, minimum of 10 digits (space padded)
 
* %010f = integer, minimum of 10 digits (zero padded)

Values for format specifiers can be specified as additional parameters to sprintf, or within {} in the format specifier (such as %{varname}d, in that case a global variable is always used).

* **match(needle, haystack, ...) -- search for needle in haystack**
 **matchi(needle, haystack, ...) -- search for needle in haystack (case insensitive)***

For these you can use simplified regex-style wildcards:
* * = match 0 or more characters
 
* *? = match 0 or more characters, lazy
 
* + = match 1 or more characters
 
* +? = match 1 or more characters, lazy
 
* ? = match one character

Examples:

```eel2
match("*blah*", "this string has the word blah in it") == 1
 match("*blah", "this string ends with the word blah") == 1
```

You can also use format specifiers to match certain types of data, and optionally put that into a variable:
* %s means 1 or more chars
 
* %0s means 0 or more chars
 
* %5s means exactly 5 chars
 
* %5-s means 5 or more chars
 
* %-10s means 1-10 chars
 
* %3-5s means 3-5 chars.
 
* %0-5s means 0-5 chars.
 
* %x, %d, %u, and %f are available for use similarly
 
* %c can be used, but can't take any length modifiers
 
* Use uppercase (%S, %D, etc) for lazy matching
 
The variables can be specified as additional parameters to match(), or directly within {} inside the format tag (in this case the variable will always be a global variable):
 

```eel2
match("*%4d*","some four digit value is 8000, I say",blah)==1 && blah == 8000
 match("*%4{blah}d*","some four digit value is 8000, I say")==1 && blah == 8000
```

## REAPER | JSFX Programming Reference - Graphicsback to main JSFX reference page

## JSFX Programming Reference - Graphics
* Graphics

---

top
 **Graphics***

Effects can specify a @gfx code section, from which the effect can draw its own custom UI and/or analysis display.

These functions and variables must only be used from the @gfx section.

* **gfx_set(r[g,b,a,mode,dest,a2]) * -- REAPER 4.76+**

Sets gfx_r/gfx_g/gfx_b to r or r,g,b. gfx_a is set to 1 if not specified. gfx_mode is set to 0 if not specified. gfx_dest is set only if dest is specified. gfx_a2 is always set to a2 if specified, otherwise to 1.0.

* **gfx_lineto(x,y,aa) * -- the aa parameter is optional in REAPER 4.59+**

Draws a line from gfx_x,gfx_y to x,y. if aa is 0.5 or greater, then antialiasing is used. Updates gfx_x and gfx_y to x,y.

* **gfx_line(x,y,x2,y2[,aa]) * -- REAPER 4.59+**

Draws a line from x,y to x2,y2, and if aa is not specified or 0.5 or greater, it will be antialiased.

* **gfx_rectto(x,y)**

Fills a rectangle from gfx_x,gfx_y to x,y. Updates gfx_x,gfx_y to x,y.

* **gfx_rect(x,y,w,h) * -- REAPER 4.59+**

Fills a rectngle at x,y, w,h pixels in dimension.

* **gfx_setpixel(r,g,b)**

Writes a pixel of r,g,b to gfx_x,gfx_y.

* **gfx_getpixel(r,g,b)**

Gets the value of the pixel at gfx_x,gfx_y into r,g,b.

* **gfx_drawnumber(n,ndigits)**

Draws the number "n" with "ndigits" of precision to gfx_x, gfx_y, and updates
gfx_x to the right side of the drawing. The text height is gfx_texth

* **gfx_drawchar($'c')**

Draws the character 'c' (can be a numeric ASCII code as well), to gfx_x, gfx_y, and moves gfx_x over by the size of the character.

* **gfx_drawstr(str[,flags,right,bottom]) * -- REAPER 4.59+**

Draws a string at gfx_x, gfx_y, and updates gfx_x/gfx_y so that subsequent draws will occur in a similar place: 

```eel2
gfx_drawstr("a"); gfx_drawstr("b");
```

will look about the same as:

```eel2
gfx_drawstr("ab");
```

In REAPER 5.30+, flags,right,bottom can be specified to control alignment:
* flags&1: center horizontally
 
* flags&2: right justify
 
* flags&4: center vertically
 
* flags&8: bottom justify
 
* flags&256: ignore right/bottom, otherwise text is clipped to (gfx_x, gfx_y, right, bottom)

* **gfx_measurestr(str,w,h) * -- REAPER 4.59+**

Measures the drawing dimensions of a string with the current font (as set by gfx_setfont).

* **gfx_setfont(idx[,fontface, sz, flags]) * -- REAPER 4.59+**

Can select a font and optionally configure it. idx=0 for default bitmapped font, no configuration is possible for this font. idx=1..16 for a configurable font, specify fontface such as "Arial", sz of 8-100, and optionally specify flags, which is a multibyte character, which can include 'i' for italics, 'u' for underline, or 'b' for bold. These flags may or may not be supported depending on the font and OS. After calling gfx_setfont, gfx_texth may be updated to reflect the new average line height.

* **gfx_getfont() * -- REAPER 4.59+**

Returns current font index.

* **gfx_printf(str, ...) * -- REAPER 4.59+**

Formats and draws a string at gfx_x, gfx_y, and updates gfx_x/gfx_y accordingly (the latter only if the formatted string contains newline).

* **gfx_blurto(x,y) * -- REAPER 2.018+**

Blurs the region of the screen between gfx_x,gfx_y and x,y, and updates gfx_x,gfx_y to x,y.

* **gfx_blit(source, scale, rotation) * -- REAPER 2.018+**

If three parameters are specified, copies the entirity of the source bitmap to gfx_x,gfx_y using current opacity and copy mode (set with gfx_a, gfx_mode). You can specify scale (1.0 is unscaled) and rotation (0.0 is not rotated, angles are in radians).

For the "source" parameter specify -1 to use the main framebuffer as source, or 0..127 to use the image specified (or PNG file in a filename: line).

 **gfx_blit(source, scale, rotation[, srcx, srcy, srcw, srch, destx, desty, destw, desth, rotxoffs, rotyoffs]) * -- REAPER 4.59+***

Srcx/srcy/srcw/srch specify the source rectangle (if omitted srcw/srch default to image size), destx/desty/destw/desth specify dest rectangle (if not specified, these will default to reasonable defaults -- destw/desth default to srcw/srch * scale).

* **gfx_blitext(source, coordinatelist, rotation) * -- REAPER 2.018+**

This is a version of gfx_blit which takes many of its parameters via a buffer rather than direct parameters.

For the "source" parameter specify -1 to use the main framebuffer as source, or 0..127 to use the image specified (or PNG file in a filename: line).

coordinatelist should be an index to memory where a list of 10 parameters are stored, such as:

```eel2
coordinatelist=1000; // use memory slots 1000-1009
 coordinatelist[0]=source_x;
 coordinatelist[1]=source_y;
 coordinatelist[2]=source_w;
 coordinatelist[3]=source_h;
 coordinatelist[4]=dest_x;
 coordinatelist[5]=dest_y;
 coordinatelist[6]=dest_w;
 coordinatelist[7]=dest_h;
 coordinatelist[8]=rotation_x_offset; // only used if rotation is set, represents offset from center of image
 coordinatelist[9]=rotation_y_offset; // only used if rotation is set, represents offset from center of image
 gfx_blitext(img,coordinatelist,angle);
```

* **gfx_getimgdim(image, w, h) * -- REAPER 2.018+**

Retreives the dimensions of image (representing a filename: index number) into w and h. Sets these values to 0 if an image failed loading (or if the filename index is invalid).

* **gfx_setimgdim(image, w,h) * -- REAPER 4.59+**

Resize image referenced by index 0..127, width and height must be 0-2048. The contents of the image will be undefined after the resize.

* **gfx_loadimg(image, filename) * -- REAPER 4.59+**

Load image from filename (see strings) into slot 0..127 specified by image. Returns the image index if success, otherwise -1 if failure. The image will be resized to the dimensions of the image file.

* **gfx_gradrect(x,y,w,h, r,g,b,a[, drdx, dgdx, dbdx, dadx, drdy, dgdy, dbdy, dady]) * -- REAPER 4.59+**

Fills a gradient rectangle with the color and alpha specified. drdx-dadx reflect the adjustment (per-pixel) applied for each pixel moved to the right, drdy-dady are the adjustment applied for each pixel moved toward the bottom. Normally drdx=adjustamount/w, drdy=adjustamount/h, etc.

* **gfx_muladdrect(x,y,w,h, mul_r, mul_g, mul_b[, mul_a, add_r, add_g, add_b, add_a]) * -- REAPER 4.59+**

Multiplies each pixel by mul_* and adds add_*, and updates in-place. Useful for changing brightness/contrast, or other effects.

* **gfx_deltablit(srcimg,srcx,srcy,srcw,srch, destx, desty, destw, desth, dsdx, dtdx, dsdy, dtdy, dsdxdy, dtdxdy[, usecliprect=1] ) * -- REAPER 4.59+**

Blits from srcimg(srcx,srcy,srcw,srch) to destination (destx,desty,destw,desth). Source texture coordinates are s/t, dsdx represents the change in s coordinate for each x pixel, dtdy represents the change in t coordinate for each y pixel, etc. dsdxdy represents the change in dsdx for each line. In REAPER 5.96+ usecliprect=0 can be specified as an additional parameter.

* **gfx_transformblit(srcimg, destx, desty, destw, desth, div_w, div_h, table) * -- REAPER 4.59+**

Blits to destination at (destx,desty), size (destw,desth). div_w and div_h should be 2..64, and table should point to a table of 2*div_w*div_h values (this table must not cross a 65536 item boundary). Each pair in the table represents a S,T coordinate in the source image, and the table is treated as a left-right, top-bottom list of texture coordinates, which will then be rendered to the destination.

* **gfx_circle(x,y,r[,fill,antialias]) * -- REAPER 4.60+**

Draws a circle, optionally filling/antialiasing.

* **gfx_roundrect(x,y,w,h,radius[,antialias]) * -- REAPER 4.60+**

Draws a rectangle with rounded corners.

* **gfx_arc(x,y,r, ang1, ang2[,antialias]) * -- REAPER 4.60+**

Draws an arc of the circle centered at x,y, with ang1/ang2 being specified in radians.

* **gfx_triangle(x1,y1,x2,y2,x3,y3[,x4,y4,...]) * -- REAPER 5.0+**

Fills a triangle (or a convex polygon if more than 3 pairs of coordinates are specified).

* **gfx_getchar([char, unicodechar]) * -- REAPER 4.60+, unicodechar requires REAPER 6.74+**

If no parameter or zero is passed, returns a character from the plug-in window's keyboard queue. The return value will be less than 1 if no value is available. Note that calling gfx_getchar() at least once causes mouse_cap to reflect keyboard modifiers even when the mouse is not captured. 

If char is passed and nonzero, returns whether that key is currently down.

Common values are standard ASCII, such as 'a', 'A', '=' and '1', but for many keys multi-byte values are used, including 'home', 'up', 'down', 'left', 'rght', 'f1'.. 'f12', 'pgup', 'pgdn', 'ins', and 'del'. 

If the user has the "send all keyboard input to plug-in" option set, then many modified and special keys will be returned, including:
* Ctrl/Cmd+A..Ctrl+Z as 1..26

* Ctrl/Cmd+Alt+A..Z as 257..282,

* Alt+A..Z as 'A'+256..'Z'+256

* 27 for ESC

* 13 for Enter

* ' ' for space

The plug-in can specify a line (before code sections):

```eel2
options:want_all_kb
```

which will change the "send all keyboard input to plug-in" option to be on by default for new instances of the plug-in. * -- REAPER 4.6+

In REAPER 5.96+, gfx_getchar(65536) returns a mask of special window information flags: 1 is set if supported, 2 is set if window has focus, 4 is set if window is visible.

In REAPER 6.74+, non-ASCII unicode characters are returned as: ('u'<<24) | unicode_value. You can also pass unicodechar as a second parameter (passing 0 as the first parameter), and if a non-ASCII unicode character is pressed, unicodechar will be set to unicode value directly.

* **gfx_showmenu("str") * -- REAPER 4.76+**

Shows a popup menu at gfx_x,gfx_y. str is a list of fields separated by | characters. Each field represents a menu item.
Fields can start with special characters:
* # : grayed out

* ! : checked

* > : this menu item shows a submenu

* < : last item in the current submenu

An empty field will appear as a separator in the menu. gfx_showmenu returns 0 if the user selected nothing from the menu, 1 if the first field is selected, etc.

Example:

gfx_showmenu("first item, followed by separator||!second item, checked|>third item which spawns a submenu|#first item in submenu, grayed out|<second and last item in submenu|fourth item in top menu")

* **gfx_setcursor(resource_id[,"custom cursor name"]) * -- REAPER 4.76+**

Sets the mouse cursor. resource_id is a value like 32512 (for an arrow cursor), custom_cursor_name is a string description (such as \"arrow\") that will be override the resource_id, if available. In either case resource_id should be nonzero.

* **gfx_r, gfx_g, gfx_b, gfx_a**

These represent the current red, green, blue, and alpha components used by drawing operations (0.0..1.0).

* **gfx_w, gfx_h**

These are set to the current width and height of the UI framebuffer.

* **gfx_x, gfx_y**

These set the "current" graphics position in x,y. You can set these yourselves, and many of the drawing functions update them as well.

* **gfx_a2**

Sets the alpha channel value to be written to the image. Normally the alpha channel for images is ignored, however if you are creating an image that will be blitted later, you may wish to modify the alpha channel with this value. Defaults to 1.0.

* **gfx_mode**

Set to 0 for default options. Add 1.0 for additive blend mode (if you wish to do subtractive, set gfx_a to negative and use gfx_mode as additive). Add 2.0 to disable source alpha for gfx_blit(). Add 4.0 to disable filtering for gfx_blit().

* **gfx_clear**

If set to a value greater than -1.0, this will result in the framebuffer being cleared to that color. the color for this one is packed RGB (0..255), i.e. red+green*256+blue*65536. The default is 0 (black).

* **gfx_dest * -- REAPER 4.59+**

Defaults to -1, set to 0..127 to have drawing operations go to an offscreen buffer (or loaded image).

* **gfx_texth**

Set to the height of a line of text in the current font. Do not modify this variable.

* **gfx_ext_retina**

To support hidpi/retina, callers should set to 1.0 on initialization, this value will be updated to value greater than 1.0 (such as 2.0) if retina/hidpi. On macOS gfx_w/gfx_h/etc will be doubled, but on other systems gfx_w/gfx_h will remain the same and gfx_ext_retina is a scaling hint for drawing.

* **gfx_ext_flags**
Bitfield:
* 1: will be set in @gfx if the JSFX is embedded in TCP/MCP * -- REAPER 6.30+
* 2: will be set in @gfx if the JSFX is running in an idle context (implies options:gfx_idle or options:gfx_idle_only is set) * -- REAPER 6.44+
* 0x100 (256): script can set to specify that any embedded UI will be displayed without decoration (this should be done in @init but not later on). * -- REAPER 7.45+
* 0x200 (512): script can set to specify that any clicks on the embedded UI will be passed through and treated as an "open UI" command. This can be dynamically changed in @gfx depending on mouse position/etc. * -- REAPER 7.45+

* **mouse_x, mouse_y**

mouse_x and mouse_y are set to the coordinates of the mouse within the graphics area of the window.

* **mouse_cap**

A bitfield of mouse and keyboard modifier state. Note that a script must call gfx_getchar() at least once in order to get modifier state when the mouse is not captured by the window. Bitfield bits:
* 1: left mouse button

* 2: right mouse button

* 4: Control key (Windows), Command key (OSX)

* 8: Shift key

* 16: Alt key (Windows), Option key (OSX)

* 32: Windows key (Windows), Control key (OSX) * -- REAPER 4.60+
* 64: middle mouse button * -- REAPER 4.60+

* **mouse_wheel, mouse_hwheel * -- REAPER 4.60+**

mouse wheel (and horizontal wheel) positions. These will change typically by 120 or a multiple thereof, the caller should clear the state to 0
 after reading it.

## REAPER | JSFX Programming Reference - User Functions and Namespace Pseudo-Objectsback to main JSFX reference page

## JSFX Programming Reference - User Functions and Namespace Pseudo-Objects
* User defined functions and namespace pseudo-objects

---

top
 **User defined functions and namespace pseudo-objects***

 *Note: the functionality available in this section requires REAPER 4.25+*

JS now supports user defined functions, as well as some basic object style data access.

Functions can be defined anywhere in top level code (i.e. not within an existing () block, but before or after existing code), and in any section, although functions defined in @init can be used from other sections (whereas functions defined in other sections are local to those sections). Functions are not able to be called recursively -- this is enforced by functions only being able to call functions that are declared before the current function, and functions not being able to call themselves. Functions may have 0 to 40 parameters. To define a function, use the following syntax: 

```eel2
function getSampleRate()
 (
 srate; // return srate
 );

 function mySine(x)
 (
 // taylor approximation
 x - (x^3)/(3*2) + (x^5)/(5*4*3*2) - (x^7)/(7*6*5*4*3*2) + (x^9)/(9*8*7*6*5*4*3*2);
 );

 function calculateSomething(x y)
 (
 x += mySine(y);
 x/y;
 );
```

Which would then be callable from other code, such as:

```eel2
y = mySine($pi * 18000 / getSampleRate());
 z = calculateSomething(1,2);
```

Note that the parameters for functions are private to the function, and will not affect global variables. If you need more private variables for a function, you can declare additional variables using a local() statement between the function declaration and the body of the function. Variables declared in the local() statement will be local to that function, and persist across calls of the function (though calls to a function from two different sections (such as @init and @sample) will have two different local states. Example:

```eel2
function mySine(x) local(lastreq lastvalue)
 (
 lastreq != x ? (
 lastreq = x; // save last input
 // taylor approximation
 lastvalue = x - (x^3)/(3*2) + (x^5)/(5*4*3*2) - (x^7)/(7*6*5*4*3*2) + (x^9)/(9*8*7*6*5*4*3*2);
 );
 lastvalue; // result of function is cached value
 );
```

In the above example, mySine() will cache the last value used and not perform the calculation if the cached value is available. Note that the local variables are initialized to 0, which happens to work for this demonstration but if it was myCosine(), additional logic would be needed.

JS also supports relative namespaces on global variables, allowing for pseudo object style programming. Accessing the relative namespace is accomplished either by using a "this." prefix for variable/function names, or by using the instance() declaration in the function definition for variable names: 

```eel2
function set_foo(x) instance(foo)
 (
 foo = x;
 );
 // or
 function set_foo(x)
 (
 this.foo = x;
 );

 whatever.set_foo(32); // whatever.foo = 32;
 set_foo(32); // set_foo.foo = 32;

 function test2()
 (
 this.set_foo(32);
 );
 whatever.test2(); // whatever.foo = 32
```

Additionally functions can use the "this.." prefix for navigating up the namespace hierarchy, such as:

```eel2
function set_par_foo(x)
 (
 this..foo = x;
 );
 a.set_par_foo(1); // sets foo (global) to 1
 a.b.set_par_foo(1); // sets a.foo to 1
```

## REAPER | JSFX Programming Reference - EEL2 Preprocessorback to main JSFX reference page

## JSFX Programming Reference - EEL2 Preprocessor
* EEL2 Preprocessor
* Compile-time user-configurable JSFX settings

---

top
 **EEL2 Preprocessor***

JSFX (and ReaScript/EEL) in REAPER v6.74+ support the EEL2 preprocessor, which allows generating EEL2 code at compile-time. To make effecient JSFX/EEL2 code, it is often helpful to use named variables rather than memory, and when using a lot of variables it is often harder to write and maintain. The EEL2 preprocessor allows you to generate repetitive code dynamically.

To use the EEL2 preprocessor, one uses the tags <? and ?> in EEL2 code. Between these tags, a separate EEL2 compiler runs, using a minimal, separate, and non-persistent state, and can generate EEL2 code output using the printf() function.

Additionally, preprocessor code can suppress passthrough of existing text between its blocks by setting the _suppress variable (allowing for conditional compilation).

 **Examples***

Suppose you have state consisting of 16 values and you wish to clear that state:

```eel2
x00=0; x01=0; x02=0; x03=0; x04=0; x05=0; x06=0; x07=0;
 x08=0; x09=0; x10=0; x11=0; x12=0; x13=0; x14=0; x15=0;
```

Using the EEL2 preprocessor, you could write this as:

```eel2
<? x_size = 16; /* near the start of file, perhaps */ ?>

 ...

 <?
 // x_size will still be set
 loop(i=0;x_size, printf("x%02d=0;\n", i); i += 1);
 ?>
```

To use _suppress for conditional compilation, one does something along the lines of:

```eel2
<? some_config = 1; ?>

 ...

 <? some_config < 5 ? _suppress = 1; ?>

 do_some_extra_code() // only compiled if some_config is >= 5
 ...

 <? _suppress = 0; ?>
```

Note that in the preprocessor the only functions available are built-in EEL2 math/logic functions, and printf(). REAPER 6.82+ also supports include(), which allows JSFX to include additional EEL2 files inline (rather than @import which imports the file and its JSFX sections).

---

top
 **Compile-time user-configurable JSFX settings***

Starting with REAPER 7.0+, individual JSFX can define compile-time preprocessor configurations which can be used for extensive reconfiguration of the underlying JSFX. If the plug-in defines one or more "config:" lines near the top of its file, these configuration items will appear in the plug-in's "+" menu for the user to configure. Note that reconfiguring these parameters only affect the existing instance of the plug-in, and it causes the plug-in to lose all state. The benefit of this is that the plug-in can redefine its I/O, parameters, etc, according to these configuration items.

For example, super8 defines the following config: line:

```eel2
config: nch "Channels" 8 1 2 4 8="8 (namesake)" 12 16 24 32 48
```

In the above example:
* "nch" is the variable name which will be set for the preprocessor's context. Additionaly, it is the key name for the configuration item as it will be saved in presets/project files/etc.

* Channels is the user-visible description of the configuration item. This string can be changed and it will not affect presets/projects/etc.

* The first number, 8, is the default value for "nch."

* The remaining values are allowable options. Note that these all must be numeric values.

* Numeric values can have =string appended to them, in which case the item will be displayed as that string

* Supported in REAPER v7.28+ - if the description field has "-preserve-config" appended to it (e.g. "Channels -preserve-config"), then the user changing the configuration item will preserve the configuration state (slider values, any @serialize, etc). If implementing this, you must make sure your plug-in handles this correctly.

## EEL2
EEL2 is a language that powers REAPER's JSFX, Video Processors, ReaScript, and other functionality, and is also used by OSCII-bot. This document is purely for the core EEL2 functionality -- each use of EEL2 will define functions specific to its context.

 *(If you are a software developer and wish to integrate EEL2 into your software, it is BSD-licensed and included in WDL)*

* Basic Language Attributes
* Operator reference
* Simple math functions
* Loops
* Strings
* String functions
* User defined functions and namespace pseudo-objects
* Advanced Functions

---

top **Basic Language Attributes***

 
The core of EEL2 has many similarities to C but is distictly different. Some notable qualities of this language are:
* Variables do not need to be declared, are by default global, and are all double-precision floating point. 

* Variable names are NOT case sensitive, so a and A refer to the same variable.

* Variable names may begin with a _, a-z, or A-Z, and can contain numbers after one of those characters.

* The maximum variable name length is by default 127 characters.

* Variable names can also contain . characters, though this is used for namespaced pseudo-objects. 

* There are a few predefined constant variables: $pi, $phi, and $e.

* Parentheses "(" and ")" can be used to clarify precidence, contain parameters for functions, and collect multiple statements into a single statement.

* A semicolon ";" is used to separate statements from eachother (including within parentheses).

* A virtual local address space of about 8 million words (queryable at runtime via __memtop()) can be accessed via brackets "[" and "]". 

* A shared global address space of at least 1 million words, accessed via gmem[]. These words are shared between all script instances (the implementation can choose to partition separate instances depending on necessity).

* Shared global named variables, accessible via the "_global." prefix. These variables are shared between all script instances.

* User definable functions, which can define private variables, parameters, and also can optionally access namespaced instance variables. Recursion is NOT supported.

* Numbers are in normal decimal, however if you prefix a '$x' or '0x' to them, they will be hexadecimal (e.g. $x90, 0xDEADBEEF, etc).

* You may specify the ASCII value of a character using $'c' or 'c' (where c is the character). Multibyte characters are also supported using 'abc'.

* If you wish to generate a mask of 1 bits in integer, you can use $~X, for example $~7 is 127, $~8 is 255, $~16 is 65535, etc.

* Comments can be specified using:
* // comments to end of line

* /* comments block of code that span lines or be part of a line */

---

top **Operator reference***

Listed from highest precedence to lowest (but one should use parentheses whenever there is doubt!):
* **[ ]**

```eel2
z=x[y]; 
 x[y]=z;
```

 Brackets are used to index memory. The sum of the value to the left of the brackets and the value within the brackets is used to index memory. If a value in the brackets is omitted then only the value to the left of the brackets is used.

 *Note: due to legacy reasons, the summed address is rounded unconventionally (value + 0.00001, truncated to integer). If using fractional values to index a array, you may wish to manually truncate them to integer, e.g.:*

```eel2
x[y|0] = z
```

... *if y is not an integer.*

If 'gmem' is specified as the left parameter to the brackets, then the global shared buffer is used: 

```eel2
z=gmem[y]; 
 gmem[y]=z;
```

* **!value -- returns the logical NOT of the parameter (if the parameter is 0.0, returns 1.0, otherwise returns 0.0).**

* **-value -- returns value with a reversed sign (-1 * value).**

* **+value -- returns value unmodified. ***

* **base ^ exponent -- returns the first parameter raised to the power of the second parameter. This is also available the function pow(x,y) ***

* **numerator % denominator -- converts the absolute values of numerator and denominator to integers (may be 32-bit or 64-bit integers depending on platform/OS/etc), returns the remainder of numerator divided by denominator.**

* **value << shift_amt -- converts both values to 32 bit integers, bitwise left shifts the first value by the second. Note that shifts by more than 32 or less than 0 produce undefined results.**

* **value >> shift_amt -- converts both values to 32 bit integers, bitwise right shifts the first value by the second, with sign-extension (negative values of y produce non-positive results). Note that shifts by more than 32 or less than 0 produce undefined results.**

* **value / divisor -- divides two values and returns the quotient.**

* **value * another_value -- multiplies two values and returns the product.**

* **value - another_value -- subtracts two values and returns the difference.**

* **value + another_value -- adds two values and returns the sum.**

* *Note: the relative precedence of |, &, and ~ are equal, meaning a mix of these operators is evaluated left-to-right (which is different from other languages and may not be as expected). Use parentheses when mixing these operators.
* **a | b -- converts both values to integers (may be 32-bit or 64-bit integers depending on platform/OS/etc), and returns bitwise OR of values.**

* **a & b -- converts both values to integers (may be 32-bit or 64-bit integers depending on platform/OS/etc), and returns bitwise AND of values.**

* **a ~ b -- converts both values to integers (may be 32-bit or 64-bit integers depending on platform/OS/etc), bitwise XOR the values.**

* **value1 == value2 -- compares two values, returns 1 if difference is less than 0.00001, 0 if not.**

* **value1 === value2 -- compares two values, returns 1 if exactly equal, 0 if not.**

* **value1 != value2 -- compares two values, returns 0 if difference is less than 0.00001, 1 if not.**

* **value1 !== value2 -- compares two values, returns 0 if exactly equal, 1 if not.**

* **value1 < value2 -- compares two values, returns 1 if first parameter is less than second.**

* **value1 > value2 -- compares two values, returns 1 if first parameter is greater than second.**

* **value1 <= value2 -- compares two values, returns 1 if first is less than or equal to second.**

* **value1 >= value2 -- compares two values, returns 1 if first is greater than or equal to second.**

* *Note: the relative precedence of || and && are equal, meaning a mix of these operators is evaluated left-to-right (which is different from other languages and may not be as expected). Use parentheses when mixing these operators.
* **y || z -- returns logical OR of values. If 'y' is nonzero, 'z' is not evaluated.**

* **y && z -- returns logical AND of values. If 'y' is zero, 'z' is not evaluated.**

* **y ? z * -- how conditional branching is done -- similar to C's if/else**
 **y ? z : x***

 If y is non-zero, executes and returns z, otherwise executes and returns x (or 0.0 if *': x' is not specified). *
 

 Note that the expressions used can contain multiple statements within parentheses, such as:

```eel2
x % 5 ? (
 f += 1;
 x *= 1.5;*
 ) : (
 f=max(3,f);
 x=0;
 );
```

* **y = z -- assigns the value of 'z' to 'y'. 'z' can be a variable or an expression.**

* **y *= z -- multiplies two values and stores the product back into 'y'.***

* **y /= divisor -- divides two values and stores the quotient back into 'y'.**

* **y %= divisor -- converts the absolute values of y and divisor to integers (may be 32-bit or 64-bit integers depending on platform/OS/etc), returns and sets y to the remainder of y divided by divisor.**

* **base ^= exponent -- raises first parameter to the second parameter-th power, saves back to 'base'**

* **y += z -- adds two values and stores the sum back into 'y'.**

* **y -= z -- subtracts 'z' from 'y' and stores the difference into 'y'.**

* **y |= z -- converts both values to integer, and stores the bitwise OR into 'y'**

* **y &= z -- converts both values to integer, and stores the bitwise AND into 'y'**

* **y ~= z -- converts both values to integer, and stores the bitwise XOR into 'y'**

 
Some key notes about the above, especially for C programmers:
* ( and ) (vs { } ) -- enclose multiple statements, and the value of that expression is the last statement within the block:
 

```eel2
z = (
 a = 5; 
 b = 3; 
 a+b;
 ); // z will be set to 8, for example
```

* Conditional branching is done using the ? or ? : operator, rather than if()/else.

```eel2
a < 5 ? b = 6; // if a is less than 5, set b to 6
 a < 5 ? b = 6 : c = 7; // if a is less than 5, set b to 6, otherwise set c to 7
 a < 5 ? ( // if a is less than 5, set b to 6 and c to 7
 b = 6;
 c = 7;
 );
```

* The ? and ?: operators can also be used as the lvalue of expressions:

```eel2
(a < 5 ? b : c) = 8; // if a is less than 5, set b to 8, otherwise set c to 8
```

---

top **Simple math functions***

* **sin(angle) -- returns the Sine of the angle specified (specified in radians -- to convert from degrees to radians, multiply by $pi/180, or 0.017453)**

* **cos(angle) -- returns the Cosine of the angle specified (specified in radians).**

* **tan(angle) -- returns the Tangent of the angle specified (specified in radians).**

* **asin(x) -- returns the Arc Sine of the value specified (return value is in radians).**

* **acos(x) -- returns the Arc Cosine of the value specified (return value is in radians).**

* **atan(x) -- returns the Arc Tangent of the value specified (return value is in radians).**

* **atan2(x,y) -- returns the Arc Tangent of x divided by y (return value is in radians). **

* **sqr(x) -- returns the square of the parameter (similar to x*x, though only evaluating x once).**

* **sqrt(x) -- returns the square root of the parameter.**

* **pow(x,y) -- returns the first parameter raised to the second parameter-th power. Identical in behavior and performance to the ^ operator.**

* **exp(x) -- returns the number e (approx 2.718) raised to the parameter-th power. This function is significantly faster than pow() or the ^ operator**
* **log(x) -- returns the natural logarithm (base e) of the parameter.**

* **log10(x) -- returns the logarithm (base 10) of the parameter.**

* **abs(x) -- returns the absolute value of the parameter.**

* **min(x,y) -- returns the minimum value of the two parameters.**

* **max(x,y) -- returns the maximum value of the two parameters.**

* **sign(x) -- returns the sign of the parameter (-1, 0, or 1).**

* **rand(x) -- returns a psuedorandom number between 0 and the parameter.**

* **floor(x) -- rounds the value to the lowest integer possible (floor(3.9)==3, floor(-3.1)==-4).**

* **ceil(x) -- rounds the value to the highest integer possible (ceil(3.1)==4, ceil(-3.9)==-3).**

* **invsqrt(x) -- returns a fast inverse square root (1/sqrt(x)) approximation of the parameter.**
 

---

top **Loops***

Looping is supported in EEL2 via the following functions:
* **loop(count,code)**

```eel2
loop(32, 
 r += b;
 b = var * 1.5;
 );
```

 
 Evaluates the first parameter once in order to determine a loop count. If the loop count is less than 1, the second parameter is not evaluated.
 

 Implementations may choose to limit the number of iterations a loop is permitted to execute (usually such limits are in the millions and should rarely be encountered).
 

 
 The first parameter is only evaluated once (so modifying it within the code will have no effect on the number of loops). For a loop of indeterminate length, see while() below.
 

* **while(code)**

```eel2
while(
 a += b;
 b *= 1.5;*
 a < 1000; // as long as a is below 1000, we go again.
 );
```

 
 Evaluates the first parameter until the last statement in the code block evaluates to zero. 

 Implementations may choose to limit the number of iterations a loop is permitted to execute (usually such limits are in the millions and should rarely be encountered).

* **while(condition) ( code )**

```eel2
while ( a < 1000 ) (
 a += b;
 b *= 1.5;*
 );
```

 
 Evaluates the parameter, and if nonzero, evaluates the following code block, and repeats. This is similar to a C style while() construct. 

 Implementations may choose to limit the number of iterations a loop is permitted to execute (usually such limits are in the millions and should rarely be encountered).

---

top **Strings***

 *Note: Implementations may choose not to implement string functions*

Strings can be specified as literals using quotes, such as "This is a test string". Much of the syntax mirrors that of C: you must escape quotes with backslashes to put them in strings ("He said \"hello, world\" to me"), multiple literal strings will be automatically concatenated by the compiler. Unlike C, quotes can span multiple lines. Implementations may choose to impose a soft limit on the size of each string: attempts to grow a string past the limit will result in the string not being modified.

Strings are always refered to by a number, so one can reference a string using a normal EEL2 variable:

```eel2
x = "hello world";
 gfx_drawstr(x);
```

Literal strings are immutable (meaning they cannot be modified). If you wish to have mutable strings, you have three choices:
* You can use the fixed values of 0-1023 (implementations define the number of indexed strings available):

```eel2
x = 50; // string slot 50
 strcpy(x, "hello ");
 strcat(x, "world");
 gfx_drawstr(x);
```

This mode is useful if you need to build or load a table of strings.

* You can use # to get an instance of a temporary string:

```eel2
x = #;
 strcpy(x, "hello ");
 strcat(x, "world");
 gfx_drawstr(x);
```

Note that the scope of these temporary instances is very limited and unpredictable, and their initial values are undefined. 

* Finally, you can use named strings, which are the equivalent of normal variables:

```eel2
x = #myString;
 strcpy(x, "hello world");
```

The value of named strings is defined to be empty at script load, and to persist throughout the life of your script. There is also a shortcut to assign/append to named strings:

```eel2
#myString = "hello "; // same as strcpy(#myString, "hello ");
 #myString += "world"; // same as strcat(#myString, "world");
```

---

top **String functions***

* **strlen(str) -- returns length of string**

* **strcpy(str, srcstr) -- copies srcstr into str, returns str**

* **strcat(str, srcstr) -- appends srcstr to str, returns str**

* **strcmp(str, str2) -- compares str to str2, case sensitive, returns -1, 0, or 1**

* **stricmp(str, str2) -- compares str to str2, ignoring case, returns -1, 0, or 1**

* **strncmp(str, str2, maxlen) -- compares str to str2 up to maxlen bytes, case sensitive, returns -1, 0, or 1**

* **strnicmp(str, str2, maxlen) -- compares str to str2 up to maxlen bytes, ignoring case, returns -1, 0, or 1**

* **strncpy(str, srcstr, maxlen) -- copies srcstr into str, but stops after maxlen bytes. returns str**

* **strncat(str, srcstr, maxlen) -- appends srcstr to str, but stops after maxlen bytes of srcstr have been read. returns str**

* **strcpy_from(str,srcstr, offset) -- copies srcstr to str, starting offset bytes into srcstr. returns str.**

* **strcpy_substr(str,srcstr, offset, maxlen) -- copies srcstr to str, starting offset bytes into srcstr, and up to maxlen bytes. if offset is less than 0, offset is from end of source string. If maxlen is less than 0, length is limited to output string length shortened by maxlen. returns str.**

* **str_getchar(str, offset[, type]) -- returns the data at byte-offset offset of str. if offset is negative, position is relative to end of string. Type defaults to signed char, but can be specified to read raw binary data in other formats (note the single quotes, these are single/multi-byte characters):**
* 'c' - signed char

* 'cu' - unsigned char

* 's' - signed short

* 'S' - signed short, big endian

* 'su' - unsigned short

* 'Su' - unsigned short, big endian

* 'i' - signed int

* 'I' - signed int, big endian

* 'iu' - unsigned int

* 'Iu' - unsigned int, big endian

* 'f' - float

* 'F' - float, big endian

* 'd' - double

* 'D' - double, big endian

* **str_setchar(str, offset, value[, type]) -- sets the value at byte-offset "offset" of str to value (which may be one or more bytes of data). If offset is negative, then offset is relative to end of the string. If offset is the length of the string, or between (-0.5,0.0), then the character (or multibyte value if type is specified) will be appended to the string.**

* **sprintf(str,format, ...) -- copies format to str, converting format strings:**
* %% = %
 
* %s = string from parameter
 
* %d = parameter as integer
 
* %i = parameter as integer
 
* %u = parameter as unsigned integer
 
* %x = parameter as hex (lowercase) integer
 
* %X = parameter as hex (uppercase) integer
 
* %c = parameter as character
 
* %f = parameter as floating point
 
* %e = parameter as floating point (scientific notation, lowercase)
 
* %E = parameter as floating point (scientific notation, uppercase)
 
* %g = parameter as floating point (shortest representation, lowercase)
 
* %G = parameter as floating point (shortest representation, uppercase)

Many standard C printf() modifiers can be used, including:
* %.10s = string, but only print up to 10 characters
 
* %-10s = string, left justified to 10 characters
 
* %10s = string, right justified to 10 characters
 
* %+f = floating point, always show sign
 
* %.4f = floating point, minimum of 4 digits after decimal point
 
* %10d = integer, minimum of 10 digits (space padded)
 
* %010f = integer, minimum of 10 digits (zero padded)

Values for format specifiers can be specified as additional parameters to sprintf, or within {} in the format specifier (such as %{varname}d, in that case a global variable is always used).

* **match(needle, haystack, ...) -- search for needle in haystack**
 **matchi(needle, haystack, ...) -- search for needle in haystack (case insensitive)***

For these you can use simplified regex-style wildcards:
* * = match 0 or more characters
 
* *? = match 0 or more characters, lazy
 
* + = match 1 or more characters
 
* +? = match 1 or more characters, lazy
 
* ? = match one character

Examples:

```eel2
match("*blah*", "this string has the word blah in it") == 1
 match("*blah", "this string ends with the word blah") == 1
```

You can also use format specifiers to match certain types of data, and optionally put that into a variable:
* %s means 1 or more chars
 
* %0s means 0 or more chars
 
* %5s means exactly 5 chars
 
* %5-s means 5 or more chars
 
* %-10s means 1-10 chars
 
* %3-5s means 3-5 chars. 
 
* %0-5s means 0-5 chars. 
 
* %x, %d, %u, and %f are available for use similarly
 
* %c can be used, but can't take any length modifiers
 
* Use uppercase (%S, %D, etc) for lazy matching
 
The variables can be specified as additional parameters to match(), or directly within {} inside the format tag (in this case the variable will always be a global variable):
 

```eel2
match("*%4d*","some four digit value is 8000, I say",blah)==1 && blah == 8000
 match("*%4{blah}d*","some four digit value is 8000, I say")==1 && blah == 8000
```

---

top **User defined functions and namespace pseudo-objects***

EEL2 supports user defined functions, as well as some basic object style data access.

Functions can be defined anywhere in top level code (i.e. not within an existing () block, but before or after existing code). Functions are not able to be called recursively -- this is enforced by functions only being able to call functions that are declared before the current function, and functions not being able to call themselves. Functions may have 0 to 40 parameters. To define a function, use the following syntax: 

```eel2
function getSampleRate()
 (
 srate; // return srate
 );

 function mySine(x)
 (
 // taylor approximation
 x - (x^3)/(3*2) + (x^5)/(5*4*3*2) - (x^7)/(7*6*5*4*3*2) + (x^9)/(9*8*7*6*5*4*3*2);
 );

 function calculateSomething(x y)
 (
 x += mySine(y);
 x/y;
 );
```

Which would then be callable from other code, such as:

```eel2
y = mySine($pi * 18000 / getSampleRate());
 z = calculateSomething(1,2);
```

Note that the parameters for functions are private to the function, and will not affect global variables. If you need more private variables for a function, you can declare additional variables using a local() statement between the function declaration and the body of the function. Variables declared in the local() statement will be local to that function, and persist across calls of the function. Example:

```eel2
function mySine(x) local(lastreq lastvalue)
 (
 lastreq != x ? (
 lastreq = x; // save last input
 // taylor approximation
 lastvalue = x - (x^3)/(3*2) + (x^5)/(5*4*3*2) - (x^7)/(7*6*5*4*3*2) + (x^9)/(9*8*7*6*5*4*3*2);
 );
 lastvalue; // result of function is cached value
 );
```

In the above example, mySine() will cache the last value used and not perform the calculation if the cached value is available. Note that the local variables are initialized to 0, which happens to work for this demonstration but if it was myCosine(), additional logic would be needed.

EEL2 also supports relative namespaces on global variables, allowing for pseudo object style programming. Accessing the relative namespace is accomplished either by using a "this." prefix for variable/function names, or by using the instance() declaration in the function definition for variable names: 

```eel2
function set_foo(x) instance(foo)
 (
 foo = x;
 );
 // or
 function set_foo(x)
 (
 this.foo = x;
 );

 whatever.set_foo(32); // whatever.foo = 32;
 set_foo(32); // set_foo.foo = 32;

 function test2()
 (
 this.set_foo(32);
 );
 whatever.test2(); // whatever.foo = 32
```

Additionally functions can use the "this.." prefix for navigating up the namespace hierarchy, such as:

```eel2
function set_par_foo(x) 
 (
 this..foo = x;
 );
 a.set_par_foo(1); // sets foo (global) to 1
 a.b.set_par_foo(1); // sets a.foo to 1
```

---

top **Advanced Functions***

 **FFT/MDCT***

 *Not available in all implementations, but common*
* **mdct(start_index, size), imdct(start_index, size)**
 
Example:

```eel2
mdct(0, 512);
```

 
 Performs a modified DCT (or inverse in the case of imdct()) on the data
 in the local memory buffer at the offset specified by the first parameter.
 The second parameter controls the size of the MDCT, and it MUST be one of
 the following: 64, 128, 256, 512, 1024, 2048, or 4096. The MDCT takes the number of
 inputs provided, and replaces the first half of them with the results. The
 IMDCT takes size/2 inputs, and gives size results.

 
 Note that the MDCT must NOT cross a 65,536 item boundary, so be sure to
 specify the offset accordingly.

 
 The MDCT/IMDCT provided also provide windowing, so your code is not required
 to window the overlapped results, but simply add them. See the example
 effects for more information.

* **fft(start_index, size), ifft(start_index, size)**
 **fft_real(start_index, size), ifft_real(start_index, size)***
 **fft_permute(index,size), fft_ipermute(index,size)***
 
 Example:

```eel2
buffer=0;
 fft(buffer, 512);
 fft_permute(buffer, 512);
 buffer[32]=0;
 fft_ipermute(buffer, 512);
 ifft(buffer, 512);
 // need to scale output by 1/512.0, too.
```

 
 Performs a FFT (or inverse in the case of ifft()) on the data in the local
 memory buffer at the offset specified by the first parameter.
 The size of the FFT is specified by the second parameter, which must be
 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, or 32768. The outputs 
 are permuted, so if you plan to use them in-order, call **fft_permute(buffer, size) ***
 before and **fft_ipermute(buffer,size) after your in-order use.***
 Your inputs or outputs will need to be scaled down by 1/size, if used.
 

 
 Note that the FFT/IFFT require real/imaginary input pairs (so a
 256 point FFT actually works with 512 items).
 

 
 Note that the FFT/IFFT must NOT cross a 65,536 item boundary, so be sure to
 specify the offset accordingly.
 

 
 The fft_real()/ifft_real() variants operate on a set of size real inputs, and produce size/2 complex
 outputs. The first output pair is DC,nyquist. Normally this is used with fft_permute(buffer,size/2).

* **convolve_c(dest,src,size)**
 
 Used to convolve two buffers, typically after FFTing them.
 convolve_c works with complex numbers. The sizes specify number 
 of items (the number of complex number pairs).
 

 
 Note that the convolution must NOT cross a 65,536 item boundary, 
 so be sure to specify the offset accordingly.
 **Memory Utility***
* **freembuf(top)**
 
 The freembuf() function provides a facility for you to notify the memory
 manager that you are no longer using a portion of the local memory buffer.
 

 
 For example, if the user changed a parameter on your effect halving your
 memory requirements, you should use the lowest indices possible, and call
 this function with the highest index you are using plus 1, i.e. if you are
 using 128,000 items, you should call freembuf(128001); If you are no longer
 using any memory, you should call freembuf(0);
 

 
 Note that calling this does not guarantee that the memory is freed or
 cleared, it just provides a hint that it is OK to free it.

* **memcpy(dest,source,length)**
 
 The memcpy() function provides the ability to quickly copy regions of the
 local memory buffer. If the buffers overlap and either buffer crosses a 65,536 item boundary, the 
 results may be undefined.
 

* **memset(dest,value,length)**
 
 The memset() function provides the ability to quickly set a region of the
 local memory buffer to a particular value. 
 

* **mem_multiply_sum(buf1,buf2,length)**
 
 Sums the products of length items of buf1 and buf2. If buf2 is exactly -1, then sums the squares of items in buf1. If buf2 is exactly -2 then sums the absolute values of buf1. If buf2 is exactly -3 then sums the values of buf1. If buf2 is another negative value, the result is undefined.
 

* **mem_insert_shuffle(buf,len,value)**
 
 Shuffles buf to the right by one element, inserting value as buf[0], and returning the previous buf[len-1].
 

* **__memtop() -- returns the maximum memory words available to the script (read/writes to __memtop()[-1] will succeed, but __memtop()[0] will not)**

 **Stack***

A small (approximately 4096 item) user stack is available for use in code:

* **stack_push(value)**

 Pushes value onto the user stack, returns a reference to the value.
 

* **stack_pop(value)**

 Pops a value from the user stack into value, or into a temporary buffer if value is not specified, and returns a reference to where the stack was popped. Note that no checking is done to determine if the stack is empty, and as such stack_pop() will never fail.

* **stack_peek(index)**

 Returns a reference to the item on the top of the stack (if index is 0), or to the Nth item on the stack if index is greater than 0.
 

* **stack_exch(value)**

 Exchanges a value with the top of the stack, and returns a reference to the parameter (with the new value).
 

Copyright © 2004-2026 
Cockos Incorporated