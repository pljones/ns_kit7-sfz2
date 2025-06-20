#!/bin/bash -eu
: <<-'@EOF'
One idea is to have one file containing an include for a kit piece trigger along with its kit piece "group" include
for each kit piece and load each of those as separate Sforzando instances.

This allows "time since note on" to be used (as "note on" is "instrument on") for things like choking.

It also means putting together kits is "easier"
- each beater type separate
  - snare on / off separate
- but different tunings of drums and different selections of cymbals would all be in the one "kit" for switching in and out quickly
@EOF

# kit layout (joy of ASCII art) for ns_kit7 generic

#             ( 8" splash )      ( 9" spash )
#                      ( 15" crash )
#       ( 19" ride )     (T2)  (T3)
#                   (T1)   (KICK)    ( 19" china )
#  ( 18" crash ) (SN)               (T4)   ( 12" splash )
#            (HH)                       ( 20" ride )
#                                     (T5)

# kit layout for TD-27KV2

#           (CR1)          (CR2)
#                (T1)  (T2)       (DR)
#                              (T3)
#            (HH)       (KICK)
#                  (SN)

# TD-27KV2 default cymbal MIDI assignments

# AUX 1 as a cymbal:  BOW 31, EDGE 32; position AUX1CC tbc (?? Note: 27, 28)
# AUX 2 as a cymbal:  BOW 33, EDGE 34; position AUX2CC tbc (?? Note: 29, 30)

# splash_8 (sws/ord/rol grb bel)
#        brs hnd mlt stx
#    BOW sws ord rol ord - $AUXnCC < 16 for stx-bel
#   EDGE ord ord ord ord - AT > 64 for grb

# splash_9 (sws/ord/rol grb)
#        brs hnd mlt stx
#    BOW sws ord rol ord
#   EDGE ord ord ord ord - AT > 64 for grb

# china_19 (sws/ord/rol/top grb)
#        brs hnd mlt stx
#    BOW sws ord rol top
#   EDGE ord ord ord ord - AT > 64 for grb

# splash_12 (sws/ord/rol/top grb bel rim)
#        brs hnd mlt stx
#    BOW sws ord rol top - $AUXnCC < 16 for stx-bel - if AT > 64 stx-rim
#   EDGE ord ord ord ord - AT > 64 for grb

# CRASH 1: BOW 49, EDGE 55; position $CR1CC (to be defined)
# crash_15 (sws/ord/rol/top grb bel rim)
#        brs hnd mlt stx
#    BOW sws ord rol top - $CR1CC < 16 for stx-bel - if AT > 64 stx-rim
#   EDGE ord ord ord ord - AT > 64 for grb

# CRASH 2: BOW 57, EDGE 52; position $CR2CC (to be defined)
# crash_18 (sws/ord/rol/top grb bel rim)
#        brs hnd mlt stx
#    BOW sws ord rol top - $CR2CC < 16 for stx-bel - if AT > 64 stx-rim
#   EDGE ord ord ord ord - AT > 64 for grb


# RIDE: BELL 53, BOW 51, EDGE 59; position CC17
# ride_19 (sws/ord/rol/top bel crs elv, grb/grc/grt rim)
#        brs hnd mlt stx
#   BELL bel ord bel bel - AT > 64 for stx-rim
#    BOW sws ord rol ord - AT > 64 for stx-grt - $RDPCC > 96 for stx-elv
#   EDGE ord ord ord crs - AT > 64 for grb/stx-grc

# ride_20 (sws/ord/rol/top bel elv, grb rim)
#        brs hnd mlt stx
#   BELL bel ord bel bel - AT > 64 for stx-rim
#    BOW sws ord rol ord - $RDPCC > 96 for stx-elv
#   EDGE ord ord ord rim - AT > 64 for grb

# sizzle_19 (sws/ord/rol/top bel elv, grb)
#        brs hnd mlt stx
#   BELL bel ord bel bel
#    BOW sws ord ord ord - $RDPCC > 96 for stx-elv
#   EDGE ord ord ord crs - AT > 64 for grb

# Selector AUX1/CR1: crash_18; ride_19; sizzle_19; splash_8
# Selector AUX2/CR2: splash_9; china_19; splash_12
# Selector DR:       ride_20; (l/r) ride_19; (l/r) sizzle_19

# So, TD-27KV2 cymbal triggers:
# #define $cy_aux1_top 27
# #define $cy_aux1_rim 28
# #define $cy_aux2_top 29
# #define $cy_aux2_rim 30
# #define $cy_cr1_top  49
# #define $cy_cr1_rim  55
# #define $cy_cr2_top  57
# #define $cy_cr2_rim  52
# #define $cy_dr_bel   53
# #define $cy_dr_top   51
# #define $cy_dr_rim   59
# #define $cy_aux1_sel tbc
# #define $cy_aux2_sel tbc
# #define $cy_cr1_sel  tbc
# #define $cy_cr2_sel  tbc
# #define $cy_dr_sel   017
# <control>
#  set_cc$cy_aux1_CC=064  label_cc$cy_aux1_CC=AUX1 posn  (cc$cy_aux1_CC)
#  set_cc$cy_aux2_CC=064  label_cc$cy_aux2_CC=AUX2 posn  (cc$cy_aux2_CC)
#  set_cc$cy_cr1_CC=064   label_cc$cy_cr1_CC=CR1 posn   (cc$cy_cr1_CC)
#  set_cc$cy_cr2_CC=064   label_cc$cy_cr2_CC=CR2 posn   (cc$cy_cr2_CC)
#  set_cc$cy_dr_CC=064    label_cc$cy_dr_CC=Ride posn  (cc$cy_dr_CC)

function override_defines () {
	local trigger_file=$1; shift || { echo "override_defines: Missing trigger_file" >&2; exit 1; }
	local -n key_ref=$1  ; shift || { echo "override_defines: Missing key_ref" >&2; exit 1; }

	echo ''
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


for kit in ${kits[@]}
do
	echo --- $kit ---
	declare -n k=$kit
	declare -a c=(${cys[@]} ${k[cymbals]})
	declare -n t=tm_${k[toms]}

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
			[[ -f "triggers/${btr}/${cy}.inc" ]] || { echo "${kit} ${btr} snare ${snare} has no ${cy}"; continue; }
		done
		[[ -f "triggers/${btr}/${k[hihats]}.inc" ]] || { echo "${kit} ${btr} snare ${snare} has no ${k[hihats]}"; continue; }
		for snare in off on
		do
			[[ -f "triggers/${btr}/${k[snares]}_snare_${snare}.inc" ]] || {
				# echo "${kit} ${btr} snare ${snare} has no ${k[snares]}";
				continue;
			}
			[[ -f "triggers/ped/${k[kicks]}_snare_${snare}.inc" ]] || { echo "${kit} snare ${snare} has no ${k[kicks]}"; continue; }
			actual_toms=()
			# tm12_rock_snare_off.inc
			for tm in "${t[@]}"
			do
				f="triggers/${btr}/${tm}_${k[toms]}_snare_${snare}.inc"
				if [[ ! -f $f ]]
				then
					x="sn${snare}_btr${btr}_toms${k[toms]}"
#echo >&2 "f {$f}; snare {$snare}; btr {$btr}; toms {${k[toms]}}; x {$x}"
					echo -n "${kit} ${btr} (${k[toms]}) snare ${snare} has no ${tm}";
					case $x in
						snon_btrbrs_tomsbop|snon_btrstx_tomsbop|snon_btrstx_tomsnoreso)
							actual_toms+=(${tm}_${k[toms]}_snare_off)
							echo '... will use snare_off tom, then'
							;;
						*)
							echo ''
							;;
					esac
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

// ------------------------------------------------------------------

<control>
 hint_ram_based=1
 octave_offset=0
 set_cc7=127  set_cc10=64
 set_cc4=127  label_cc4=Pedal (cc4)
 set_cc16=0   label_cc16=GP1
 set_cc17=0   label_cc17=GP2
 set_cc18=0   label_cc18=GP3
 set_cc19=0   label_cc19=GP4
 set_cc48=0   label_cc48=GP5
 set_cc49=0   label_cc49=GP6
 set_cc50=0   label_cc50=GP7
 set_cc51=0   label_cc51=GP8

  
<global>
 loop_mode=one_shot off_mode=normal
 volume_cc7=0 pan_cc10=0
 ampeg_release=.2

@EOF
				key=1
				for cy in ${cys[@]} ${k[cymbals]}
				do
					override_defines "triggers/${btr}/${cy}.inc" key
				done
				if [[ $hh == - ]]
				then
					override_defines "triggers/${btr}/${k[hihats]}.inc" key
				else
					override_defines "triggers/${btr}/${k[hihats]}_invcc4.inc" key
				fi
				override_defines "triggers/ped/${k[kicks]}_snare_${snare}.inc" key
				override_defines "triggers/${btr}/${k[snares]}_snare_${snare}.inc" key
				for tm in ${actual_toms[@]}
				do
					override_defines "triggers/${btr}/${tm}.inc" key
				done
				if [[ -f "triggers/${btr}/pn8_cowbell.inc" ]]
				then
					override_defines "triggers/${btr}/pn8_cowbell.inc" key
				else
					# here we need to know how much to add to key - guess for now
					(( key += 2 ))
				fi
				if [[ -f "triggers/${btr}/pn9_tambourine.inc" ]]
				then
					override_defines "triggers/${btr}/pn9_tambourine.inc" key
				else
					# here we need to know how much to add to key - guess for now
					(( key += 5 ))
				fi
				} > "_kits/${f}"
			done
		done
	done

	unset -n k
	unset -n t
done
