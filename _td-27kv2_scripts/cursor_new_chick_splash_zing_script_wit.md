# New Chick/Splash/Zing script with slider
_Exported on 07/02/2026 at 16:01:08 GMT from Cursor (2.4.28)_

---

**User**

OK, looking back at @_td-27kv2_scripts/cursor_patch_to_claude.md  and taking a similar approach to the coding as the current version, can you come up with a new script that implements the Chick/Splash/Zing model.  Add a slider for the Zing note with number 98 as default.

---

**Cursor**


Reading the referenced files to understand the approach and current implementation.



Checking MegaDrum/hi-hat logic and how the project handles similar note mapping:



Checking JSFX MIDI note emission (Note On/Off) and sample-accurate timing:



Creating the plan:


---

**User**

Chick will sound on close.  Splash will sound on fast release.  This is a change to the existing approach.  (We can let the chick always sound -- the splash can suppress it in the sample mapping).

---

**Cursor**


Updating the plan to reflect Chick-on-close and Splash-on-fast-release. Reading the plan file and applying the update.



Updating the plan to reflect Chick-on-close and Splash-on-fast-release.



Adding a note about resetting release state when closing:



Updated the plan to match your new model. Summary:

**Changes**

1. **Chick** – Always pass through. The Chick note is forwarded as-is on close, with no conversion logic.

2. **Splash** – Triggered only on fast release. The script generates a Splash note when CC4 opens quickly (CC4 toward open, short release time). The sample/SFZ mapping can suppress the Chick when Splash fires.

3. **Sliders** – Use `zingNote` (default 98) for the Splash articulation and remove `splashNote` and `chickHeld`.

4. **Logic** – Chick is a simple pass-through. Splash is generated from release tracking in the CC4 branch. Chick and Splash no longer share velocity/press-duration logic.

5. **Release handling** – When closing (CC4 toward closed), reset `release_start_*` and `splash_sent` so the next release can trigger Splash again.

The plan file is updated and ready for implementation.

---

**User**

It doesn't cover Zing now.  That should happen if Splash doesn't.  It should happen only if the pedal is released fast.  The velocity will depend on the speed of release and the depth below chick level from which the release happens.

---

**Cursor**


Updating the plan to reintroduce Zing as a distinct articulation.



Adding a note about the chick-level tolerance:



Updated the plan to include Splash and Zing as separate articulations. Summary:

**Model**

- **Chick**: Always passes through on close.
- **Splash**: Fast release from chick level (cymbal touch). Takes priority.
- **Zing**: Fast release from below chick level, only when Splash is not triggered.

Both Splash and Zing require a fast release. The split is based on where the release starts relative to `chickLevel`:
- eKit (closed=127): Splash when `release_start_value >= chickLevel`, Zing otherwise.
- Keyboard (closed=0): Splash when `release_start_value <= chickLevel`, Zing otherwise.

**Zing velocity**

- Depends on:
  - **Release speed** – `release_delta / release_duration_ms`
  - **Depth below chick** – how much more closed than chick level (e.g. `chickLevel - release_start_value` for eKit)
- Use both in the velocity formula, then scale with minVel/maxVel/curve.

**Sliders**

- `splashNote` (97), `zingNote` (98)
- `chickLevel` – CC4 at cymbal touch (e.g. 100 for eKit, 27 for Keyboard)
- `fastReleaseMs` – max release duration for “fast release”

---

**User**

Splash/Zing need a switch over time thresshold.  Below, it's a splash, above it's a Zing

---

**Cursor**


Updating the plan to use a time threshold for Splash vs Zing.



The plan now uses a time threshold for Splash vs Zing:

**Time-based switch:**
- **Splash**: Hold time **below** `splashZingTimeMs` (short hold before release)
- **Zing**: Hold time **above** `splashZingTimeMs` (longer hold before release)

Hold duration = time from last close (when CC4 crossed the gate) to release start. A new `splashZingTimeMs` slider (e.g. 200 ms default) controls this.

---

**User**

chickLevel - 80 for eKit, 0 for Keyboard

---

**Cursor**


Updated the plan: `chickLevel` defaults are 80 for eKit and 0 for Keyboard.

---

**User**

Oh, and Splash and Zinge should be sent only when CC4 opens more than the Chick close level.  If that wasn't already covered.

---

**Cursor**


Updated the plan: Splash and Zing are emitted only when CC4 has gone past chick level:

- **eKit** (closed = 127): `data2 < chickLevel`
- **Keyboard** (closed = 0): `data2 > chickLevel`

---

**User**

Implement the plan as specified, it is attached for your reference. Do NOT edit the plan file itself.

To-do's from the plan have already been created. Do not create them again. Mark them as in_progress as you work, starting with the first one. Don't stop until you have completed all the to-dos.

---

**Cursor**


Implementing the Chick/Splash/Zing script per the plan. Reading the current script and plan.



Creating the new script file.



Fixing the Splash/Zing velocity logic: removing the stray `raw_vel;` and correcting the Splash branch.



Confirming jsfx-lint passed (exit code 0). Checking for lint issues:



The Chick/Splash/Zing script is implemented at `_td-27kv2_scripts/jsfx/TD-27_hihat_chick_splash_zing.jsfx`. Summary:

**Implemented behavior**

1. **Chick** – Passes through the Chick note on close with no changes.

2. **Splash** – On fast release with short hold (hold < `splashZingTimeMs`): sends Splash note (97).

3. **Zing** – On fast release with long hold (hold ≥ `splashZingTimeMs`): sends Zing note (98).

4. **Gate** – Splash/Zing only when CC4 has opened past chick level (eKit: `data2 < chickLevel`; Keyboard: `data2 > chickLevel`).

5. **Velocities**  
   - Splash: release speed (CC4 change / duration)  
   - Zing: release speed × (1 + depth-below-chick factor)

**Sliders**
- chickNote (44), splashNote (97), zingNote (98)  
- closedSide, chickLevel (80)  
- fastReleaseMs (150), splashZingTimeMs (200)  
- minVel, maxVel, velSensitivity, curveType, zingDepthScale  
- Debug sliders for Chick vel, emitted note, and sample position  

**Timing**
- Sample-based clock, active only while tracking, 2 s timeout  
- CC4 gate: `abs(delta) >= 1`  
- `press_start_time` updated on close; `release_start_time` and `release_start_value` on first open  

`jsfx-lint` completed with exit code 0 and no errors. Load the script in REAPER to test with your TD-27.

---

**User**

I've made a minor change to reset the sample position when tracking expires.  Can you confirm this has no adverse effect?

---

**Cursor**


The change in the tracking expiry block is:

**Original:**
```eel
tracking_active && (total_samples - last_activity_samples > 2 * srate) ? tracking_active = 0;
```

**Current:**
```eel
tracking_active && (total_samples - last_activity_samples > 2 * srate) ? (
  tracking_active = 0;
  total_samples = 0;
  last_activity_samples;
);
```

**1. `total_samples = 0`** – This is fine. When tracking restarts, timing is relative (`event_samples - press_start_time`, etc.), and the clock simply restarts from zero. The timeout check still behaves correctly because `last_activity_samples` gets updated when new activity arrives.

**2. `last_activity_samples;`** – This is a no-op: it reads and discards the value. It likely intended `last_activity_samples = 0`; either way it doesn’t break anything.

**3. Possible adverse effect** – There is one corner case:

After expiry, `total_samples` is reset but `press_start_time` is not. If activity resumes with an **opening** (no new close first):

- `release_start_time` is set to a small value (around `0 + offset`)
- `press_start_time` is still the old pre-idle value
- `hold_duration_samples = release_start_time - press_start_time` can be negative
- `hold_duration_ms < splashZingTimeMs` becomes true
- That forces **Splash** even when the physical hold was long (Zing).

So: after a long idle, a fast open can be misclassified as Splash instead of Zing.

**Recommendation:** When tracking expires, also reset `press_start_time = 0`. Then the existing fallback `(press_start_time == 0 || hold_duration_samples > 2 * srate) ? hold_duration_ms = splashZingTimeMs + 1` will apply and treat it as Zing, which matches a “long hold” after idle.

---

**User**

OK, I set a rule -- only send the Splash or Zing when the pedal opens to the same position (or more) as the Chick.  Where is the Chick position stored and how is this implemented?

---

**Cursor**


In the current script it works like this:

**Where Chick position is stored**

- Chick position is the **`chickLevel`** slider (around line 13, slider5).
- It’s a fixed CC4 value (default 80 for eKit, 0 for Keyboard), not updated from Chick notes.
- It’s the CC4 value where the cymbals touch.

**How the rule is implemented**

The check is here (around lines 96–99):

```96:99:_td-27kv2_scripts/jsfx/TD-27_hihat_chick_splash_zing.jsfx
        // CC4 opened past chick level?
        past_chick = closedSide ? (data2 < chickLevel) : (data2 > chickLevel);

        (release_duration_ms < fastReleaseMs && release_delta >= 20 && !release_sent && past_chick) ? (
```

So Splash/Zing is only sent when `past_chick` is true:

- **eKit** (closed = 127): `data2 < chickLevel` → pedal must be more open than chick level.
- **Keyboard** (closed = 0): `data2 > chickLevel` → pedal must be more open than chick level.

For “same position or more open”, you’d use `<=` / `>=` instead of `<` / `>`:

- eKit: `data2 <= chickLevel`
- Keyboard: `data2 >= chickLevel`

---

**User**

No, it isn't a user input - it comes in via the MIDI CC4 stream.  It's the last CC4 before the Chick note on, always.

---

**Cursor**


Understood. The Chick position comes from MIDI, not from a slider.

**Chick position source**

The Chick position should be the last CC4 value before the Chick Note On – i.e. the CC4 value when the cymbals touch and the Chick fires. That is typically the CC4 event immediately before the Chick Note On in the stream.

**Implementation**

1. **Storage**  
   Add a variable, e.g. `chick_cc4`, and initialize it in `@init`.

2. **Update on Chick Note On**  
   In the Chick Note On branch, set it to `last_cc4_value`:

   ```eel
   chick_cc4 = last_cc4_value;
   ```

   `last_cc4_value` holds the most recent CC4 received, so it represents the pedal position when the Chick fires (given the CC4-before-Chick ordering).

3. **Use for Splash/Zing gate**  
   Replace the `chickLevel` comparison with `chick_cc4`:
   - eKit: `data2 <= chick_cc4` (same or more open)
   - Keyboard: `data2 >= chick_cc4` (same or more open)

4. **Initial / no Chick yet**  
   If no Chick has occurred yet, `chick_cc4` is undefined or stale. You can either skip Splash/Zing until the first Chick, or use a fallback (e.g. `chickLevel`) when `chick_cc4` has never been set.

5. **Zing velocity depth**  
   The Zing velocity “depth below chick” should use `chick_cc4` instead of `chickLevel` so it’s consistent with the gate logic.

---

**User**

The the pedal doesn't close whilst the script is running, no tracking should be needed?  Both Splash and Zing now depend on speed towards open of the pedal, right?

---

**Cursor**


Right now the script **does** need tracking.

**Current model**

- Splash vs Zing is decided by **hold duration**: how long the pedal was closed before release.
- That needs `press_start_time` (set when CC4 closes).
- So it needs tracking of the **close** to get `hold_duration = release_start_time - press_start_time`.

**If Splash and Zing both depend only on “speed towards open”**

If both articulations were driven only by **release speed** (and maybe how far open you go), then:

- You only need:
  - `release_start_time`, `release_start_value` (first opening CC4)
  - `release_delta`, `release_duration_ms` (from subsequent opening CC4s)
- You **do not** need `press_start_time` or any close tracking.

That would mean changing how Splash vs Zing are split, for example:

1. **Release speed bands**: Splash for very fast release, Zing for slower but still fast.
2. **Release depth**: Splash when released far open, Zing when released less far.
3. **Single articulation**: One note type on fast release, no Splash/Zing distinction.

If you adopt one of these, close tracking can be removed. If you keep hold duration as the split, close tracking is required.

---

**User**

We know that a CC4 will _always_ happen before the pedal closes, because it always happens before Chick.

