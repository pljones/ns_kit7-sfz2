#!/usr/bin/env bash
set -euo pipefail

# Require bash >= 4.3 for declare -n and namerefs
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
  echo "This script requires bash >= 4.3" >&2
  exit 1
fi

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


kits=(bop bop_muted bop_open dead funk jungle metal orleans piccolo rock tight)
for kit in ${kits[@]}
do
	declare -A $kit
done
bop=(      [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop       [toms]=bop)
bop_muted=([cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop_muted [toms]=bop)
bop_open=( [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop_open  [toms]=bop)
dead=(     [cymbals]=cy19_ride   [hihats]=hh14 [kicks]=kd22_noreso [snares]=sn12_dead      [toms]=dry)
funk=(     [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd20_punch  [snares]=sn12_funk      [toms]=rock)
jungle=(   [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn10_jungle    [toms]=bop)
metal=(    [cymbals]=cy19_sizzle [hihats]=hh13 [kicks]=kd22_boom   [snares]=sn14_metal     [toms]=noreso)
orleans=(  [cymbals]=cy19_ride   [hihats]=hh14 [kicks]=kd22_boom   [snares]=sn12_orleans   [toms]=rock)
piccolo=(  [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd22_noreso [snares]=sn10_piccolo   [toms]=dry)
rock=(     [cymbals]=cy19_ride   [hihats]=hh13 [kicks]=kd20_punch  [snares]=sn14_rock      [toms]=rock)
tight=(    [cymbals]=cy19_ride   [hihats]=hh14 [kicks]=kd20_full   [snares]=sn12_tight     [toms]=rock)

cys=(cy8_splash cy9_splash cy12_splash cy15_crash cy18_crash cy19_china cy20_ride)

declare -A actual_toms
tms=(tm8 tm10 tm12 tm14 tm16)

function common_override () {
	local trigger_file=$1; shift || { echo "common_override: Missing trigger_file" >&2; exit 1; }
	local -n key_ref=$1  ; shift || { echo "common_override: Missing key_ref" >&2; exit 1; }

	# the <master> line was done by the call, we take care of defines and includes
	grep -v '^\(#define\|<master>\|#include\|//\|$\)' "${trigger_file}" || :

	# slurp the existing file
	mapfile -t triggers < "${trigger_file}"

	i=0
	while [[ $i -lt ${#triggers[@]} ]]
	do
		line=${triggers[$i]}
		(( i += 1 ))
		if [[ "$line" =~ ^(#define  *)(\$[^ ]* )([0-9][0-9]*)$ ]]
		then
			printf '%s %s %03d\n' ${BASH_REMATCH[1]} ${BASH_REMATCH[2]} $key_ref
			(( key_ref += 1 ))
		fi
	done
}

function override_defines () {
	local trigger_file=$1; shift || { echo "override_defines: Missing trigger_file" >&2; exit 1; }
	local -n _key_ref=$1 ; shift || { echo "override_defines: Missing key_ref" >&2; exit 1; }

	local my_key=${_key_ref}

	common_override "${trigger_file}" my_key
	_key_ref=$my_key

	# make sure the include line follows the defines
	grep '^#include' "${trigger_file}"
}

function hihat_overrides () {
	local hh=$1; shift || { echo "hihat_overrides: Missing hh" >&2; exit 1; }
	local btr=$1; shift || { echo "hihat_overrides: Missing btr" >&2; exit 1; }
	local -n _key_ref=$1 ; shift || { echo "hihat_overrides: Missing key_ref" >&2; exit 1; }

	local my_key=${_key_ref}

	echo ''
	echo '<master>'
	echo " volume=-6.00 gain_cc${gain_cc[hihat]}=24 volume_curvecc${gain_cc[hihat]}=1"

	for the_hihat_beater in $btr ped spl
	do
		if [[ $hh == - ]]
		then
			common_override "triggers/${the_hihat_beater}/${k[hihats]}.sfzh" my_key
		else
			common_override "triggers/${the_hihat_beater}/${k[hihats]}_invcc4.sfzh" my_key
		fi
	done

	for the_hihat_beater in $btr ped spl
	do
		if [[ $hh == - ]]
		then
			grep '^#include' "triggers/${the_hihat_beater}/${k[hihats]}.sfzh"
		else
			grep '^#include' "triggers/${the_hihat_beater}/${k[hihats]}_invcc4.sfzh"
		fi

	done

	_key_ref=$my_key

}

function tom_overrides () {
	local trigger_file=$1; shift || { echo "tom_overrides: Missing trigger_file" >&2; exit 1; }
	local -n _key_ref=$1 ; shift || { echo "tom_overrides: Missing key_ref" >&2; exit 1; }
	local actual_tom=$1  ; shift || { echo "tom_overrides: Missing actual tom" >&2; exit 1; }
	local tom=$1         ; shift || { echo "tom_overrides: Missing tom" >&2; exit 1; }

	local my_key=${_key_ref}
	local random_file=/tmp/$$.tmp

	common_override "${trigger_file}" my_key > "$random_file"
	_key_ref=$my_key

	if [[ "${actual_tom}" == "${tom}" ]]
	then
		cat "$random_file"
		rm -f "$random_file"
		# make sure the include line follows the defines
		grep '^#include' "${trigger_file}"
		return
	fi

	sed -e 's/\$\<'${actual_tom}'_/$'${tom}'_/g' "$random_file"
	rm -f "$random_file"
	echo >&2 "_key_ref {$_key_ref}; my_key {$my_key}"

	echo >&2 "OK, need to read the filename from {${trigger_file}} (actual_tom {$actual_tom}; tom {$tom})..."
	read -r unused include_file < <(grep '^#include' "${trigger_file}")
	sed -e 's/\$\<'${actual_tom}'_/$'${tom}'_/g' ${include_file//\"/}
}

rm -rf _kits
mkdir _kits

for kit in ${kits[@]}
do
	echo --- $kit ---
	declare -n k=$kit
	declare -a c=(${cys[@]} ${k[cymbals]})
	the_hihat=${k[hihats]}


	for btr in brs hnd mlt stx
	do
		if [[ "$kit" == "bop" && "$btr" == "stx" ]] || [[ "$btr" != "stx" && "$kit" =~ ^bop_ ]]
		then
			continue
		fi

		for cy in "${c[@]}"
		do
			if [[ ! -f "triggers/${btr}/${cy}.sfzh" ]]
			then
				echo "${kit} ${btr} has no ${cy} cymbal" >&2
				exit 1
			fi
		done

		if [[ ! -f "triggers/${btr}/${k[hihats]}.sfzh" ]]
		then
			echo "${kit} ${btr} has no ${k[hihats]} hihat" >&2
			exit 1
		fi

		for snare in off on
		do
			[[ -f "triggers/${btr}/${k[snares]}_snare_${snare}.sfzh" ]] || {
				continue
			}

			if [[ ! -f "triggers/ped/${k[kicks]}_snare_${snare}.sfzh" ]]
			then
				 echo "${kit} snare ${snare} has no ${k[kicks]} kick" >&2
				 exit 1
			fi

			# Available toms for this beater, tuning, snare
			actual_toms=()
			# tm12_rock_snare_off.sfzh
			for tm in "${tms[@]}"
			do
				f="triggers/${btr}/${tm}_${k[toms]}_snare_${snare}.sfzh"
				if [[ -f "$f" ]]
				then
					actual_toms[${tm}]="${tm}_${k[toms]}_snare_${snare}"
					continue
				fi

				echo -n "${kit}: ${btr} (${k[toms]}) snare ${snare} has no ${tm}"

				# try the opposite snare state
				replacement_snare=$([[ "$snare" == "on" ]] && echo off || echo on)
				f="triggers/${btr}/${tm}_${k[toms]}_snare_${replacement_snare}.sfzh"
				if [[ -f "$f" ]]
				then
					actual_toms[${tm}]="${tm}_${k[toms]}_snare_${replacement_snare}"
					echo " - replacing with opposite snare {${actual_toms[${tm}]}}"
					continue
				fi

				# fall back to the last tom we found (or the next if none yet)
				if [[ "${#actual_toms[@]}" -gt 0 ]]
				then
					replacement_tom="${tms[$((${#actual_toms[@]} - 1))]}"
					actual_toms[${tm}]="${actual_toms[${replacement_tom}]}"  # duplicate last found tom
					echo " - replacing with previous tom {${actual_toms[${tm}]}}"
					continue
				fi

				# look ahead for the next tom that exists
				# - find the index of current tom in tms array
				current_index=0
				while [[ $current_index -lt ${#tms[@]} && "${tms[$current_index]}" != "$tm" ]]
				do
					((current_index++))
				done

				replacement_tom=""
				# - check each tom after current one
				for ((i=current_index+1; i<${#tms[@]}; i++))
				do
					later_tm=${tms[$i]}

					f="triggers/${btr}/${later_tm}_${k[toms]}_snare_${snare}.sfzh"
					if [[ -f "$f" ]]
					then
						replacement_tom="${later_tm}_${k[toms]}_snare_${snare}"
						break
					fi
					# also try opposite snare state
					f="triggers/${btr}/${later_tm}_${k[toms]}_snare_${replacement_snare}.sfzh"
					if [[ -f "$f" ]]
					then
						replacement_tom="${later_tm}_${k[toms]}_snare_${replacement_snare}"
						break
					fi
					# ... continue looking
				done

				if [[ -n "$replacement_tom" ]]
				then
					actual_toms[${tm}]="$replacement_tom"
					echo " - replacing with next available tom {${actual_toms[${tm}]}}"
				else
					echo ''
					echo "${kit} ${btr} snare ${snare} has no ${tm} tom" >&2
					exit 1
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
				gain_cc[brush]=${cc}
				((cc++))
				for tm in "${tms[@]}"
				do
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
					echo " volume=-6.00 gain_cc${gain_cc[$cy]}=24 volume_curvecc${gain_cc[$cy]}=1"
					override_defines "triggers/${btr}/${cy}.sfzh" key
				done

				hihat_overrides ${hh} ${btr} key

				echo ''
				echo '<master>'
				echo " volume=-6.00 gain_cc${gain_cc[kick]}=24 volume_curvecc${gain_cc[kick]}=1"
				override_defines "triggers/ped/${k[kicks]}_snare_${snare}.sfzh" key

				echo ''
				echo '<master>'
				echo " volume=-6.00 gain_cc${gain_cc[snare]}=24 volume_curvecc${gain_cc[snare]}=1"
				[[ "${btr}" == "brs" ]] && echo " gain_cc${gain_cc[brush]}=-12 volume_curvecc${gain_cc[brush]}=4"
				override_defines "triggers/${btr}/${k[snares]}_snare_${snare}.sfzh" key

				for tm in "${tms[@]}"
				do
					atm="${actual_toms[$tm]}"
					echo ''
					echo '<master>'
					echo " volume=-6.00 gain_cc${gain_cc[$tm]}=24 volume_curvecc${gain_cc[$tm]}=1"
					tom_overrides "triggers/${btr}/${atm}.sfzh" key "$(
						echo $atm | sed -e 's!^triggers/.../!!' -e 's/_.*$//g'
					)" "$tm"
				done

				echo ''
				echo '<master>'
				echo " volume=-6.00 gain_cc${gain_cc[cowbell]}=24 volume_curvecc${gain_cc[cowbell]}=1"
				override_defines "triggers/${btr}/pn8_cowbell.sfzh" key

				echo ''
				echo '<master>'
				echo " volume=-6.00 gain_cc${gain_cc[tambourine]}=24 volume_curvecc${gain_cc[tambourine]}=1"
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
