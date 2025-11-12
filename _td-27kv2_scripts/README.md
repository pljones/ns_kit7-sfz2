First, we need the "true peak" levels of each sample (not RMS or whatever I got from VelLeveler originally).

In `..`, link `_samples` to wherever the samples live.

Get `sox` installed and run the following in `..`:
```bash
find _samples/ -type f -name \*.wav | sort | while read f
do
    echo $f $(sox $f -n stats 2>&1 | grep '^Pk lev')
done | while read f x x x pk y
do
    echo $pk ${f#_samples/}
done > ns_kits7-all_samples-db.txt
```

Next, the `to_ranges.sh` script needs running against these raw values (again, with `..` as cwd):
```bash
{
    grep '_[0-9][0-9][0-9]\.wav$' ns_kits7-all_samples-db.txt | grep -v _misc/    | ./_td-27kv2_scripts/to_ranges.sh;
    for x in a b c;
    do
        grep '_'$x'[0-9][0-9][0-9]\.wav$' ns_kits7-all_samples-db.txt | grep -v _misc/ | ./_td-27kv2_scripts/to_ranges.sh | sed -e 's!^[^;]*;[^;]*; !&'$x'_!';
    done;
    for x in p r x;
    do
        grep '_[0-9][0-9][0-9]'$x'\.wav$' ns_kits7-all_samples-db.txt | grep -v _misc/    | ./_td-27kv2_scripts/to_ranges.sh | sed -e 's!^[^;]*;[^;]*; !&'$x'_!';
    done;
} > ns_kits7-all_samples-db_ranges.txt
```

Then run `to_velocity.sh` (here) to create `kit_pieces` from scratch:
```
./to_velocity.sh ../ns_kits7-all_samples-db_ranges.txt ../ns_kits7-all_samples-db.txt
```

Once the kit pieces are there (in fact, once the ranges are there), `mk_kits.sh` can have the
"mic group" levels set.  This is a manual process... and it's still evolving...

Each mic group is checked by running a command like this:
```bash
grep 'cymbals/' ns_kits7-all_samples-db_ranges.txt | sort -t\; -k1n | grep stx/ | grep 'cy12\|cy19c\|cy20'
```
I get
```
-0.67; -47.66; cymbals/cy20ride/stx/ord/cy20ride_stx_ord; 033.wav 001.wav
```
`-0.67` means the peak channel maximum level for that set of cymbals is nearly hitting 0dB.

For reference, the two loudest samples I can see are
```
-0.00; -15.11; percussion/pn9tambourine/hnd/hit/pn9tambourine_hnd_hit; 031.wav 001.wav
0.00; -17.94; snares/sn12tight/stx/snare_on/rms/sn12tight_stxr_rms; 023.wav 001.wav
```
| Beater | Loudest hit |
+ -- + -- +
| brs | `-12.32; -43.39; cymbals/cy12splash/brs/grb/cy12splash_brs_grb; 012.wav 001.wav` |
| hnd* | `-12.85; -38.53; snares/sn10jungle/hnd/snare_off/slp/sn10jungle_hndr_slp; 023.wav 001.wav` |
| mlt | `-1.82; -42.38; cymbals/cy18crash/mlt/grb/cy18crash_mlt_grb; 010.wav 001.wav` |
| stx | `0.00; -17.94; snares/sn12tight/stx/snare_on/rms/sn12tight_stxr_rms; 023.wav 001.wav` |

(hnd* -- ignoring the tambourine)
