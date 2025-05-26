#!/bin/bash -eu

. utils.sh


### rework -- table unfinished: it does not work like this yet

# positions head rim xtk

# snareCC for inaccurately controlling anything else

# ???: head->ord, rim->rms, xtk->xtk
# brs: head->cls, xtk->opn, rim->sw? (with ? in four zones based on snareCC? or straight random?)


#     |------ sn10 ------|----------------------------- sn12 ----------------------------|------- sn14 ------|
#      jungle  | piccolo |           bop         |   dead  |  funk   | orleans |  tight  | metal   | rock    | trigger
#      off on  |   on    |     off        on     |    on   |   on    |   on    |   on    | off on  | off on  |
#                        | muted open muted open |         |         |         |         |

# brs
#                              cls        cls    |         |   cls   |         |         |         |         | head (snareCC?)
#                              opn        opn    |         |   cls   |         |         |         |         | rim
#                              rms        rms    |         |   cls   |         |         |         |         | xtk
#                              cls        swc    |         |   cls   |         |         |         |         | (head snareCC?)
#                              cls        swl    |         |   cls   |         |         |         |         | (head snareCC?)
#                              cls        sws    |         |   cls   |         |         |         |         | (head snareCC?)
#                              cls        swu    |         |   cls   |         |         |         |         | (head snareCC?)

# hnd
#      ord     |         |     ord        ord    |         |         |         |         |         |         | head
#      rms     |         |     ord        ord    |         |         |         |         |         |         | rim
#      slp     |         |     ord        ord    |         |         |         |         |         |         | xtk

# mlt
#              |         |     ord        ord    |         |         |         |         |         |         | head
#              |         |     ord        ord    |         |         |         |         |         |         | rim
#              |         |     ord        ord    |         |         |         |         |         |         | xtk

# stx
#      ord ord |  ord    |  ord  ord   ord  ord  |         |         |         |         |         |         | head (snareCC?)
#      rms rms |  rms    |  rms  rms   rms  rms  |         |         |         |         |         |         | rim
#      xtk xtk |  xtk    |       xtk   xtk  xtk  |         |         |         |         |         |         | xtk
#      rmh rmh |         |       rmh   rmh  rmh  |         |         |         |         |         |         | (head snareCC?)
#      rim rim |         |       rim   rim       |         |         |         |         |         |         | (rim snareCC??!)
#      prs prs |  prs    |       prs   prs  prs  |         |         |         |         |         |         | -
#          e2c |         |       e2c   e2c  e2c  |         |         |         |         |         |         | -
#          rol |         |       rol   rol  rol  |         |         |         |         |         |         | -


declare -A keys

# sn<size>_<tuning>_<beater>_snare_<on|off>_<articulation><|roundrobin>_<l|r><|mishit>.sfz

# tunings is to help create the output files
declare -A tunings
tunings=(\
	[brs]="sn12_bop sn12_funk sn14_rock"\
	[hnd]="sn10_jungle sn12_bop"\
	[mlt]="sn12_bop"\
	[stx]="sn10_jungle sn10_piccolo sn12_bop_muted sn12_bop_open sn12_dead sn12_funk sn12_orleans sn12_tight sn14_metal sn14_rock"\
)

# which snares exist
declare -A snares
snares=(\
	[brs_sn12_bop]="      off on"\
	[brs_sn12_funk]="         on"\
	[brs_sn14_rock]="         on"\
	[hnd_sn10_jungle]="   off"\
	[hnd_sn12_bop]="      off on"\
	[mlt_sn12_bop]="      off on"\
	[stx_sn10_jungle]="   off on"\
	[stx_sn10_piccolo]="      on"\
	[stx_sn12_bop_muted]="off on"\
	[stx_sn12_bop_open]=" off on"\
	[stx_sn12_dead]="         on"\
	[stx_sn12_funk]="         on"\
	[stx_sn12_orleans]="      on"\
	[stx_sn12_tight]="        on"\
	[stx_sn14_metal]="    off on"\
	[stx_sn14_rock]="     off on"\
)


declare -A articulations has_articulations
# ord - inner; e2c - loudess-dependent outer (soft) to inner (loud)
# rms - inner and rim; rmh - outer and rim; rim - rim only
# xtk - cross-stick (two versions, no telling which is which?)
# sweeps: swc - circular; swl - legato; sws - stacato; swu - under
# brushes: cls - brush stays in contact; opn - brush allowed to rebound
# 
# articulations[<beater>]         - list of expected articulations
# articulations[<beater>_default] - articulation to use if one is missing
#
articulations=(\
	[brs_sn12_bop_off]="                          rms             cls opn"
	[brs_sn12_bop_on]="                           rms             cls opn swc swl sws swu"\
	[brs_sn12_funk_on]="                                          cls"\
	[brs_sn14_rock_on]="                                          cls opn swc swl sws swu"\
	[brs]="                                       rms             cls opn swc swl sws swu"\
	[brs_default]="                                               cls"\
	[hnd_sn10_jungle_off]="       ord             rms         slp"\
	[hnd_sn12_bop_off]="          ord"\
	[hnd_sn12_bop_on]="           ord"\
	[hnd]="                       ord             rms         slp"\
	[hnd_default]="               ord"\
	[mlt_sn12_bop_off]="          ord"\
	[mlt_sn12_bop_on]="           ord"\
	[mlt]="                       ord"\
	[mlt_default]="               ord"\
	[stx_sn10_jungle_off]="       ord prs rim rmh rms     xtk"\
	[stx_sn10_jungle_on]="    e2c ord prs rim rmh rms rol xtk"\
	[stx_sn10_piccolo_on]="       ord prs         rms     xtk"\
	[stx_sn12_bop_muted_off]="    ord             rms"\
	[stx_sn12_bop_muted_on]=" e2c ord prs rim rmh rms rol xtk"\
	[stx_sn12_bop_open_off]=" e2c ord prs rim rmh rms     xtk"\
	[stx_sn12_bop_open_on]="  e2c ord prs     rmh rms rol xtk"\
	[stx_sn12_dead_on]="          ord prs         rms"\
	[stx_sn12_funk_on]="      e2c ord prs     rmh rms rol xtk"\
	[stx_sn12_orleans_on]="       ord prs     rmh rms rol xtk"\
	[stx_sn12_tight_on]="     e2c ord prs     rmh rms rol xtk"\
	[stx_sn14_metal_off]="        ord prs         rms"\
	[stx_sn14_metal_on]="         ord prs         rms     xtk"\
	[stx_sn14_rock_off]="         ord prs         rms     xtk"\
	[stx_sn14_rock_on]="          ord prs         rms rol xtk"\
	[stx]="                   e2c ord prs rim rmh rms rol xtk"\
	[stx_default]="               ord"\
)

# these _should_ have l/r files - if not, make it up (same one twice)
declare -A handed hands has_hands
handed=([e2c]=1 [ord]=1 [prs]=1 [rmh]=1 [rms]=1 [slp]=1 [cls]=1 [clsrls]=1 [opn]=1)
hands=(\
	[brs_sn12_bop_off]="                      rms     cls opn clsrls"\
	[brs_sn12_bop_on]="                       rms     cls opn clsrls"\
	[brs_sn12_funk_on]="                              cls"\
	[brs_sn14_rock_on]="                              cls opn clsrls"\
	[hnd_sn10_jungle_off]="       ord         rms slp"\
	[hnd_sn12_bop_off]="          ord"\
	[hnd_sn12_bop_on]="           ord"\
	[mlt_sn12_bop_off]="          ord"\
	[mlt_sn12_bop_on]="           ord"\
       	[stx_sn10_jungle_off]="       ord prs rmh rms"\
	[stx_sn10_jungle_on]="    e2c ord prs rmh rms"\
	[stx_sn10_piccolo_on]="       ord prs     rms"\
	[stx_sn12_bop_muted_off]="    ord         rms"\
	[stx_sn12_bop_muted_on]=" e2c ord prs rmh rms"\
	[stx_sn12_bop_open_off]=" e2c ord prs rmh rms"\
	[stx_sn12_bop_open_on]="  e2c ord prs rmh rms"\
	[stx_sn12_dead_on]="          ord prs     rms"\
	[stx_sn12_funk_on]="      e2c ord prs rmh rms"\
	[stx_sn12_orleans_on]="       ord prs rmh rms"\
	[stx_sn12_tight_on]="     e2c ord prs rmh rms"\
	[stx_sn14_metal_off]="        ord prs     rms"\
	[stx_sn14_metal_on]="         ord prs     rms"\
	[stx_sn14_rock_off]="         ord prs     rms"\
	[stx_sn14_rock_on]="          ord prs     rms"\
)

declare -A releases has_release
# these _should_ have <articulation>rls files - if not, make it up (use <articulation> or default)
releases=([cls]=1)
# those kit pieces with release articulations
has_release=([brs_sn12_bop_off_cls]=1 [brs_sn12_bop_on_cls]=1 [brs_sn14_rock_on_cls]=1)

declare -A repeats has_repeat
# these _should_ have <articulation>rpt files - if not, make it up (use <articulation> or default)
repeats=([swl]=1 [sws]=1)
# those kit pieces with repeat articulations
has_repeat=([brs_sn12_bop_on_swl]=1 [brs_sn12_bop_on_sws]=1 [brs_sn14_rock_on_sws]=1)

declare -A has_rr
has_rr=(\
	[stx_sn10_piccolo_on_xtk]="a b"\
	[stx_sn12_bop_muted_on_xtk]="a b c"\
	[stx_sn12_bop_open_off_xtk]="a b"\
	[stx_sn12_bop_open_on_xtk]="a b"\
	[stx_sn12_funk_on_xtk]="a b"\
	[rr2a]="0.0 0.5" [rr2b]="0.5 1.0"\
	[rr3a]="0.0 0.33333" [rr3b]="0.33333 0.66667" [rr3c]="0.66667 1.0"\
)

function do_rr () {
	local beater=$1      ; shift || { echo "do_rr: Missing beater"       >&2; exit 1; }
	local tuning=$1      ; shift || { echo "do_rr: Missing tuning"       >&2; exit 1; }
	local snare=$1       ; shift || { echo "do_rr: Missing snare"        >&2; exit 1; }
	# trigger is what it should be
	local trigger=$1     ; shift || { echo "do_rr: Missing trigger"      >&2; exit 1; }
	# articulation is what we have to use
	local articulation=$1; shift || { echo "do_rr: Missing articulation" >&2; exit 1; }
	local trigger_hand=$1; shift || { echo "do_rr: Missing trigger_hand" >&2; exit 1; }
	local file_hand=$1   ; shift || { echo "do_rr: Missing file_hand"    >&2; exit 1; }
#echo >&2 "beater {$beater}; tuning {$tuning}; snare {$snare}; trigger {$trigger}; articulation {$articulation}; trigger_hand {$trigger_hand}; file_hand {$file_hand}"

	# sn12_bop_mlt_snare_on_ord_l.sfz
	local key file

	local bts="${beater}_${tuning}_${snare}"
	if [[ ! -v has_rr[${bts}_${trigger}] ]]
	then
		file="${tuning}_${beater}_snare_${snare}_${articulation}"
		[[ -z "$trigger_hand" ]] && key="\$${tuning}_${trigger}" || key="\$${tuning}_${trigger}_${trigger_hand}"
		[[ -z "$file_hand"    ]] || file="${file}_${file_hand}"
		[[ -f "kit_pieces/snares/${file}.sfz" ]] || { echo "Missing kit piece: $file" >&2; exit 1; }
		[[ -v keys[$key] ]] || { keys[$key]=1; [[ -v keys[keys] ]] && keys[keys]="${keys[keys]} $key" || keys[keys]=$key; }
#echo >&2 "key {$key}; file {$file}"
		get_durations kit_pieces/snares/${file}.sfz max_duration

		echo "<group>"
		echo " key=$key"
		echo "#include \"kit_pieces/snares/${file}.sfz\""
	else
		local -a rrs lohirand
		rrs=($(echo ${has_rr[${bts}_${trigger}]}))
		local n_rrs=${#rrs[@]}
		for rr in ${rrs[@]}
		do
			lohirand=($(echo ${has_rr[rr${n_rrs}${rr}]}))
			file="${tuning}_${beater}_snare_${snare}_${articulation}${rr}"
			[[ -z "$trigger_hand" ]] && key="\$${tuning}_${trigger}" || key="\$${tuning}_${trigger}_${trigger_hand}"
			[[ -z "$file_hand"    ]] || file="${file}_${file_hand}"
			[[ -f "kit_pieces/snares/${file}.sfz" ]] || { echo "Missing kit piece: $file" >&2; exit 1; }
			[[ -v keys[$key] ]] || { keys[$key]=1; [[ -v keys[keys] ]] && keys[keys]="${keys[keys]} $key" || keys[keys]=$key; }
#echo >&2 "key {$key}; file {$file}; rr {$rr}"
			get_durations kit_pieces/snares/${file}.sfz max_duration

			echo "<group>"
			echo " key=$key"
			echo " lorand=${lohirand[0]} hirand=${lohirand[1]}"
			echo "#include \"kit_pieces/snares/${file}.sfz\""
		done
	fi
}

# do_articulation $beater $tuning $snare $articulation $the_articulation
function do_articulation () {
	local beater=$1      ; shift || { echo "do_articulation: Missing beater"       >&2; exit 1; }
	local tuning=$1      ; shift || { echo "do_articulation: Missing tuning"       >&2; exit 1; }
	local snare=$1       ; shift || { echo "do_articulation: Missing snare"        >&2; exit 1; }
	local trigger=$1     ; shift || { echo "do_articulation: Missing trigger"      >&2; exit 1; }
	local articulation=$1; shift || { echo "do_articulation: Missing articulation" >&2; exit 1; }

	if [[ -v handed[$trigger] ]]
	then

		if [[ -v has_hands[${beater}_${tuning}_${snare}_${articulation}] ]]
		then
#echo >&2 "trigger {$trigger} is handed; articulation ${articulation} has hands"
			do_rr $beater $tuning $snare $trigger $articulation l l
			do_rr $beater $tuning $snare $trigger $articulation r r
		else
#echo >&2 "trigger {$trigger} is handed; articulation ${articulation} does not have hands"
			do_rr $beater $tuning $snare $trigger $articulation l ''
			do_rr $beater $tuning $snare $trigger $articulation r ''
		fi

	else
		if [[ -v has_hands[${beater}_${tuning}_${snare}_${articulation}] ]]
		then
#echo >&2 "trigger {$trigger} is not handed; articulation ${articulation} has hands"
			do_rr $beater $tuning $snare $trigger $articulation '' r
		else
#echo >&2 "trigger {$trigger} is not handed; articulation ${articulation} does not have hands"
			do_rr $beater $tuning $snare $trigger $articulation '' ''
		fi
	fi
}

rm -rf triggers/*/snares/
rm -f triggers/*/sn??_snare_*.inc

for beater in ${!tunings[@]}
do
	# {
	[[ -v tunings[$beater] ]] || { echo "tuning for $beater not found" >&2; exit 1; }

	required_articulations=($(echo ${articulations[$beater]}))
	default_articulation=$(echo ${articulations[${beater}_default]})

	mkdir -p triggers/${beater}/snares

	for tuning in $(echo ${tunings[$beater]})
	do
		# {
		[[ -v snares[${beater}_${tuning}] ]] || { echo "snares for ${beater}_${tuning} not found" >&2; exit 1; }

		for snare in $(echo ${snares[${beater}_${tuning}]})
		do
			# {

			f="${tuning}_snare_${snare}.inc"
echo >&2 "triggers/${beater}/snares/$f"
			rm -f triggers/${beater}/snares/$f
			rm -f triggers/${beater}/$f
			max_duration=0

			bts="${beater}_${tuning}_${snare}"
			[[ -v articulations[$bts] ]] || { echo "articulations for $bts not found" >&2; exit 1; }
#echo >&2 "bts {$bts}; articulations {$(echo ${articulations[$bts]})}; hands {$(echo ${hands[$bts]})}"

			keys=()

			has_articulations=()
			for articulation in $(echo ${articulations[$bts]})
			do
				has_articulations[$articulation]=1
			done

			has_hands=()
			for hand in $(echo ${hands[$bts]})
			do
				has_hands[${bts}_${hand}]=1
			done

			for articulation in ${required_articulations[@]}
			do
				[[ -v has_articulations[$articulation] ]] && {
					the_articulation=$articulation
				} || {
					the_articulation=$default_articulation
				}
				do_articulation $beater $tuning $snare $articulation $the_articulation

				if [[ -v releases[$articulation] ]]
				then
					[[ -v has_release[${bts}_${articulation}] ]] && {
						do_articulation $beater $tuning $snare ${articulation}rls ${articulation}rls
					} || {
						do_articulation $beater $tuning $snare ${articulation}rls ${the_articulation}
					}
				fi

				if [[ -v repeats[$articulation] ]]
				then
					[[ -v has_repeat[${bts}_${articulation}] ]] && {
						do_articulation $beater $tuning $snare ${articulation}rpt ${articulation}rpt
					} || {
						do_articulation $beater $tuning $snare ${articulation}rpt ${the_articulation}
					}
				fi
			done > triggers/$beater/snares/$f

			{
				echo "// Max duration $max_duration"
				i=1
				for key in $(echo ${keys[keys]})
				do
					printf '#define %s %03d\n' ${key} $i
					(( i += 1 ))
				done
				echo ""
				echo "#include \"triggers/$beater/snares/$f\""
			} > triggers/$beater/$f

			# } - snare
		done
		# } - tuning

	done

	# } - beater
done
