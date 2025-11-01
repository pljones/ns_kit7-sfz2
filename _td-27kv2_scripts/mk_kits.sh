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

# Crank each kit piece up to 0dB, allow tweaking using faders (on CCs)
declare -A cy_volume  ;# left, centre and right groups
cy_volume+=([brs-cy8_splash]="19.97" [brs-cy9_splash]="12.61" [brs-cy15_crash]="19.10" [brs-cy18_crash]="13.34" [brs-cy19_ride]="21.37" [brs-cy19_sizzle]="20.40" [brs-cy12_splash]="12.32" [brs-cy19_china]="23.76" [brs-cy20_ride]="13.12")
cy_volume+=([hnd-cy8_splash]="17.73" [hnd-cy9_splash]="17.76" [hnd-cy15_crash]="22.98" [hnd-cy18_crash]="22.88" [hnd-cy19_ride]="22.39" [hnd-cy19_sizzle]="21.90" [hnd-cy12_splash]="18.47" [hnd-cy19_china]="23.39" [hnd-cy20_ride]="26.38")
cy_volume+=([mlt-cy8_splash]="9.85" [mlt-cy9_splash]="8.92" [mlt-cy15_crash]="6.66" [mlt-cy18_crash]="1.82" [mlt-cy19_ride]="12.88" [mlt-cy19_sizzle]="11.63" [mlt-cy12_splash]="2.24" [mlt-cy19_china]="15.58" [mlt-cy20_ride]="7.86")
cy_volume+=([stx-cy8_splash]="5.69" [stx-cy9_splash]="5.95" [stx-cy15_crash]="1.61" [stx-cy18_crash]="0.08" [stx-cy19_ride]="1.11" [stx-cy19_sizzle]="1.07" [stx-cy12_splash]="1.29" [stx-cy19_china]="7.60" [stx-cy20_ride]="0.67")
declare -A hh_volume
hh_volume+=([brs-hh13]="16.68" [brs-hh14]="14.43")
hh_volume+=([hnd-hh13]="20.58" [hnd-hh14]="14.17")
hh_volume+=([mlt-hh13]="13.43" [mlt-hh14]="12.59")
hh_volume+=([stx-hh13]="2.57" [stx-hh14]="3.08")
hh_volume+=([ped-hh13]="13.50" [ped-hh14]="22.22")
hh_volume+=([spl-hh13]="12.54" [spl-hh14]="26.62")
declare -A kick_volume=([kd14_bop]="10.55" [kd20_punch]="2.59" [kd22_noreso]="11.01" [kd22_boom]="6.29" [kd20_full]="6.86")
declare -A sn_volume
# sn brs needs to be quieter
#sn_volume+=([brs-sn12_bop-off]="17.26" [brs-sn12_funk-off]="13.49" [brs-sn14_rock-off]="16.26")
#sn_volume+=([brs-sn12_bop-on]="17.25" [brs-sn12_funk-on]="13.49" [brs-sn14_rock-on]="16.26")
sn_volume+=([brs-sn12_bop-off]="11.26" [brs-sn12_funk-off]="7.49" [brs-sn14_rock-off]="10.26")
sn_volume+=([brs-sn12_bop-on]="11.25" [brs-sn12_funk-on]="7.49" [brs-sn14_rock-on]="10.26")
sn_volume+=([hnd-sn12_bop-off]="19.40" [hnd-sn10_jungle-off]="12.85")
sn_volume+=([hnd-sn12_bop-on]="19.67" [hnd-sn10_jungle-on]="12.85")
sn_volume+=([mlt-sn12_bop-off]="5.32")
sn_volume+=([mlt-sn12_bop-on]="5.38")
sn_volume+=([stx-sn12_bop_muted-off]="7.06" [stx-sn12_bop_open-off]="5.83" [stx-sn10_jungle-off]="3.88" [stx-sn12_funk-off]="1.45" [stx-sn14_rock-off]="3.70" [stx-sn10_piccolo-off]="4.33" [stx-sn12_orleans-off]="1.38" [stx-sn12_tight-off]="0.00" [stx-sn12_dead-off]="1.56" [stx-sn14_metal-off]="0.89")
sn_volume+=([stx-sn12_bop_muted-on]="5.42" [stx-sn12_bop_open-on]="7.34" [stx-sn10_jungle-on]="2.79" [stx-sn12_funk-on]="1.45" [stx-sn14_rock-on]="1.14" [stx-sn10_piccolo-on]="4.33" [stx-sn12_orleans-on]="1.38" [stx-sn12_tight-on]="0.00" [stx-sn12_dead-on]="1.56" [stx-sn14_metal-on]="3.65")
declare -A tm_volume
tm_volume+=([brs-tm8-bop-off]="22.16" [brs-tm10-bop-off]="20.41" [brs-tm12-bop-off]="22.74" [brs-tm14-bop-off]="23.01" [brs-tm16-bop-off]="23.90")
tm_volume+=([brs-tm8-bop-on]="22.16" [brs-tm10-bop-on]="20.41" [brs-tm12-bop-on]="22.74" [brs-tm14-bop-on]="23.01" [brs-tm16-bop-on]="23.90")
tm_volume+=([brs-tm8-rock-off]="16.70" [brs-tm10-rock-off]="17.12" [brs-tm12-rock-off]="16.69" [brs-tm14-rock-off]="18.80" [brs-tm16-rock-off]="19.10")
tm_volume+=([brs-tm8-rock-on]="17.17" [brs-tm10-rock-on]="18.10" [brs-tm12-rock-on]="16.27" [brs-tm14-rock-on]="21.15" [brs-tm16-rock-on]="19.71")
tm_volume+=([hnd-tm8-bop-off]="24.99" [hnd-tm10-bop-off]="25.65" [hnd-tm12-bop-off]="23.49" [hnd-tm14-bop-off]="23.76" [hnd-tm16-bop-off]="22.38")
tm_volume+=([hnd-tm8-bop-on]="24.99" [hnd-tm10-bop-on]="25.65" [hnd-tm12-bop-on]="24.49" [hnd-tm14-bop-on]="22.42" [hnd-tm16-bop-on]="22.38")
tm_volume+=([hnd-tm8-rock-off]="18.92" [hnd-tm10-rock-off]="17.08" [hnd-tm12-rock-off]="17.00" [hnd-tm14-rock-off]="18.01" [hnd-tm16-rock-off]="19.34")
tm_volume+=([hnd-tm8-rock-on]="17.97" [hnd-tm10-rock-on]="17.75" [hnd-tm12-rock-on]="17.17" [hnd-tm14-rock-on]="18.35" [hnd-tm16-rock-on]="22.29")
tm_volume+=([mlt-tm8-bop-off]="9.46" [mlt-tm10-bop-off]="10.59" [mlt-tm12-bop-off]="5.58" [mlt-tm14-bop-off]="9.12" [mlt-tm16-bop-off]="6.54")
tm_volume+=([mlt-tm8-bop-on]="9.46" [mlt-tm10-bop-on]="10.59" [mlt-tm12-bop-on]="12.08" [mlt-tm14-bop-on]="13.47" [mlt-tm16-bop-on]="7.75")
tm_volume+=([mlt-tm8-rock-off]="9.86" [mlt-tm10-rock-off]="12.00" [mlt-tm12-rock-off]="10.14" [mlt-tm14-rock-off]="6.97" [mlt-tm16-rock-off]="9.49")
tm_volume+=([mlt-tm8-rock-on]="10.67" [mlt-tm10-rock-on]="11.33" [mlt-tm12-rock-on]="11.07" [mlt-tm14-rock-on]="9.89" [mlt-tm16-rock-on]="10.72")
tm_volume+=([stx-tm8-bop-off]="5.15" [stx-tm10-bop-off]="3.93" [stx-tm12-bop-off]="11.35" [stx-tm14-bop-off]="2.38" [stx-tm16-bop-off]="5.92")
tm_volume+=([stx-tm8-bop-on]="5.15" [stx-tm10-bop-on]="3.93" [stx-tm12-bop-on]="6.97" [stx-tm14-bop-on]="2.56" [stx-tm16-bop-on]="6.46")
tm_volume+=([stx-tm8-dry-off]="1.53" [stx-tm10-dry-off]="1.53" [stx-tm12-dry-off]="5.75" [stx-tm14-dry-off]="4.61" [stx-tm16-dry-off]="4.61")
tm_volume+=([stx-tm8-dry-on]="4.62" [stx-tm10-dry-on]="4.62" [stx-tm12-dry-on]="5.63" [stx-tm14-dry-on]="5.46" [stx-tm16-dry-on]="5.46")
tm_volume+=([stx-tm8-noreso-off]="1.96" [stx-tm10-noreso-off]="1.96" [stx-tm12-noreso-off]="3.79" [stx-tm14-noreso-off]="5.90" [stx-tm16-noreso-off]="5.90")
tm_volume+=([stx-tm8-noreso-on]="1.96" [stx-tm10-noreso-on]="1.96" [stx-tm12-noreso-on]="3.79" [stx-tm14-noreso-on]="5.90" [stx-tm16-noreso-on]="5.90")
tm_volume+=([stx-tm8-rock-off]="4.35" [stx-tm10-rock-off]="8.19" [stx-tm12-rock-off]="7.81" [stx-tm14-rock-off]="6.00" [stx-tm16-rock-off]="7.47")
tm_volume+=([stx-tm8-rock-on]="4.19" [stx-tm10-rock-on]="8.68" [stx-tm12-rock-on]="6.87" [stx-tm14-rock-on]="6.47" [stx-tm16-rock-on]="7.68")
declare -A cowbell_volume=([brs]="29.08" [hnd]="32.34" [mlt]="26.39" [stx]="15.78")

for kit in ${kits[@]}
do
	echo --- $kit ---
	declare -n k=$kit
	declare -a c=(${cys[@]} ${k[cymbals]})
	declare -n t=tm_${k[toms]}
	the_hihat=${k[hihats]}


	for btr in brs hnd mlt stx
	do
		if [[ "$kit" == "bop" && "$btr" == "stx" ]] || [[ "$btr" != "stx" && "$kit" =~ ^bop_ ]]
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
					echo -n "${kit} ${btr} (${k[toms]}) snare ${snare} has no ${tm}; (x {$x})"
					replacement_snare=$([[ "$snare" == "on" ]] && echo off || echo on)
					actual_toms+=(${tm}_${k[toms]}_snare_${replacement_snare})
					f="triggers/${btr}/${actual_toms[-1]}.sfzh"
					if [[ ! -f "$f" ]]
					then
						echo ''
						echo >&2 "Failed to replace tom (${snare} -> ${replacement_snare}): {$f} not found"
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
 set_hdcc7=1
 set_hdcc10=0.5

@EOF
				if [[ "${hh}" == "-" ]]
				then
					echo ' set_cc4=0    label_cc4=Pedal (cc4)'
				else
					echo ' set_cc4=127  label_cc4=Pedal (cc4)'
				fi

				# Mixer controls
				# gain_cc<CC> assignments and labels for each kit piece
				# start at CC14 ("undefined")
				cc=13
				echo " set_hdcc${cc}=0.5   label_cc${cc}=Vol Ctrls follow"
				((cc++))
				declare -A gain_cc
				for cy in ${cys[@]} ${k[cymbals]}
				do
					echo " set_hdcc${cc}=0.5   label_cc${cc}=$(sed -e 's/cy\([^_]*\)_/\1” /' <<<"${cy}") (cc${cc})"
					gain_cc[${cy}]=${cc}
					((cc++))
				done
				echo " set_hdcc${cc}=0.5   label_cc${cc}=hihat (cc${cc})"
				gain_cc[hihat]=${cc}
				((cc++))
				echo " set_hdcc${cc}=0.5   label_cc${cc}=kick (cc${cc})"
				gain_cc[kick]=${cc}
				((cc++))
				echo " set_hdcc${cc}=0.5   label_cc${cc}=snare (cc${cc})"
				gain_cc[snare]=${cc}
				((cc++))
				for (( ti = 0; ti < ${#actual_toms[@]}; ti++ ))
				do
					tm=${t[$ti]}
					echo " set_hdcc${cc}=0.5   label_cc${cc}=$(sed -e 's/tm\(.*\)/\1” tom/' <<<"${tm}") (cc${cc})"
					gain_cc[${tm}]=${cc}
					((cc++))
				done
				echo " set_hdcc${cc}=0.5   label_cc${cc}=cowbell (cc${cc})"
				gain_cc["cowbell"]=${cc}
				((cc++))
				echo " set_hdcc${cc}=0.5   label_cc${cc}=tambourine (cc${cc})"
				gain_cc["tambourine"]=${cc}
				((cc++))

				cat <<-'@EOF'

<global>
 // disable volume and pan controllers
 gain_cc7=0
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
					echo ''
					echo '<master>'
					echo " volume=$(dc -e "${cy_volume[${btr}-${cy}]/#-/_} 12 - p")"
					echo " gain_cc${gain_cc[$cy]}=24 volume_curvecc${gain_cc[$cy]}=1"
					override_defines "triggers/${btr}/${cy}.sfzh" key
				done

				for the_hihat_beater in $btr ped spl
				do

					echo ''
					echo '<master>'
					echo " volume=$(dc -e "${hh_volume[${the_hihat_beater}-${the_hihat}]/#-/_} 12 - p")"
					echo " gain_cc${gain_cc[hihat]}=24 volume_curvecc${gain_cc[hihat]}=1"
					if [[ $hh == - ]]
					then
						override_defines "triggers/${the_hihat_beater}/${k[hihats]}.sfzh" key
					else
						override_defines "triggers/${the_hihat_beater}/${k[hihats]}_invcc4.sfzh" key
					fi

				done

				echo ''
				echo '<master>'
				kick=${k[kicks]}
				[[ -v kick_volume[$kick] ]] || { echo >&2 "kick_volume[$kick] not set {${!kick_volume[@]}}"; exit 1; }
				echo " volume=$(dc -e "${kick_volume[$kick]/#-/_} 12 - p")"
				echo " gain_cc${gain_cc[kick]}=24 volume_curvecc${gain_cc[kick]}=1"
				override_defines "triggers/ped/${k[kicks]}_snare_${snare}.sfzh" key

				echo ''
				echo '<master>'
				sn=${k[snares]}
				[[ -v sn_volume["${btr}-${sn}-${snare}"] ]] || { echo >&2 "sn_volume[${btr}-${sn}-${snare}] not set {${!sn_volume[@]}}"; exit 1; }
				echo " volume=$(dc -e "${sn_volume[${btr}-${sn}-${snare}]/#-/_} 12 - p")"
				override_defines "triggers/${btr}/${k[snares]}_snare_${snare}.sfzh" key

				for (( ti = 0; ti < ${#actual_toms[@]}; ti++ ))
				do
					tm=${actual_toms[$ti]}
					tt=${t[$ti]}
					[[ -v tm_volume[${btr}-${tt}-${k[toms]}-${snare}] ]] || { echo >&2 "tm_volume[${btr}-${tt}-${k[toms]}-${snare}] not set {${!tm_volume[@]}}"; exit 1; }
					echo ''
					echo '<master>'
					echo " volume=$(dc -e "${tm_volume[${btr}-${tt}-${k[toms]}-${snare}]/#-/_} 12 - p")"
					echo " gain_cc${gain_cc[$tt]}=24 volume_curvecc${gain_cc[$tt]}=1"
					override_defines "triggers/${btr}/${tm}.sfzh" key
				done

				echo ''
				echo '<master>'
				echo " volume=$(dc -e "${cowbell_volume[$btr]/#-/_} 12 - p")"
				echo " gain_cc${gain_cc[cowbell]}=24 volume_curvecc${gain_cc[cowbell]}=1"
				override_defines "triggers/${btr}/pn8_cowbell.sfzh" key

				echo ''
				echo '<master>'
				echo " volume=-19.00"
				echo " gain_cc${gain_cc[tambourine]}=24 volume_curvecc${gain_cc[tambourine]}=1"
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
