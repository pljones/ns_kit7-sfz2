#!/usr/bin/env bash
set -euo pipefail

# Require bash >= 4.3 for declare -n and namerefs
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
  echo "This script requires bash >= 4.3" >&2
  exit 1
fi

. utils.sh

declare -A keys

for beater in brs hnd mlt stx
do
	rm -rf triggers/$beater/percussion pn*_*.sfzh
done

percussion=cowbell
p=pn8_cowbell
for beater in brs hnd mlt stx
do
	# {
	keys=()
	t=triggers/$beater/percussion/${p}.sfzh
	rm -f $t
	max_duration=0

	for articulation in muted open
	do
		# {
		for position in ord top
		do
			# {

			f="kit_pieces/percussion/cowbell_pn8_${beater}"
			if [[ -f "${f}_${articulation}_${position}.sfzh" ]]
			then
				f="${f}_${articulation}_${position}.sfzh"
			elif [[ -f "${f}_${articulation}_ord.sfzh" ]]
			then
				f="${f}_${articulation}_ord.sfzh"
			elif [[ -f "${f}_${position}.sfzh" ]]
			then
				f="${f}_${position}.sfzh"
			else
				f="${f}_ord.sfzh"
			fi
			[[ -f "${f}" ]] || continue

			mkdir -p "triggers/$beater/percussion"
			get_durations "$f" max_duration

			trigger="${percussion}_${articulation}_${position}"
			[[ -v keys[$trigger] ]] || { keys[$trigger]=1; [[ -v keys[keys] ]] && keys[keys]="${keys[keys]} ${trigger}" || keys[keys]="${trigger}"; }
[[ ! -f $t ]] && echo >&2 "$t"
			{
				echo "<group> key=\$$trigger group_label=$trigger"
				echo "#include \"$f\""
				echo ""
			} >> $t

			# } position
		done

		if [[ -v keys[keys] ]]
		then
			{
				# echo "// Max duration $max_duration"
				# Start at MIDI note 001 for each percussion piece -- mk_kits.sh overrides these; mk_sfz.sh does not
				i=1
				for key in $(echo ${keys[keys]})
				do
					printf '#define $%s %03d\n' ${key} $i
					(( i += 1 ))
				done
				echo ""
				echo "#include \"triggers/$beater/percussion/${p}.sfzh\""
			} > "triggers/$beater/${p}.sfzh"
		fi
		# } - articulation
	done
	# } - beater
done

function do_rr () {
	local trigger=$1;    shift || { echo "do_rr: Missing trigger" >&2; exit 1; }
	local f=$1;          shift || { echo "do_rr: Missing filename" >&2; exit 1; }
	local lo_rr=$1;      shift || { echo "do_rr: Missing lo_rr" >&2; exit 1; }
	local hi_rr=$1;      shift || { echo "do_rr: Missing lo_rr" >&2; exit 1; }
	local -n max_ref=$1; shift || { echo "do_rr: Missing max_duration reference" >&2; exit 1; }

	[[ -f "$f" ]] || { echo "do_rr: Invalid filename {$f}" >&2; exit 1; }

	[[ $articulation == rol ]] || get_durations $f max_ref

	echo "<group> key=\$$trigger group_label=$trigger"
	[[ "$lo_rr" == '' && "$hi_rr" == '' ]] || echo " lorand=${lo_rr} hirand=${hi_rr}"
	echo "#include \"$f\""
}

percussion=tambourine
p=pn9_tambourine
for beater in hnd
do
	# {
	keys=()
	t="triggers/$beater/percussion/${p}.sfzh"
	rm -f $t
	max_duration=0

	mkdir -p triggers/$beater/percussion

	for articulation in hit jng rol thm
	do
		# {

		trigger="${percussion}_${articulation}"
		[[ -v keys[$trigger] ]] || { keys[$trigger]=1; [[ -v keys[keys] ]] && keys[keys]="${keys[keys]} ${trigger}" || keys[keys]="${trigger}"; }
[[ ! -f $t ]] && echo >&2 "$t"
		f="kit_pieces/percussion/tambourine_pn9_${beater}_${articulation}"
		if [[ $articulation == jng ]]
		then
			do_rr "${trigger}" "${f}_l.sfzh" 0.0 0.5 max_duration >> $t
			do_rr "${trigger}" "${f}_r.sfzh" 0.5 1.0 max_duration >> $t
		else
			do_rr "${trigger}" "${f}.sfzh"   ''  ''  max_duration >> $t
		fi

		# } - articulation
	done

	if [[ -v keys[keys] ]]
	then
		{
			# echo "// Max duration $max_duration"
			# Start at MIDI note 001 for each percussion piece -- mk_kits.sh overrides these; mk_sfz.sh does not
			i=1
			for key in $(echo ${keys[keys]})
			do
				printf '#define $%s %03d\n' ${key} $i
				(( i += 1 ))
			done
			echo ""
			echo "#include \"triggers/$beater/percussion/${p}.sfzh\""
		} > "triggers/$beater/${p}.sfzh"
	fi

	# } - beater
done
