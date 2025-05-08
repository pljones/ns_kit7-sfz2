#!/bin/bash -eu

function get_durations () {
	local current_max=$1; shift || { echo "Missing current_max" >&2; exit 1; }
	local sfz_file=$1   ; shift || { echo "Missing sfz_file"    >&2; exit 1; }

	local line x duration
	while read line
	do
		read x duration <<<$(echo $line)
		current_max=$(awk '{ print ( ( 0.0 + $1 ) > ( 0.0 + $2 ) ? $1 : $2 ) }' <<<"$duration $current_max")
	done < <(
		grep 'sample=' $sfz_file | sed -e 's!^.*sample=\.\./samples/!!' | while read sample
		do
			grep "^$sample " ../ns_kits7-all_samples-duration.txt
		done
	)
	echo $current_max
}

rm -rf triggers/*/kicks/ triggers/*/kd*.inc

declare -A keys
for beater in ped
do
	# {
	c=0
	mkdir -p triggers/$beater/kicks
	for kick in kd14_bop kd20_full kd20_punch kd22_boom kd22_noreso
	do
		# {
		for snare in off on
		do
			# {
			(( c+=1 ))
			keys=()
			t="triggers/$beater/kicks/${kick}_snare_${snare}.inc"
echo >&2 "$t"
			rm -f $t
			max_duration=0
			for mishit in '' 'x'
			do
				for pos in cls opn
				do
					for rr in '' a b
					do
						f="kit_pieces/kicks/${kick}_snare_${snare}_${pos}$([[ -z $rr ]] && echo '' || echo '_'$rr)$([[ -z $mishit ]] && echo '' || echo '_'$mishit).sfz"
						[[ -f "$f" ]] || continue
						trigger=\$"${kick}_$pos$([[ -z $mishit ]] && echo '' || echo '_'$mishit)"
						[[ -v keys[$trigger] ]] || {
							keys[$trigger]=1
							[[ -v keys[keys] ]] \
								&& keys[keys]="${keys[keys]} $trigger" \
								|| keys[keys]="$trigger"
						}
						max_duration=$(get_durations $max_duration $f)
						echo "<group>"
						echo " key=$trigger"
						[[ "$rr" == "a" ]] && echo " lorand=0.00 hirand=0.50"
						[[ "$rr" == "b" ]] && echo " lorand=0.50 hirand=1.00"
						echo "#include \"$f\""
					done
				done
			done > $t

			if [[ "${#keys[@]}" -gt 0 ]]
			then
				t="triggers/$beater/${kick}_snare_${snare}.inc"
				rm -f $t
				{
					echo "// Max duration $max_duration"
					i=1
					for key in $(echo ${keys[keys]})
					do
						printf '#define %s %03d\n' ${key} $i
						(( i += 1 ))
					done
					echo ""
					echo "#include \"triggers/$beater/kicks/${kick}_snare_${snare}.inc\""
				} > $t
			fi
			# } - do snare
		done
		# } - do kick
	done
	# } - do beater
done
