#!/bin/bash
#
# Sourced into the other mk_XX.sh scripts

declare -A sample_durations
while read sample duration
do
	sample_durations[$sample]=$duration
done < ../ns_kits7-all_samples-duration.txt

function get_durations () {
	local sfz_file=$1   ; shift || { echo "Missing sfz_file"    >&2; exit 1; }
	local -n _max_ref=$1; shift || { echo "Missing _max_ref" >&2; exit 1; }
	[[ $# -eq 0 ]] || { echo "Unexpected trailing parameters: [$@]" >&2; exit 1; }

	local line sample duration
	while read line
	do
		sample=${line##*sample=../samples/}
		duration=${sample_durations[$sample]}
		(( $(awk 'BEGIN { print ('$duration' > '$_max_ref') }') )) && _max_ref=$duration || true
	done < <(grep 'sample=' "$sfz_file")
}
