#!/bin/bash -eu

. utils.sh



### rework -- table unfinished: it does not work like this yet

declare -A beaters=(
	[keys]="brs hnd mlt stx"
	[brs]="brushes"
	[hnd]="hand"
	[mlt]="mallets"
	[stx]="sticks"
)
declare -A drum_tunings=(
	[keys]="sn10 sn12 sn14"
	[sn10]="jungle piccolo"
	[sn12]="bop dead funk orleans tight"
	[sn14]="metal rock"
)
declare -A snares=(
	[sn10_jungle]="off on"
	[sn10_piccolo]="on"
	[sn12_bop]="off on"
	[sn12_dead]="on"
	[sn12_funk]="on"
	[sn12_orleans]="on"
	[sn12_tight]="on"
	[sn14_metal]="off on"
	[sn14_rock]="off on"
)

cat <<-'@EOF' > /dev/null
positions: head xtk rim brush ... magic happens:
    head xtk rim
    brush_down_new brush_down_legato brush_down_legato_rls
    brush_drag_new brush_drag_new_rpt brush_drag_legato brush_drag_legato_rpt
articulations:
    sweeps: swc - circular; swl - legato; sws - stacato; swu - under
    brushes: cls - brush stays in contact; opn - brush allowed to rebound

We're going to need some magic scripting.
TD-27 sends the snare pos CC when it decides a fresh brush stroke has started.
Overall timer (sample counter) needs to check whether we've had a Note On recently.

Flow A - Note On following Snare Position CC without intervening Note On
- Flow A1 - Timer has expired
  - if we last sent sn_head_drag_new, send sn_head_drag_new_rpt
  - else if we last sent sn_head_down_legato, send sn_head_down_legato_rls
  - else sn_head_down_new
- Flow A2 - Timer has not expired
  - sn_head_down_legato
Flow B - Note On following Note On without intervening Snare Position CC (i.e. not Flow A)
- Flow B1 - Timer has expired
  - if we last sent sn_head_drag_legato, send sn_head_drag_legato
  - else sn_head_drag_new
- Flow B2 - Timer has not expired
  - if we last sent sn_head_drag_legato, send sn_head_drag_legato_rpt
  - else sn_head_drag_legato

We do NOT get a valid position from Snare Position CC for brush notes

sn_brush_down_new:        opn
sn_brush_down_legato:     cls
sn_brush_down_legato_rls: clsrls or end=-1 sample=*silence
sn_brush_drag_new:        sws
sn_brush_drag_new_rpt:    swsrpt or sws
sn_brush_drag_legato:     swl
sn_brush_drag_legato_rpt: swlrpt or swl
sn_xtk:                   xtk
sn_rim:                   rim


cls may have clsrls (bop, rock/w) to be triggered when the brush leaves the head
swl/sws may have swlrpt/swsrpt (swl/sws: bop/w; sws: rock/w) to be triggered continues the sweep rather than leaves the head

swc, cirular sweep, and swu, sweep under, are not supported.

   |------- sn10 ------|----------------------------- sn12 ----------------------------|------- sn14 ------|
     jungle  | piccolo |           bop         |   dead  |  funk   | orleans |  tight  | metal   |  rock   | trigger
     off on  |   on    |     off        on     |    on   |   on    |   on    |   on    | off on  | off on  |
                       | muted open muted open |         |         |         |         |         |         | (or "-")

brs
                             opn        opn    |         |   cls   |         |         |         |     opn | sn_head_down_new
                             cls        cls    |         |   cls   |         |         |         |     cls | sn_head_down_legato*1
                             opn        sws    |         |   cls   |         |         |         |     sws | sn_head_drag_new*2
                             cls        swl    |         |   cls   |         |         |         |     swl | sn_head_drag_legato*2
                             rms        rms    |         |   cls   |         |         |         |     opn | sn_rim / sn_xtk
                                        swc    |         |         |         |         |         |     swc | -
                                        swu    |         |         |         |         |         |     swu | -


*1: sn_head_down_legato:
    cls may have clsrls (bop, rock/w) to be triggered when the brush leaves the head
    or, where no clsrls, end=-1 sample=*silence

*2: sn_head_drag_new, sn_head_drag_legato:
    swl/sws may have swlrpt/swsrpt (swl/sws: bop/w; sws: rock/w) to be triggered for repeated strokes
    or, where no swlrpt/swsrpt, swl/sws

sn_xtk:                  xtk
sn_rim:                  rim


@EOF
cat <<-'@EOF' > /dev/null
positions head rim xtk
snareCC for inaccurately controlling anything else

???: head->ord, rim->rms, xtk->xtk

(old)
ord - inner; e2c - loudess-dependent outer (soft) to inner (loud)
rms - inner and rim; rmh - outer and rim; rim - rim only
xtk - cross-stick (two versions, no telling which is which?)


   |------- sn10 ------|----------------------------- sn12 ----------------------------|------- sn14 ------|
     jungle  | piccolo |           bop         |   dead  |  funk   | orleans |  tight  | metal   |  rock   | trigger
     off on  |   on    |     off        on     |    on   |   on    |   on    |   on    | off on  | off on  |
                       | muted open muted open |         |         |         |         |         |         | (or "-")

hnd
     ord     |         |     ord        ord    |         |         |         |         |         |         | head
     slp     |         |     ord        ord    |         |         |         |         |         |         | xtk
     rms     |         |     ord        ord    |         |         |         |         |         |         | rim

slp=slap

mlt
             |         |     ord        ord    |         |         |         |         |         |         | head
             |         |     ord        ord    |         |         |         |         |         |         | xtk
             |         |     ord        ord    |         |         |         |         |         |         | rim

stx
     ord ord |  ord    |  ord  ord   ord  ord  |   ord   |   ord   |   ord   |   ord   | ord ord | ord ord | head
     xtk xtk |  xtk    |  rms  xtk   xtk  xtk  |   rms   |   xtk   |   xtk   |   xtk   | rms xtk | xtk xtk | xtk
     rim rim |  rms    |  rms  rim   rim  rms  |   rms   |   rms   |   rms   |   rms   | rms rms | rms rms | rim
     rms rms |  rms    |  rms  rms   rms  rms  |   rms   |   rms   |   rms   |   rms   | rms rms | rms rms | rim+head CCin
     rmh rmh |  rms    |  rms  rmh   rmh  rmh  |   rms   |   rmh   |   rmh   |   rmh   | rms rms | rms rms | rim+head CCout
     prs prs |  prs    |       prs   prs  prs  |   prs   |   prs   |   prs   |   prs   | prs prs | prs prs | -
         e2c |         |       e2c   e2c  e2c  |         |   e2c   |         |   e2c   |         |         | -
         rol |         |             rol  rol  |         |   rol   |   rol   |   rol   |         |     rol | -

# xtk=cross-stick; rmh=high rimshot; rim=rim;
#
# For rms/rmh - use sw_last=$sn_rim key=$sn_head and locc$sn_zone=0 hicc$sn_zone=<thresh> for rms vs rmh switching -- mute any rim
# For rim     - use key=$sn_rim
@EOF

# Currently, sn_head, sn_xtk and sn_rim are likely to work.
# No current plan for how sn_rms and sn_rmh work (rim+snareCCin, rim+snareCCout ???).
# Similarly, sn_prs, sn_e2c and sn_rol aren't scripted so won't arrive.
# Brushes, except sn_swc and sn_swu as explained above.
# triggermap is the lookup -- "keys" is all possible triggers.
# articulations is the mapping from trigger to kit piece for that snare.
# "-" means play `end=-1 sample=*silence` and should generally never happen.
# Where index exceeds articulations for snare, use "-".
declare -A triggermap=(
	[keys]="head xtk rim rms rmh prs e2c rol brush_down_new brush_down_legato brush_down_legato_rls brush_drag_new brush_drag_new_rpt brush_drag_legato brush_drag_legato_rpt swc swu"
	[head]=0 [xtk]=1 [rim]=2 [rms]=3 [rmh]=4
	[prs]=5 [e2c]=6 [rol]=7
	[brush_down_new]=8 [brush_down_legato]=9 [brush_down_legato_rls]=10
	[brush_drag_new]=11 [brush_drag_new_rpt]=12 [brush_drag_legato]=13 [brush_drag_legato_rpt]=14
	[swc]=15 [swu]=16
)

declare -A articulations=(
	[sn10_jungle_off_hnd]="   ord slp rms rms rms"
	[sn10_jungle_off_stx]="   ord xtk rim rms rmh prs"
	[sn10_jungle_on_stx]="    ord xtk rim rms rmh prs e2c rol"
	[sn10_piccolo_on_stx]="   ord xtk rms rms rms prs"
	[sn12_bop_off_brs]="      -   rms rms -   -   -   -   -   opn cls clsrls opn opn    cls cls    -   -"
	[sn12_bop_off_hnd]="      ord ord ord ord ord"
	[sn12_bop_off_mlt]="      ord ord ord ord ord"
	[sn12_bop_off_stx_muted]="ord rms rms rms rms"
	[sn12_bop_off_stx_open]=" ord xtk rim rms rmh prs e2c"
	[sn12_bop_on_brs]="       -   rms rms -   -   -   -   -   opn cls clsrls sws swsrpt swl swlrpt swc swu"
	[sn12_bop_on_hnd]="       ord ord ord ord ord"
	[sn12_bop_on_mlt]="       ord ord ord ord ord"
	[sn12_bop_on_stx_muted]=" ord xtk rim rms rmh prs e2c rol"
	[sn12_bop_on_stx_open]="  ord xtk rms rms rmh prs e2c rol"
	[sn12_dead_on_stx]="      ord rms rms rms rms prs"
	[sn12_funk_on_brs]="      -   cls cls -   -   -   -   -   cls cls cls    cls cls    cls cls    -   -"
	[sn12_funk_on_stx]="      ord xtk rms rms rmh prs e2c rol"
	[sn12_orleans_on_stx]="   ord xtk rms rms rmh prs -   rol"
	[sn12_tight_on_stx]="     ord xtk rms rms rmh prs e2c rol"
	[sn14_metal_off_stx]="    ord rms rms rms rms prs"
	[sn14_metal_on_stx]="     ord xtk rms rms rms prs"
	[sn14_rock_off_stx]="     ord xtk rms rms rms prs"
	[sn14_rock_on_brs]="      -   cls cls -   -   -   -   -   opn cls clsrls sws swsrpt swl swl    swc swu"
	[sn14_rock_on_stx]="      ord xtk rms rms rms prs -   rol"
)

function get_articulations () {
	local drum=$1; shift || { echo "get_articulations: Missing drum" >&2; exit 1; }
	local tuning=$1; shift || { echo "get_articulations: Missing tuning" >&2; exit 1; }
	local snare=$1; shift || { echo "get_articulations: Missing snare" >&2; exit 1; }
	local beater=$1; shift || { echo "get_articulations: Missing beater" >&2; exit 1; }
	local mute=$1; shift || { echo "get_articulations: Missing mute" >&2; exit 1; }
	local -n _arts_ref=$1; shift || { echo "get_articulations: Missing articulations reference" >&2; exit 1; }
	[[ $# -eq 0 ]] || { echo "get_articulations: Unexpected trailing parameters: [$@]" >&2; exit 1; }

	local art_key="${drum}_${tuning}_${snare}_${beater}"
	if [[ "${mute}" != "-" ]]
	then
		art_key="${art_key}_${mute}"
	fi

	if [[ -v articulations[$art_key] ]]
	then
	 _arts_ref=(${articulations[$art_key]})
#echo >&2 "art_key {$art_key}; articulations (${_arts_ref[@]})"
	fi
}

function get_articulation () {
	local trigger=$1; shift || { echo "get_art_ref: Missing trigger" >&2; exit 1; }
	local -n _arts_ref=$1; shift || { echo "get_art_ref: Missing articulations reference" >&2; exit 1; }
	local -n _art_ref=$1; shift || { echo "get_art_ref: Missing articulation array reference" >&2; exit 1; }
	[[ $# -eq 0 ]] || { echo "get_art_ref: Unexpected trailing parameters: [$@]" >&2; exit 1; }

	[[ -v triggermap["$trigger"] ]] || { echo "get_art_ref: Invalid trigger {$trigger}" >&2; exit 1; }
	local index=${triggermap["$trigger"]}

	if [[ $index -ge ${#_arts_ref[@]} ]]
	then
		_art_ref="-"
	else
		_art_ref=${_arts_ref[$index]}
	fi
}

declare -A has_rr=(
	[sn10_piccolo_on_stx_xtk]="a b"
	[sn12_bop_off_stx_open_xtk]="a b"
	[sn12_bop_on_stx_muted_xtk]="a b c"
	[sn12_bop_on_stx_open_xtk]="a b"
	[sn12_funk_on_stx_xtk]="a b"
	[rr2a]="0.0 0.5" [rr2b]="0.5 1.0"
	[rr3a]="0.0 0.33333" [rr3b]="0.33333 0.66667" [rr3c]="0.66667 1.0"
)

declare -A handed=([e2c]=1 [ord]=1 [prs]=1 [rmh]=1 [rms]=1 [slp]=1 [cls]=1 [clsrls]=1 [opn]=1)

function get_rrs () {
	local drum=$1; shift || { echo "get_rrs: Missing drum" >&2; exit 1; }
	local tuning=$1; shift || { echo "get_rrs: Missing tuning" >&2; exit 1; }
	local snare=$1; shift || { echo "get_rrs: Missing snare" >&2; exit 1; }
	local beater=$1; shift || { echo "get_rrs: Missing beater" >&2; exit 1; }
	local mute=$1; shift || { echo "get_rrs: Missing mute" >&2; exit 1; }
	local art=$1; shift || { echo "get_rrs: Missing art" >&2; exit 1; }
	local -n _rrs_ref=$1; shift || { echo "get_rrs: Missing round-robins reference" >&2; exit 1; }
	[[ $# -eq 0 ]] || { echo "get_rrs: Unexpected trailing parameters: [$@]" >&2; exit 1; }

	_rrs_ref=()

	# deal with the simple ones first - lucky these do not have real rrs
	if [[ -v handed[$art] ]]
	then
		_rrs_ref["keys"]="l r"
		_rrs_ref["l"]="0.0 0.5"
		_rrs_ref["r"]="0.5 1.0"
		return
	fi

	# now deal with xtk
	local rrs_key="${drum}_${tuning}_${snare}_${beater}"
	if [[ "${mute}" != "-" ]]
	then
		rrs_key="${rrs_key}_${mute}"
	fi
	rrs_key="${rrs_key}_${art}"
	if [[ -v has_rr[$rrs_key] ]]
	then
		_rrs_ref["keys"]="${has_rr[$rrs_key]}"
		local -a _rrs=(${has_rr[$rrs_key]})
		local rr_name="rr${#_rrs[@]}"
		for rr in ${_rrs[@]}
		do
			_rrs_ref["$rr"]="${has_rr["${rr_name}${rr}"]}"
		done
	fi
}

# do_articulation $drum $tuning $_sn $beater $mute $trigger $articulation $rr "${rrs[$rr]}"
function do_articulation () {
	local drum=$1; shift || { echo "do_articulation: Missing drum" >&2; exit 1; }
	local tuning=$1; shift || { echo "do_articulation: Missing tuning" >&2; exit 1; }
	local snare=$1; shift || { echo "do_articulation: Missing snare" >&2; exit 1; }
	local beater=$1; shift || { echo "do_articulation: Missing beater" >&2; exit 1; }
	local mute=$1; shift || { echo "do_articulation: Missing mute" >&2; exit 1; }
	local trigger=$1; shift || { echo "do_articulation: Missing trigger" >&2; exit 1; }
	local articulation=$1; shift || { echo "do_articulation: Missing articulation" >&2; exit 1; }
	local rr=$1; shift || { echo "do_articulation: Missing rr" >&2; exit 1; }
	local rr_range=$1; shift || { echo "do_articulation: Missing rr_range" >&2; exit 1; }
	[[ $# -eq 0 ]] || { echo "do_articulation: Unexpected trailing parameters: [$@]" >&2; exit 1; }

	local sfz_file="${drum}_${tuning}"
	if [[ "${mute}" != "-" ]]
	then
		sfz_file="${sfz_file}_${mute}"
	fi
	sfz_file="${sfz_file}_${beater}_snare_${snare}_${articulation}"
	if [[ "${rr}" =~ ^[abc]$ ]]
	then
		sfz_file="${sfz_file}${rr}"
	elif [[ "${rr}" =~ ^[lr]$ ]]
	then
		sfz_file="${sfz_file}_${rr}"
	fi
#echo >&2 "do_articulation: drum {$drum}; tuning {$tuning}; snare {$_sn}; beater {$beater}; mute {$mute}; trigger {$trigger}; articulation {$articulation}; rr {$rr}; rr_range {$rr_range}; sfz_file {$sfz_file}"
	[[ -f "kit_pieces/snares/${sfz_file}.sfz" ]] || { echo "do_articulation: new kit piece ${sfz_file} not found" >&2; exit 1; }
	[[ -f "../snares/${sfz_file}.sfz" ]] || { echo "do_articulation: old kit piece ${sfz_file} not found" >&2; exit 1; }

	get_durations kit_pieces/snares/${sfz_file}.sfz max_duration || { echo "do_articulation: get_durations failed" >&2; exit 1; }

	echo "<group>"
	echo " key=\$sn_${trigger}"
	if [[ "${rr}" != "-" ]]
	then
		local -a lohirand=($rr_range)
		echo " lorand=${lohirand[0]} hirand=${lohirand[1]}"
	fi
	echo "#include \"kit_pieces/snares/${sfz_file}.sfz\""
}

for drum in $(echo ${drum_tunings["keys"]})
do
	for tuning in ${drum_tunings[$drum]}
	do
		for _sn in ${snares[${drum}_${tuning}]}
		do
			for beater in $(echo ${beaters["keys"]})
			do
				if [[ "$beater" == "stx" && "$tuning" == bop ]]
				then
					_mutes=(muted open)
				else
					_mutes=(-)
				fi
				for mute in ${_mutes[@]}
				do

					arts=()
					get_articulations $drum $tuning $_sn $beater $mute arts || { echo "get_articulations failed" >&2; exit 1; }
					if [[ ${#arts[@]} == 0 ]]
					then
#echo >&2 "No articulations for $drum $tuning $_sn $beater $mute"
						continue
					fi

					file="${drum}_${tuning}"
					[[ "${mute}" == "-" ]] || file="${file}_${mute}"
					file="${file}_snare_${_sn}.inc"
					rm -f "triggers/${beater}/${file}"
					rm -f "triggers/${beater}/snares/${file}"
					max_duration=0

					declare -A keymap=()
					for trigger in $(echo ${triggermap["keys"]})
					do
						articulation=""
						get_articulation $trigger arts articulation || { echo "get_articulation failed" >&2; exit 1; }
						if [[ "$articulation" == "-" ]]
						then
							keymap["$trigger"]=0
							continue
						fi
						keymap["$trigger"]=1

						# This gets left/right and real round-robin groups
						# For left/right, need to check if l/r files exist else ignore it
						declare -A rrs=()
						get_rrs $drum $tuning $_sn $beater $mute $articulation rrs || { echo "get_rrs failed" >&2; exit 1; }

[[ -f "triggers/${beater}/snares/${file}" ]] || echo >&2 "drum {$drum}; tuning {$tuning}; snare {$_sn}; beater {$beater}; mute {$mute} -> triggers/${beater}/snares/${file}"
						{
							if [[ -v rrs["keys"] ]]
							then
								for rr in $(echo ${rrs["keys"]})
								do
									do_articulation $drum $tuning $_sn $beater $mute $trigger $articulation $rr "${rrs[$rr]}" || { echo "do_articulation failed" >&2; exit 1; }
								done
							else
								do_articulation $drum $tuning $_sn $beater $mute $trigger $articulation - - || { echo "do_articulation failed" >&2; exit 1; }
							fi
						} >> "triggers/${beater}/snares/${file}"
					done

					{
						echo "// Max duration $max_duration"
						i=1
						for key in $(echo ${triggermap["keys"]})
						do
							if [[ ${keymap["$key"]} == 0 ]]
							then
								printf '#define $sn_%s %03d\n' ${key} 0
							else
								printf '#define $sn_%s %03d\n' ${key} $i
							fi
							(( i += 1 ))
						done
						echo ""
						echo "#include \"triggers/${beater}/snares/${file}\""
					} > "triggers/${beater}/${file}"


				done
			done
		done
	done
done
exit 0


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
	[[ $# -eq 0 ]] || { echo "do_rr: Unexpected trailing parameters: [$@]" >&2; exit 1; }

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
	[[ $# -eq 0 ]] || { echo "do_articulation: Unexpected trailing parameters: [$@]" >&2; exit 1; }

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
