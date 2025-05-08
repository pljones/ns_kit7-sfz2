#!/bin/bash
# stdin  - lines containing "dB path"
# stdout - lines containing "hi_dB; lo_dB; base_path; hi_num.wav lo_num.wav"
#
# where
#   "dB"     is a negative decimal
#   "path"   is a sample path with instrument, size, tuning, beater (except kick; pedal/splashed hi-hats spuriously), openness, snare wire (when present), articulation, (kick) random robin, brush stroke, mishit - and a sequence number
#
#   "num_part" is "(kick) random robin, brush stroke, mishit" (which, fortunately, are mutually exclusive) and sequence number
#
#   "hi_dB"      is the highest "dB" for a group of samples
#   "lo_dB"      is the lowest "dB" for a group of samples
#   "base_path"  is the part of the "path" with "num_part" removed and is used as a grouping condition
#   "hi_num.wav" is the part of "path" for the last "path" in the group
#   "lo_num.wav" is the part of "path" for the first "path" in the group
#
# It's not perfect and needs the "(kick) random robin, brush stroke, mishit" and "_misc" handled with care, like this:
# {
#   grep '_[0-9][0-9][0-9]\.wav$' ns_kits7-all_samples-db.txt | grep -v _misc/  | ./_td-27kv2_scripts/to_ranges.sh;
#   for x in a b c;
#   do
#     grep '_'$x'[0-9][0-9][0-9]\.wav$' ns_kits7-all_samples-db.txt | grep -v _misc/ | ./_td-27kv2_scripts/to_ranges.sh | sed -e 's!^[^;]*;[^;]*; !&'$x'_!';
#   done;
#   for x in p r x;
#   do
#     grep '_[0-9][0-9][0-9]'$x'\.wav$' ns_kits7-all_samples-db.txt | grep -v _misc/  | ./_td-27kv2_scripts/to_ranges.sh | sed -e 's!^[^;]*;[^;]*; !&'$x'_!';
#   done;
# } > ns_kits7-all_samples-db_ranges.txt
# TODO: actually process _misc
#

sed -e 's/^ * //g' -e 's/_\([abc]*[0-9]*[prx]*.wav\)$/ \1/' | sort -b -k2,2 -k1nr | { 
	dl=""
	gl=""
	sl=""
	while read d g s
	do
		[[ "$g" != "$gl" ]] && {
			echo "--1: dl $dl; gl $gl; sl $sl"
			echo ''
			echo "--2: d  $d; g  $g; s  $s"
			dl="$d"; gl="$g"
		}
		dl="$d"
		sl="$s"
	done
	echo "--3: dl $dl; gl $gl; sl $sl"
} | grep 'wav$' | while read x x d_hi x ga x n_hi; read x x d_lo x gb x n_lo
do
	[[ "$ga" == "$gb" ]] || {
		echo "Error: $gb should be $ga!" >&2
		break
	}
	echo $d_hi $d_lo $ga $n_hi $n_lo
done |\
	sed -e 's!/! !g' -e 's/\(hh[^ ]*\) \([^ ]*\) \([^ ]\) /\1_\3 \2 /' |\
	sort -k5,5 -k3,4 -k6,12 -k1,2h |\
	sed -e 's/\(hh[^_ ]*\)_\([^ ]\) \([^ ]*\) /\1 \3 \2 /' -e 's! !/!g' -e 's!;/!; !g' -e 's!wav/!wav !'

