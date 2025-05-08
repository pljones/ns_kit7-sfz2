#!/bin/bash

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

declare -A keys

for beater in brs hnd mlt stx
do
	rm -rf triggers/$beater/percussion pn*_*.inc
done

percussion=cowbell
p=pn8_cowbell
for beater in brs hnd mlt stx
do
	# {
	for articulation in '' muted open
	do
		# {

		keys=()
		t=triggers/$beater/percussion/${p}$([[ -z "$articulation" ]] || echo "_$articulation").inc
		rm -f $t
		max_duration=0

		for position in ord top
		do
			f="kit_pieces/percussion/cowbell_pn8_${beater}$([[ -z "$articulation" ]] || echo "_$articulation")_$position.sfz"
			[[ -f "$f" ]] || continue
[[ ! -f $t ]] && echo >&2 "$t"
			mkdir -p triggers/$beater/percussion
			max_duration=$(get_durations $max_duration $f)

			trigger="\$${percussion}_${position}"
			[[ -v keys[$trigger] ]] || keys[$trigger]=1
			{
				echo "<group>"
				echo " key=$trigger"
				echo "#include \"$f\""
			} >> $t
		done

		if [[ ${#keys[@]} -gt 0 ]]
		then
			t="triggers/$beater/${p}$([[ -z "$articulation" ]] || echo "_$articulation").inc"
			{
				echo "// Max duration $max_duration"
				i=1
				for key in "${!keys[@]}"
				do
					printf '#define %s %03d\n' ${key} $i
					(( i += 1 ))
				done | sort -k2,2n
				echo ""
				echo "#include \"triggers/$beater/percussion/${p}$([[ -z "$articulation" ]] || echo "_$articulation").inc\""
			} > $t
		fi
		# } - articulation
	done
	# } - beater
done

percussion=tambourine
p=pn9_tambourine
for beater in brs hnd mlt stx
do
	# {
	t="triggers/$beater/percussion/${p}.inc"
	rm -f $t
	max_duration=0

	keys=()
	for articulation in hit jng rol thm
	do
		# {

		for hand in '' l r
		do
			f="kit_pieces/percussion/tambourine_pn9_${beater}_${articulation}$([[ -z "$hand" ]] || echo "_$hand").sfz"
			[[ -f "$f" ]] || continue
[[ ! -f $t ]] && echo >&2 "$t"
			mkdir -p triggers/$beater/percussion
			max_duration=$(get_durations $max_duration $f)

			trigger="\$${percussion}_${articulation}$([[ -z "$hand" ]] || echo "_$hand")"
			[[ -v keys[$trigger] ]] || keys[$trigger]=1
			{
				echo "<group>"
				echo " key=$trigger"
				echo "#include \"$f\""
			} >> $t
		done

		# } - articulation
	done

	if [[ ${#keys[@]} -gt 0 ]]
	then
		t="triggers/$beater/${p}.inc"
[[ ! -f $t ]] && echo >&2 "$t"
		rm -f $t
		{
			echo "// Max duration $max_duration"
			i=1
			for key in "${!keys[@]}"
			do
				printf '#define %s %03d\n' ${key} $i
				(( i += 1 ))
			done | sort -k2,2n
			echo ""
			echo "#include \"triggers/$beater/percussion/${p}.inc\""
		} > $t
	fi

	# } - beater
done
