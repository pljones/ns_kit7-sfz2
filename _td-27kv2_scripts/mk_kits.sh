#!/bin/bash -eu

# kit layout (joy of ASCII art) for ns_kit7 generic

#             ( 8" splash )      ( 9" spash )
#                      ( 15" crash )
#       ( 19" ride )     (T2)  (T3)
#                   (T1)   (KICK)    ( 19" china )
#  ( 18" crash ) (SN)               (T4)   ( 12" splash )
#            (HH)                       ( 20" ride )
#                                     (T5)

# kit layout for TD-27KV2

#                  (CR1)          (CR2)
#                        (T1) (T2)
#                     (HH)     (KICK) (DR)
#                        (SN)     (T3)


function override_defines () {
	local trigger_file=$1; shift || { echo "override_defines: Missing trigger_file" >&2; exit 1; }
	local -n key_ref=$1  ; shift || { echo "override_defines: Missing key_ref" >&2; exit 1; }

	mapfile -t triggers < "${trigger_file}"
	i=0
	while [[ $i -lt ${#triggers[@]} ]]
	do
		line=${triggers[$i]}
		(( i += 1 ))
		[[ "$line" =~ ^(#define  *)(\$[^ ]* )([0-9][0-9]*)$ ]] && {
			printf '%s %s %03d\n' ${BASH_REMATCH[1]} ${BASH_REMATCH[2]} $key_ref
			(( key_ref += 1 ))
		}
	done
	grep -v '^\(#define\|$\)' "${trigger_file}"
	echo ''
}

rm -rf _kits
mkdir _kits

kits=(funk orleans bop bop_muted bop_open rock jungle tight piccolo dead metal)
for kit in ${kits[@]}
do
	declare -A $kit
done
bop=(      [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop       [toms]=bop)
bop_muted=([cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop_muted [toms]=bop)
bop_open=( [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop_open  [toms]=bop)
jungle=(   [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn10_jungle    [toms]=bop)
funk=(     [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd20_punch  [snares]=sn12_funk      [toms]=rock)
rock=(     [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd20_punch  [snares]=sn14_rock      [toms]=rock)
piccolo=(  [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd22_noreso [snares]=sn10_piccolo   [toms]=dry)
orleans=(  [cymbals]=cy19_ride   [hihats]=hh14 [kicks]=kd22_boom   [snares]=sn12_orleans   [toms]=rock)
tight=(    [cymbals]=cy19_ride   [hihats]=hh14 [kicks]=kd20_full   [snares]=sn12_tight     [toms]=rock)
dead=(     [cymbals]=cy19_ride   [hihats]=hh14 [kicks]=kd22_noreso [snares]=sn12_dead      [toms]=dry)
metal=(    [cymbals]=cy19_sizzle [hihats]=hh13 [kicks]=kd22_boom   [snares]=sn14_metal     [toms]=noreso)

cys=(cy8_splash cy9_splash cy12_splash cy15_crash cy18_crash cy19_china cy20_ride)

tm_bop=(tm8 tm10 tm12 tm14 tm16)
tm_dry=(tm10 tm10 tm12 tm14 tm14)
tm_noreso=(tm10 tm10 tm12 tm14 tm14)
tm_rock=(tm8 tm10 tm12 tm14 tm16)

# OK, so stuff "natural studio" dynamics... these should have fader onccXX assignments
declare -A cy_volume=()
cy_volume+=([brs-cy8_splash]="10" [brs-cy9_splash]="5" [brs-cy12_splash]="10" [brs-cy15_crash]="10" [brs-cy18_crash]="10" [brs-cy19_china]="17.5" [brs-cy20_ride]="15" [brs-cy19_ride]="15" [brs-cy19_sizzle]="15")
cy_volume+=([hnd-cy8_splash]="12" [hnd-cy9_splash]="13" [hnd-cy12_splash]="17" [hnd-cy15_crash]="19.5" [hnd-cy18_crash]="22.5" [hnd-cy19_china]="19.5" [hnd-cy20_ride]="34.5" [hnd-cy19_ride]="13.5" [hnd-cy19_sizzle]="14")
cy_volume+=([mlt-cy8_splash]="2" [mlt-cy9_splash]="2" [mlt-cy12_splash]="4" [mlt-cy15_crash]="-1.5" [mlt-cy18_crash]="-0.5" [mlt-cy19_china]="10" [mlt-cy20_ride]="15" [mlt-cy19_ride]="4" [mlt-cy19_sizzle]="4")
cy_volume+=([stx-cy8_splash]="-2" [stx-cy9_splash]="-1.5" [stx-cy12_splash]="-1.5" [stx-cy15_crash]="-2.5" [stx-cy18_crash]="-4" [stx-cy19_china]="1.5" [stx-cy20_ride]="0.5" [stx-cy19_ride]="7.5" [stx-cy19_sizzle]="8.5")
declare -A hh_volume=([brs-hh13]="12.5" [brs-hh14]="7.5" [hnd-hh13]="14" [hnd-hh14]="8" [mlt-hh13]="7" [mlt-hh14]="5.5" [stx-hh13]="0" [stx-hh14]="-1")
declare -A kick_volume=([kd14_bop]="0.5" [kd20_punch]="-4.5" [kd22_noreso]="0.5" [kd22_boom]="-0.5" [kd20_full]="-0.5")
declare -A sn_volume=()
sn_volume+=([brs-sn12_bop]="7" [brs-sn12_funk]="5" [brs-sn14_rock]="7")
sn_volume+=([hnd-sn12_bop]="10" [hnd-sn10_jungle]="15")
sn_volume+=([mlt-sn12_bop]="0")
sn_volume+=([stx-sn12_bop_muted]="1" [stx-sn12_bop_open]="1" [stx-sn10_jungle]="6" [stx-sn12_funk]="-2.5" [stx-sn14_rock]="-2" [stx-sn10_piccolo]="3" [stx-sn12_orleans]="-1" [stx-sn12_tight]="-3.5" [stx-sn12_dead]="1" [stx-sn14_metal]="4")
declare -A tm_volume=([tm8]="6.5" [tm10]="4.5" [tm12]="3" [tm14]="4.5" [tm16]="6")
declare -A cowbell_volume=([brs]="13" [hnd]="14.5" [mlt]="11" [stx]="-1.5")

: <<-@EOF
Unfortunately I decided in the end to put these embedded in the trigger include files.
ped hh13 +7.5, hh14 +18.5
spl hh13 +4.5, hh14 +19
@EOF

for kit in ${kits[@]}
do
	echo --- $kit ---
	declare -n k=$kit
	declare -a c=(${cys[@]} ${k[cymbals]})
	declare -n t=tm_${k[toms]}
	the_hihat=${k[hihats]}


	for btr in brs hnd mlt stx
	do
		if [[ "$kit" == "bop" && "$btr" == "stx" ]]
		then
			continue
		elif [[ "$btr" != "stx" && "$kit" =~ ^bop_ ]]
		then
			continue
		fi
		for cy in "${c[@]}"
		do
			[[ -f "triggers/${btr}/${cy}.sfzh" ]] || { echo "${kit} ${btr} snare ${snare} has no ${cy}"; continue; }
		done
		[[ -f "triggers/${btr}/${k[hihats]}.sfzh" ]] || { echo "${kit} ${btr} snare ${snare} has no ${k[hihats]}"; continue; }
		for snare in off on
		do
			[[ -f "triggers/${btr}/${k[snares]}_snare_${snare}.sfzh" ]] || {
				# echo "${kit} ${btr} snare ${snare} has no ${k[snares]}";
				continue;
			}
			[[ -f "triggers/ped/${k[kicks]}_snare_${snare}.sfzh" ]] || { echo "${kit} snare ${snare} has no ${k[kicks]}"; continue; }
			actual_toms=()
			# tm12_rock_snare_off.sfzh
			for tm in "${t[@]}"
			do
				f="triggers/${btr}/${tm}_${k[toms]}_snare_${snare}.sfzh"
				if [[ ! -f $f ]]
				then
					x="sn${snare}_btr${btr}_toms${k[toms]}"
#echo >&2 "f {$f}; snare {$snare}; btr {$btr}; toms {${k[toms]}}; x {$x}"
					echo -n "${kit} ${btr} (${k[toms]}) snare ${snare} has no ${tm}; (x {$x})";
					case $x in
						snon_btrbrs_tomsbop|snon_btrstx_tomsbop|snon_btrstx_tomsnoreso)
							actual_toms+=(${tm}_${k[toms]}_snare_off)
							#echo '... will use snare_off tom, then'
							;;
						snon_btrhnd_tomsbop)
							if [[ $tm =~ ^(tm8|tm10)$ ]]
							then
								actual_toms+=(tm12_${k[toms]}_snare_${snare})
								#echo '... will use tm12 tom, then'
							elif [[ $tm == tm16 ]]
							then
								actual_toms+=(tm14_${k[toms]}_snare_${snare})
								#echo '... will use tm14 tom, then'
							fi
							;;
						snon_btrmlt_tomsbop)
							if [[ $tm =~ ^(tm8|tm10)$ ]]
							then
								actual_toms+=(tm12_${k[toms]}_snare_${snare})
								#echo '... will use tm12 tom, then'
							fi
							;;
						*)
							true
							;;
					esac
					f="triggers/${btr}/${actual_toms[-1]}.sfzh"
					if [[ ! -f "$f" ]]
					then
						echo ''
						echo >&2 "Failed to replace tom: {$f} not found"
						exit 1
					else
						echo " - using ${kit} ${btr} ${actual_toms[-1]} instead";
					fi
				else
					actual_toms+=(${tm}_${k[toms]}_snare_${snare})
				fi
			done

			for hh in - invcc4
			do
				f="${kit}"
				if [[ "$hh" != "-" ]]
				then
					f="${f}_${hh}"
				fi
				f="${f}_${btr}_snare_${snare}.sfz"
				echo "Making _kits/$f ..."
				{
				cat <<-'@EOF'
//***
// Aria Player sfz mapping V2 for Natural Studio ns_kit7
// Mapping Copyright (C) 2025 Peter L Jones
//***

// TD-27 default trigger note assignments
// --------------------------------------
// The DAW will need to map incoming MIDI notes to the triggers for the kit.
// The default note assignments in the module are:
//
// Kick note                36
// Snare head note          38
// Snare rim note           40
// Snare brush note         23
// Snare xstick note        37
// Tom 1 head note          48
// Tom 1 rim note           50
// Tom 2 head note          45
// Tom 2 rim note           47
// Tom 3 head note          43
// Tom 3 rim note           58
// Hi-hat open bow note     46
// Hi-hat open edge note    26
// Hi-hat close bow note    42
// Hi-hat close edge note   22
// Hi-hat pedal note        44
// Hi-hat pedal splash note 97 (undocumented)
// Crash 1 bow note         49
// Crash 1 edge note        55
// Crash 2 bow note         57
// Crash 2 edge note        52
// Ride bow note            51
// Ride edge note           59
// Ride bell note           53
// Aux 1 head note          27
// Aux 1 rim note           28
// Aux 2 head note          29
// Aux 2 rim note           30
// Aux 3 head note          31
// Aux 3 rim note           32
//
// --------------------------------------

<control>
 // hint_ram_based=1
 octave_offset=0
 set_cc7=127
 set_cc10=64

@EOF
				if [[ "${hh}" == "-" ]]
				then
					echo ' set_cc4=0    label_cc4=Pedal (cc4)'
				else
					echo ' set_cc4=127  label_cc4=Pedal (cc4)'
				fi
				# Mixer controls
				# volume_cc<CC> assignments and labels for each kit piece
				# start at CC14 ("undefined")
				cc=13
				echo " set_hdcc${cc}=0.5   label_cc${cc}=Vol Ctrls follow"
				echo " // ... hat for inches ... because double-quote blows up ..."
				((cc++))
				declare -A volume_cc
				for cy in ${cys[@]} ${k[cymbals]}
				do
					echo " set_hdcc${cc}=0.5   label_cc${cc}=$(sed -e 's/cy\([^_]*\)_/\1” /' <<<"${cy}") (cc${cc})"
					volume_cc[${cy}]=${cc}
					((cc++))
				done
				echo " set_hdcc${cc}=0.5   label_cc${cc}=hihat (cc${cc})"
				volume_cc[hihat]=${cc}
				((cc++))
				echo " set_hdcc${cc}=0.5   label_cc${cc}=kick (cc${cc})"
				volume_cc[kick]=${cc}
				((cc++))
				echo " set_hdcc${cc}=0.5   label_cc${cc}=snare (cc${cc})"
				volume_cc[snare]=${cc}
				((cc++))
				for (( ti = 0; ti < ${#actual_toms[@]}; ti++ ))
				do
					tm=${t[$ti]}
					echo " set_hdcc${cc}=0.5   label_cc${cc}=$(sed -e 's/tm\(.*\)/\1” tom/' <<<"${tm}") (cc${cc})"
					volume_cc[${tm}]=${cc}
					((cc++))
				done
				echo " set_hdcc${cc}=0.5   label_cc${cc}=cowbell (cc${cc})"
				volume_cc["cowbell"]=${cc}
				((cc++))
				echo " set_hdcc${cc}=0.5   label_cc${cc}=tambourine (cc${cc})"
				volume_cc["tambourine"]=${cc}
				((cc++))

				cat <<-'@EOF'
<global>
 // disable volume and pan controllers
 volume_cc7=0
 pan_cc10=0

 // play samples in full, ignoring note off
 loop_mode=one_shot

 // when sample release is triggered by an off_by group, set a noticable release for ambience
 off_mode=normal
 ampeg_release=.5

@EOF
				key=1
				for cy in ${cys[@]} ${k[cymbals]}
				do
					echo '<master>'
					echo " volume=$(dc -e "${cy_volume[${btr}-${cy}]/#-/_} 12 - p")"
					echo " volume_cc${volume_cc[$cy]}=24 volume_curvecc${volume_cc[$cy]}=1"
					override_defines "triggers/${btr}/${cy}.sfzh" key
				done

				echo '<master>'
				echo " volume=$(dc -e "${hh_volume[${btr}-${the_hihat}]/#-/_} 12 - p")"
				echo " volume_cc${volume_cc[hihat]}=24 volume_curvecc${volume_cc[hihat]}=1"
				if [[ $hh == - ]]
				then
					override_defines "triggers/${btr}/${k[hihats]}.sfzh" key
				else
					override_defines "triggers/${btr}/${k[hihats]}_invcc4.sfzh" key
				fi

				echo '<master>'
				kick=${k[kicks]}
				[[ -v kick_volume[$kick] ]] || { echo >&2 "kick_volume[$kick] not set {${!kick_volume[@]}}"; exit 1; }
				echo " volume=$(dc -e "${kick_volume[$kick]/#-/_} 12 - p")"
				echo " volume_cc${volume_cc[kick]}=24 volume_curvecc${volume_cc[kick]}=1"
				override_defines "triggers/ped/${k[kicks]}_snare_${snare}.sfzh" key

				echo '<master>'
				sn=${k[snares]}
				[[ -v sn_volume["${btr}-${sn}"] ]] || { echo >&2 "sn_volume[$sn] not set {${!sn_volume[@]}}"; exit 1; }
				echo " volume=$(dc -e "${sn_volume[${btr}-${sn}]/#-/_} 12 - p")"
				override_defines "triggers/${btr}/${k[snares]}_snare_${snare}.sfzh" key

				for (( ti = 0; ti < ${#actual_toms[@]}; ti++ ))
				do
					tm=${actual_toms[$ti]}
					tt=${t[$ti]}
					echo '<master>'
					echo " volume=$(dc -e "${tm_volume[$tt]/#-/_} 12 - p")"
					echo " volume_cc${volume_cc[$tt]}=24 volume_curvecc${volume_cc[$tt]}=1"
					override_defines "triggers/${btr}/${tm}.sfzh" key
				done

				echo '<master>'
				echo " volume=$(dc -e "${cowbell_volume[$btr]/#-/_} 12 - p")"
				echo " volume_cc${volume_cc[cowbell]}=24 volume_curvecc${volume_cc[cowbell]}=1"
				override_defines "triggers/${btr}/pn8_cowbell.sfzh" key

				echo '<master>'
				echo ' volume=-1'
				echo " volume_cc${volume_cc[tambourine]}=24 volume_curvecc${volume_cc[tambourine]}=1"
				if [[ -f "triggers/${btr}/pn9_tambourine.sfzh" ]]
				then
					override_defines "triggers/${btr}/pn9_tambourine.sfzh" key
				else
					override_defines "triggers/hnd/pn9_tambourine.sfzh" key
				fi
				} > "_kits/${f}"
			done
		done
	done

	unset -n k
	unset -n t
done
