#!/bin/bash
cat >/dev/null <<-"EOF"
One idea is to have one file containing an include for a kit piece trigger along with its kit piece "group" include
for each kit piece and load each of those as separate Sforzando instances.

This allows "time since note on" to be used (as "note on" is "instrument on") for things like choking.

It also means putting together kits is "easier"
- each beater type separate
  - snare on / off separate
- but different tunings of drums and different selections of cymbals would all be in the one "kit" for switching in and out quickly
EOF

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
exit

rm *.sfz
kits=(funk orleans bop bop_muted bop_open rock jungle tight piccolo dead metal funk_invcc4 orleans_invcc4 bop_invcc4 bop_muted_invcc4 bop_open_invcc4 rock_invcc4 jungle_invcc4 tight_invcc4 piccolo_invcc4 dead_invcc4 metal_invcc4)
for kit in ${kits[@]}
do
	declare -A $kit
done
bop=(      [cymbals]=ride19   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop       [toms]=bop)
bop_muted=([cymbals]=ride19   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop_muted [toms]=bop)
bop_open=( [cymbals]=ride19   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop_open  [toms]=bop)
jungle=(   [cymbals]=ride19   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn10_jungle    [toms]=bop)
funk=(     [cymbals]=ride19   [hihats]=hh13 [kicks]=kd20_punch  [snares]=sn12_funk      [toms]=rock)
rock=(     [cymbals]=ride19   [hihats]=hh13 [kicks]=kd20_punch  [snares]=sn14_rock      [toms]=rock)
piccolo=(  [cymbals]=ride19   [hihats]=hh13 [kicks]=kd22_noreso [snares]=sn10_piccolo   [toms]=dry)
orleans=(  [cymbals]=ride19   [hihats]=hh14 [kicks]=kd22_boom   [snares]=sn12_orleans   [toms]=rock)
tight=(    [cymbals]=ride19   [hihats]=hh14 [kicks]=kd20_full   [snares]=sn12_tight     [toms]=rock)
dead=(     [cymbals]=ride19   [hihats]=hh14 [kicks]=kd22_noreso [snares]=sn12_dead      [toms]=dry)
metal=(    [cymbals]=sizzle19 [hihats]=hh13 [kicks]=kd22_boom   [snares]=sn14_metal     [toms]=noreso)
bop_invcc4=(      [cymbals]=ride19   [hihats]=hh13_invcc4 [kicks]=kd14_bop    [snares]=sn12_bop       [toms]=bop)
bop_muted_invcc4=([cymbals]=ride19   [hihats]=hh13_invcc4 [kicks]=kd14_bop    [snares]=sn12_bop_muted [toms]=bop)
bop_open_invcc4=( [cymbals]=ride19   [hihats]=hh13_invcc4 [kicks]=kd14_bop    [snares]=sn12_bop_open  [toms]=bop)
jungle_invcc4=(   [cymbals]=ride19   [hihats]=hh13_invcc4 [kicks]=kd14_bop    [snares]=sn10_jungle    [toms]=bop)
funk_invcc4=(     [cymbals]=ride19   [hihats]=hh13_invcc4 [kicks]=kd20_punch  [snares]=sn12_funk      [toms]=rock)
rock_invcc4=(     [cymbals]=ride19   [hihats]=hh13_invcc4 [kicks]=kd20_punch  [snares]=sn14_rock      [toms]=rock)
piccolo_invcc4=(  [cymbals]=ride19   [hihats]=hh13_invcc4 [kicks]=kd22_noreso [snares]=sn10_piccolo   [toms]=dry)
orleans_invcc4=(  [cymbals]=ride19   [hihats]=hh14_invcc4 [kicks]=kd22_boom   [snares]=sn12_orleans   [toms]=rock)
tight_invcc4=(    [cymbals]=ride19   [hihats]=hh14_invcc4 [kicks]=kd20_full   [snares]=sn12_tight     [toms]=rock)
dead_invcc4=(     [cymbals]=ride19   [hihats]=hh14_invcc4 [kicks]=kd22_noreso [snares]=sn12_dead      [toms]=dry)
metal_invcc4=(    [cymbals]=sizzle19 [hihats]=hh13_invcc4 [kicks]=kd22_boom   [snares]=sn14_metal     [toms]=noreso)

for kit in ${kits[@]}
do
	declare -n k=$kit

	for btr in brs hnd mlt stx
	do
		for snare in off on
		do
			[[ -f ../cymbals/${btr}_${k[cymbals]}.sfz ]] || { echo "${kit}_${btr}_snare_${snare} has no cymbals"; continue; }
			[[ -f ../hihats/${k[hihats]}_${btr}.sfz ]] || { echo "${kit}_${btr}_snare_${snare} has no hihats"; continue; }
			[[ -f ../kicks/${k[kicks]}_snare_${snare}.inc ]] || { echo "${kit}_${btr}_snare_${snare} has no kicks"; continue; }
			[[ -f ../snares/${k[snares]}_${btr}_snare_${snare}.inc ]] || { echo "${kit}_${btr}_snare_${snare} has no snares"; continue; }
			[[ -f ../toms/${k[toms]}_${btr}_snare_${snare}.sfz ]] || {
				echo "${kit}_${btr}_snare_${snare} has no toms"
				[[ $snare == on && ( (
					${k[toms]} == noreso && $btr == stx
				) || (
					${k[toms]} == bop && $btr == brs
				) ) ]] && {
					echo '... will use snare_off toms, then'
				} || {
					continue
				}
			}

		echo "Making ${kit}_${btr}_snare_${snare}.sfz ..."
		{
cat <<-\@EOF
//***
// Aria Player sfz Mapping for Natural Studio ns_kit7
// Mapping Copyright (C) 2016 Peter L Jones
//***

// ------------------------------------------------------------------
// Standard CCs
#define $MOD 001
#define $FC 004
#define $VOL 007
#define $PAN 010

<control>
 hint_ram_based=1
 octave_offset=0
 set_cc$MOD=000  label_cc$MOD=Mod Whl    (cc$MOD)
 set_cc$FC=127   label_cc$FC=Foot Ctrler (cc$FC)
 set_cc$VOL=127  label_cc$VOL=Kit VOL    (cc$VOL)
 set_cc$PAN=64   label_cc$PAN=Kit PAN    (cc$PAN)

  
<global>
 loop_mode=one_shot off_mode=normal
 volume_cc$VOL=0 pan_cc$PAN=0
 ampeg_release=.2

// "Any other hand strike" to mute rolls
<group> end=-1 sample=*silence
 group=100000000
<region> lokey=013 hikey=019
<region> lokey=021 hikey=034
<region> lokey=037 hikey=043
<region> lokey=045 hikey=061

@EOF
cat <<-@EOF
#include "cymbals/${btr}_${k[cymbals]}.sfz"
#include "hihats/${k[hihats]}_${btr}.sfz"
#include "kicks/${k[kicks]}_snare_${snare}.inc"
#include "snares/${k[snares]}_${btr}_snare_${snare}.inc"
@EOF
			[[ $snare == on && ( (
				${k[toms]} == noreso && $btr == stx
			) || (
				${k[toms]} == bop && $btr == brs
			) ) ]] && {
				echo "#include \"toms/${k[toms]}_${btr}_snare_off.sfz\""
			} || {
				echo "#include \"toms/${k[toms]}_${btr}_snare_${snare}.sfz\""
			}
			[[ -f ../percussion/cowbell_8_${btr}.inc ]] && echo "#include \"percussion/cowbell_8_${btr}.inc\""
			[[ $btr == hnd ]]                           && echo '#include "percussion/tambourine_9_hnd.inc"'
		} > "${kit}_${btr}_snare_${snare}.sfz"
		done
	done

	unset -n k
done
