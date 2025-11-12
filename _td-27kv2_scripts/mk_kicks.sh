#!/usr/bin/env bash
set -euo pipefail

# Require bash >= 4.3 for declare -n and namerefs
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
  echo "This script requires bash >= 4.3" >&2
  exit 1
fi

. utils.sh

rm -rf triggers/*/kicks/ triggers/*/kd*.sfzh

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
			t="triggers/$beater/kicks/${kick}_snare_${snare}.sfzh"
			rm -f "$t"
			max_duration=0
			for mishit in '' 'x'
			do
				if [ "$mishit" == "x" ]
				then
					# Skip if mishit - messes up trigger counts
					continue
				fi
				for pos in cls opn
				do
					for rr in '' a b
					do
						f="kit_pieces/kicks/${kick}_snare_${snare}_${pos}$([[ -z $rr ]] && echo '' || echo '_'$rr)$([[ -z $mishit ]] && echo '' || echo '_'$mishit).sfzh"
						[[ -f "$f" ]] || continue
						trigger="${kick}_$pos$([[ -z $mishit ]] && echo '' || echo '_'$mishit)"
						[[ -v keys[$trigger] ]] || {
							keys[$trigger]=1
							[[ -v keys[keys] ]] \
								&& keys[keys]="${keys[keys]} $trigger" \
								|| keys[keys]="$trigger"
						}
						get_durations $f max_duration
[[ -f "$t" ]] || echo >&2 "$t"
						{
						echo "<group> key=\$$trigger group_label=$trigger"
						[[ "$rr" == "a" ]] && echo " lorand=0.00 hirand=0.50"
						[[ "$rr" == "b" ]] && echo " lorand=0.50 hirand=1.00"
						echo "#include \"$f\""
						} >> "$t"
					done
				done
			done

			if [[ "${#keys[@]}" -gt 0 ]]
			then
				t="triggers/$beater/${kick}_snare_${snare}.sfzh"
				rm -f $t
				{
					# echo "// Max duration $max_duration"
					# Start at MIDI note 001 for each kick -- mk_kits.sh overrides these; mk_sfz.sh does not
					i=1
					for key in $(echo ${keys[keys]})
					do
						printf '#define $%s %03d\n' ${key} $i
						(( i += 1 ))
					done
					echo ""
					echo "#include \"triggers/$beater/kicks/${kick}_snare_${snare}.sfzh\""
				} > $t
			fi
			# } - do snare
		done
		# } - do kick
	done
	# } - do beater
done
