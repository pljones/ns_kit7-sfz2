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
bop=(      [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop       [toms]=tm_bop)
bop_muted=([hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop_muted [toms]=tm_bop)
bop_open=( [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop_open  [toms]=tm_bop)
dead=(     [hihats]=hh14 [kicks]=kd22_noreso [snares]=sn12_dead      [toms]=tm_dry)
funk=(     [hihats]=hh13 [kicks]=kd20_punch  [snares]=sn12_funk      [toms]=tm_rock)
jungle=(   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn10_jungle    [toms]=tm_bop)
metal=(    [hihats]=hh13 [kicks]=kd22_boom   [snares]=sn14_metal     [toms]=tm_noreso)
orleans=(  [hihats]=hh14 [kicks]=kd22_boom   [snares]=sn12_orleans   [toms]=tm_rock)
piccolo=(  [hihats]=hh13 [kicks]=kd22_noreso [snares]=sn10_piccolo   [toms]=tm_dry)
rock=(     [hihats]=hh13 [kicks]=kd20_punch  [snares]=sn14_rock      [toms]=tm_rock)
tight=(    [hihats]=hh14 [kicks]=kd20_full   [snares]=sn12_tight     [toms]=tm_rock)

cys=(cy8_splash cy9_splash cy12_splash cy15_crash cy18_crash cy19_china cy20_ride cy19_ride cy19_sizzle)

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

		echo ''
		echo '<master>'
		echo " volume=$(
			case "${the_hihat_beater}" in
				"spl") echo '9.00'  ;;
				"ped") echo '3.00'  ;;
				*)     echo '-6.00' ;;
			esac) gain_cc${gain_cc[hihat]}=24 volume_curvecc${gain_cc[hihat]}=1"

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
	#echo >&2 "_key_ref {$_key_ref}; my_key {$my_key}"

	#echo >&2 "OK, need to read the filename from {${trigger_file}} (actual_tom {$actual_tom}; tom {$tom})..."
	read -r unused include_file < <(grep '^#include' "${trigger_file}")
	sed -e 's/\$\<'${actual_tom}'_/$'${tom}'_/g' ${include_file//\"/}
}

function build_actual_toms () {
	local btr=$1             ; shift || { echo "build_actual_toms: Missing btr" >&2; exit 1; }
	local snare=$1           ; shift || { echo "build_actual_toms: Missing snare" >&2; exit 1; }
	local kit=$1             ; shift || { echo "build_actual_toms: Missing kit" >&2; exit 1; }
	local -n _k=$1           ; shift || { echo "build_actual_toms: Missing kit config" >&2; exit 1; }
	local -n _actual_toms=$1 ; shift || { echo "build_actual_toms: Missing actual_toms array" >&2; exit 1; }

	# Available toms for this beater, tuning, snare
	_actual_toms=()

	local t="${_k[toms]#tm_}"
	# tm12_rock_snare_off.sfzh
	for tm in "${tms[@]}"
	do
		f="triggers/${btr}/${tm}_${t}_snare_${snare}.sfzh"
		if [[ -f "$f" ]]
		then
			_actual_toms[${tm}]="${tm}_${t}_snare_${snare}"
			continue
		fi

		#echo -n "${kit}: ${btr} (${_k[toms]}) snare ${snare} has no ${tm}"

		# try the opposite snare state
		replacement_snare=$([[ "$snare" == "on" ]] && echo off || echo on)
		f="triggers/${btr}/${tm}_${t}_snare_${replacement_snare}.sfzh"
		if [[ -f "$f" ]]
		then
			_actual_toms[${tm}]="${tm}_${t}_snare_${replacement_snare}"
			#echo " - replacing with opposite snare {${_actual_toms[${tm}]}}"
			continue
		fi

		# fall back to the last tom we found (or the next if none yet)
		if [[ "${#_actual_toms[@]}" -gt 0 ]]
		then
			replacement_tom="${tms[$((${#_actual_toms[@]} - 1))]}"
			_actual_toms[${tm}]="${_actual_toms[${replacement_tom}]}"  # duplicate last found tom
			#echo " - replacing with previous tom {${_actual_toms[${tm}]}}"
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

			f="triggers/${btr}/${later_tm}_${t}_snare_${snare}.sfzh"
			if [[ -f "$f" ]]
			then
				replacement_tom="${later_tm}_${t}_snare_${snare}"
				break
			fi
			# also try opposite snare state
			f="triggers/${btr}/${later_tm}_${t}_snare_${replacement_snare}.sfzh"
			if [[ -f "$f" ]]
			then
				replacement_tom="${later_tm}_${t}_snare_${replacement_snare}"
				break
			fi
			# ... continue looking
		done

		if [[ -n "$replacement_tom" ]]
		then
			_actual_toms[${tm}]="$replacement_tom"
			#echo " - replacing with next available tom {${_actual_toms[${tm}]}}"
		else
			#echo ''
			echo "${kit} ${btr} snare ${snare} has no ${tm} tom" >&2
			exit 1
		fi

	done
}

function echo_kit_header () {
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
}

function echo_global_header () {
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
}

function do_cymbal_group () {
	local -n _cc=$1; shift || { echo "do_cymbal_group: Missing cc" >&2; exit 1; }
	local -n _key=$1 ; shift || { echo "do_cymbal_group: Missing key_ref" >&2; exit 1; }

	echo_kit_header

	for cy in ${cys[@]}
	do
		echo " set_hdcc${_cc}=0.5   label_cc${_cc}=$(sed -e 's/cy\([^_]*\)_/\1” /' <<<"${cy}") (cc${_cc})"
		gain_cc[${cy}]=${_cc}
		((_cc++))
	done

	echo_global_header

	for cy in ${cys[@]}
	do
		echo ''
		echo '<master>'
		echo " volume=-6.00 gain_cc${gain_cc[$cy]}=24 volume_curvecc${gain_cc[$cy]}=1"
		override_defines "triggers/${btr}/${cy}.sfzh" _key
	done
}

function do_hihat_group () {
	local hh=$1; shift || { echo "do_hihat_group: Missing hh" >&2; exit 1; }
	local -n _cc=$1; shift || { echo "do_hihat_group: Missing cc" >&2; exit 1; }
	local -n _key=$1 ; shift || { echo "do_hihat_group: Missing key_ref" >&2; exit 1; }

	echo_kit_header

	if [[ "$hh" == "-" ]]
	then
		echo ' set_cc4=0    label_cc4=Pedal (cc4)'
	else
		echo ' set_cc4=127  label_cc4=Pedal (cc4)'
	fi
	echo " set_hdcc${_cc}=0.5   label_cc${_cc}=hihat (cc${_cc})"
	gain_cc[hihat]=${_cc}
	((_cc++))

	echo_global_header

	hihat_overrides ${hh} ${btr} _key
}

function do_kick_group () {
	local -n _cc=$1; shift || { echo "do_kick_group: Missing cc" >&2; exit 1; }
	local -n _key=$1 ; shift || { echo "do_kick_group: Missing key_ref" >&2; exit 1; }
	
	echo " set_hdcc${_cc}=0.5   label_cc${_cc}=kick (cc${_cc})"
	gain_cc[kick]=${_cc}
	((_cc++))

	echo_global_header

	echo ''
	echo '<master>'
	echo " volume=-6.00 gain_cc${gain_cc[kick]}=24 volume_curvecc${gain_cc[kick]}=1"
	override_defines "triggers/ped/${k[kicks]#tm_}_snare_${snare}.sfzh" _key
}

function do_snare_group () {
	local -n _cc=$1; shift || { echo "do_snare_group: Missing cc" >&2; exit 1; }
	local -n _key=$1 ; shift || { echo "do_snare_group: Missing key_ref" >&2; exit 1; }

	echo_kit_header

	echo " set_hdcc${_cc}=0.5   label_cc${_cc}=snare (cc${_cc})"
	gain_cc[snare]=${_cc}
	((_cc++))
	gain_cc[brush]=${_cc}
	((_cc++))

	echo_global_header

	echo ''
	echo '<master>'
	echo " volume=-6.00 gain_cc${gain_cc[snare]}=24 volume_curvecc${gain_cc[snare]}=1"
	[[ "${btr}" == "brs" ]] && echo " gain_cc${gain_cc[brush]}=-12 volume_curvecc${gain_cc[brush]}=4"
	override_defines "triggers/${btr}/${k[snares]}_snare_${snare}.sfzh" _key
}

function do_tom_group () {
	local -n _cc=$1; shift || { echo "do_tom_group: Missing cc" >&2; exit 1; }
	local -n _key=$1 ; shift || { echo "do_tom_group: Missing key_ref" >&2; exit 1; }
	local -n _actual_toms=$1 ; shift || { echo "do_tom_group: Missing actual_toms array" >&2; exit 1; }

	echo_kit_header

	for tm in "${tms[@]}"
	do
		echo " set_hdcc${_cc}=0.5   label_cc${_cc}=$(sed -e 's/tm\(.*\)/\1” tom/' <<<"${tm}") (cc${_cc})"
		gain_cc[${tm}]=${_cc}
		((_cc++))
	done

	echo_global_header

	for tm in "${tms[@]}"
	do
		atm="${_actual_toms[$tm]}"
		echo ''
		echo '<master>'
		echo " volume=-6.00 gain_cc${gain_cc[$tm]}=24 volume_curvecc${gain_cc[$tm]}=1"
		tom_overrides "triggers/${btr}/${atm}.sfzh" _key "$(
			echo $atm | sed -e 's!^triggers/.../!!' -e 's/_.*$//g'
		)" "$tm"
	done
}

function do_cowbell_group () {
	local -n _cc=$1; shift || { echo "do_cowbell_group: Missing cc" >&2; exit 1; }
	local -n _key=$1 ; shift || { echo "do_cowbell_group: Missing key_ref" >&2; exit 1; }

	echo_kit_header

	echo " set_hdcc${_cc}=0.5   label_cc${_cc}=cowbell (cc${_cc})"
	gain_cc["cowbell"]=${_cc}
	((_cc++))

	echo_global_header

	echo ''
	echo '<master>'
	echo " volume=-6.00 gain_cc${gain_cc[cowbell]}=24 volume_curvecc${gain_cc[cowbell]}=1"
	override_defines "triggers/${btr}/pn8_cowbell.sfzh" _key
}

function do_tambourine_group () {
	local -n _cc=$1; shift || { echo "do_tambourine_group: Missing cc" >&2; exit 1; }
	local -n _key=$1 ; shift || { echo "do_tambourine_group: Missing key_ref" >&2; exit 1; }

	echo_kit_header

	echo " set_hdcc${_cc}=0.5   label_cc${_cc}=tambourine (cc${_cc})"
	gain_cc["tambourine"]=${_cc}
	((_cc++))

	echo_global_header

	echo ''
	echo '<master>'
	echo " volume=-6.00 gain_cc${gain_cc[tambourine]}=24 volume_curvecc${gain_cc[tambourine]}=1"
	if [[ -f "triggers/${btr}/pn9_tambourine.sfzh" ]]
	then
		override_defines "triggers/${btr}/pn9_tambourine.sfzh" _key
	else
		override_defines "triggers/hnd/pn9_tambourine.sfzh" _key
	fi
}

rm -rf _kit_piece_groups
mkdir _kit_piece_groups

for kit in ${kits[@]}
do
	echo --- $kit ---
	declare -n k=$kit
	the_hihat=${k[hihats]}


	for btr in brs hnd mlt stx
	do
		if [[ "$kit" == "bop" && "$btr" == "stx" ]] || [[ "$btr" != "stx" && "$kit" =~ ^bop_ ]]
		then
			continue
		fi

		for cy in ${cys[@]}
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
				#echo "${kit} ${btr} has no ${k[snares]} snare with snare ${snare} - skipping kit" >&2
				continue
			}

			if [[ ! -f "triggers/ped/${k[kicks]}_snare_${snare}.sfzh" ]]
			then
				echo "${kit} snare ${snare} has no ${k[kicks]} kick" >&2
				exit 1
			fi

			build_actual_toms "${btr}" "${snare}" "${kit}" k actual_toms

			for hh in - invcc4
			do

				# Keys start at 1
				key=1

				# Mixer controls
				# gain_cc<CC> assignments and labels for each kit piece
				# start at CC14 ("undefined")
				declare -A gain_cc
				cc=14

# cymbals ${btr}/${cy}
# hihats ${btr}/${k[hihats]}
# snare ${btr}/${k[snares]}_snare_${snare}
# kick ${btr}/${k[kicks]}_snare_${snare}
# toms ${btr}/${k[toms]}_snare_${snare} (with actual tom replacement as needed)
# cowbell ${btr}/pn8_cowbell
# tambourine ${btr}/pn9_tambourine

				for kit_piece_group in cymbals ${k[hihats]} ${k[kicks]} ${k[snares]} ${k[toms]} pn8_cowbell pn9_tambourine
				do
					f="${kit_piece_group}"
					if [[ ! "$kit_piece_group" =~ ^(kd|pn9) ]]
					then
						f="${btr}_${kit_piece_group}"
					fi
					if [[ "$kit_piece_group" =~ ^hh && "$hh" != "-" ]]
					then
						f="${f}_invcc4"
					fi
					if [[ "$kit_piece_group" =~ ^(kd|sn|tm) ]]
					then
						f="${f}_snare_${snare}"
					fi
					#echo "kit {$kit}; btr {$btr}; snare {$snare}; hh {$hh}; kit_piece_group {${kit_piece_group}} -> f {$f}"
					f="_kit_piece_groups/${f}.sfz"
					[[ -f "$f" ]] && f="/dev/null" # need to loop to keep the key and cc counts correct, but skip regenerating if already exists

					echo "Making ${btr} ${kit_piece_group}: $f ..."

					case "$kit_piece_group" in
						"cymbals")
							do_cymbal_group cc key > "${f}"
							;;
						hh*)
							do_hihat_group ${hh} cc key > "${f}"
							;;
						kd*)
							do_kick_group cc key > "${f}"
							;;
						sn*)
							do_snare_group cc key > "${f}"
							;;
						tm*)
							do_tom_group cc key actual_toms > "${f}"
							;;
						"pn8_cowbell")
							do_cowbell_group cc key > "${f}"
							;;
						"pn9_tambourine")
							do_tambourine_group cc key > "${f}"
							;;
						*) echo "Unknown kit piece group ${kit_piece_group}" >&2; exit 1 ;;
					esac
				done
				echo "key is $key; cc is $cc"
			done
		done
	done

	unset -n k
done
