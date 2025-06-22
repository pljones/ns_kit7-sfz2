#!/bin/bash -eu

. utils.sh

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

: <<-'@EOF'
----- BRUSH SNARE -----

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

@EOF
: <<-'@EOF'
----- HAND, MALLET, STICK SNARE -----

positions head rim xtk
snareCC for inaccurately controlling anything else

???: head->ord, rim->rms, xtk->xtk


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

# Currently, sn_head, sn_xtk and sn_rim are likely to work.
# No current plan for how sn_rms and sn_rmh work (rim+snareCCin, rim+snareCCout ???).
#     (maybe use sw_last=$sn_rim key=$sn_head and locc$sn_zone=0 hicc$sn_zone=<thresh>)
# Similarly, sn_prs, sn_e2c and sn_rol aren't scripted so won't arrive.
# Brushes, except sn_swc and sn_swu as explained above.
@EOF

# triggermap is the lookup -- "keys" is all possible triggers.
# articulations is the mapping from trigger to kit piece for that snare.
# "-" means play `end=-1 sample=*silence` and should generally never happen.
# Where index exceeds articulations for snare, use "-".
# Start at MIDI note 001 (value + 1) for each snare - mk_kits.sh overrides these; mk_sfz.sh does not
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

	[[ $articulation == rol ]] || get_durations kit_pieces/snares/${sfz_file}.sfz max_duration || { echo "do_articulation: get_durations failed" >&2; exit 1; }

	echo "<group>"
	echo " key=\$sn_${trigger}"
	if [[ "${rr}" != "-" ]]
	then
		local -a lohirand=($rr_range)
		echo " lorand=${lohirand[0]} hirand=${lohirand[1]}"
	fi
	echo "#include \"kit_pieces/snares/${sfz_file}.sfz\""
}

rm -rf triggers/*/snares
rm -f triggers/*/sn??_*o{n,ff}.inc
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
						mkdir -p "triggers/${beater}/snares/"
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
						# echo "// Max duration $max_duration"
						for key in $(echo ${triggermap["keys"]})
						do
							if [[ ${keymap["$key"]} == 0 ]]
							then
								printf '#define $sn_%s %03d\n' ${key} 0
							else
								printf '#define $sn_%s %03d\n' ${key} $(( ${triggermap[$key]} + 1 ))
							fi
						done
						echo ""
						#echo '<group>'
						#echo '<region> key=000 end=-1 sample=*silence'
						#echo ""
						echo "#include \"triggers/${beater}/snares/${file}\""
					} > "triggers/${beater}/${file}"


				done
			done
		done
	done
done
