#!/bin/bash -eu

. utils.sh

declare -A tunings toms

tunings=([brs]="bop rock" [hnd]="bop rock" [mlt]="bop rock" [mlt]="bop rock" [stx]="bop dry noreso rock")
toms=(\
	[brs_bop_off]="    tm8 tm10 tm12 tm14 tm16"\
	[brs_rock_off]="   tm8 tm10 tm12 tm14 tm16"\
	[brs_rock_on]="    tm8 tm10 tm12 tm14 tm16"\
	[hnd_bop_off]="    tm8 tm10 tm12 tm14 tm16"\
	[hnd_bop_on]="              tm12 tm14"\
	[hnd_rock_off]="   tm8 tm10 tm12 tm14 tm16"\
	[hnd_rock_on]="    tm8 tm10 tm12 tm14 tm16"\
	[mlt_bop_off]="    tm8 tm10 tm12 tm14 tm16"\
	[mlt_bop_on]="              tm12 tm14 tm16"\
	[mlt_rock_off]="   tm8 tm10 tm12 tm14 tm16"\
	[mlt_rock_on]="    tm8 tm10 tm12 tm14 tm16"\
	[stx_bop_off]="    tm8 tm10 tm12 tm14 tm16"\
	[stx_bop_on]="              tm12 tm14 tm16"\
	[stx_dry_off]="        tm10 tm12 tm14     "\
	[stx_dry_on]="         tm10 tm12 tm14     "\
	[stx_noreso_off]="     tm10 tm12 tm14     "\
	[stx_rock_off]="   tm8 tm10 tm12 tm14 tm16"\
	[stx_rock_on]="    tm8 tm10 tm12 tm14 tm16"\
)

articulations=(ord rim rms)
declare -A is_handed
is_handed=([ord]=1 [rms]=1)

declare -A keys

function do_articulation () {
	local beater=$1;       shift || { echo "Missing beater"       >&2; exit 1; }
	local tuning=$1;       shift || { echo "Missing tuning"       >&2; exit 1; }
	local snare=$1;        shift || { echo "Missing snare"        >&2; exit 1; }
	local tom=$1;          shift || { echo "Missing tom"          >&2; exit 1; }
	local articulation=$1; shift || { echo "Missing articulation" >&2; exit 1; }
	local hand=$1;         shift || { echo "Missing hand"         >&2; exit 1; }

	key="\$${tom}_${articulation}"
	file="kit_pieces/toms/${tom}_${tuning}_${beater}_snare_${snare}_${articulation}"
	[[ -z "$hand" ]] || {
		key="${key}_${hand}"
		file="${file}_${hand}"
	}
	file="${file}.sfzh"
	[[ -f $file ]] || file=${file/_rim/_ord_r}
	[[ -f $file ]] || file=${file/_rms/_ord}
	[[ -f $file ]] || { echo "${tom}_${tuning}_${beater}_snare_${snare}_${articulation} / hand {$hand} - file {$file} not found" >&2; exit 1; }
	get_durations $file max_duration

	[[ -v keys[$key] ]] || { keys[$key]=1; [[ -v keys[keys] ]] && keys[keys]="${keys[keys]} $key" || keys[keys]=$key; }
	echo "<group>"
	echo " key=$key"
	echo "#include \"$file\""
}

for beater in ${!tunings[@]}
do
	# {
	for tuning in $(echo ${tunings[$beater]})
	do
		# {
		for snare in off on
		do
			# {
			[[ -v toms[${beater}_${tuning}_${snare}] ]] || continue
			for tom in $(echo ${toms[${beater}_${tuning}_${snare}]})
			do
				# {

				mkdir -p triggers/$beater/toms
				t="${tom}_${tuning}_snare_${snare}.sfzh"
				rm -f triggers/$beater/toms/$t
				rm -f triggers/$beater/$t
				max_duration=0
echo >&2 triggers/$beater/toms/$t

				keys=()
				for articulation in ${articulations[@]}
				do
					# {
					if [[ -v is_handed[$articulation] ]]
					then
						do_articulation $beater $tuning $snare $tom $articulation l
						do_articulation $beater $tuning $snare $tom $articulation r
					else
						do_articulation $beater $tuning $snare $tom $articulation ''
					fi
					# } - articulation
				done > triggers/$beater/toms/$t

				{
					# echo "// Max duration $max_duration"
					# Start at MIDI note 001 for each tom - mk_kits.sh overrides these; mk_sfz.sh does not
					i=1
					for key in $(echo ${keys[keys]})
					do
						printf '#define %s %03d\n' ${key} $i
						(( i += 1 ))
					done | sort -k2,2n
					echo ""
					echo "#include \"triggers/$beater/toms/$t\""
				} > triggers/$beater/$t

				# } - tom
			done
			# } - snare
		done
		# } - tuning
	done
	# } - beater
done
