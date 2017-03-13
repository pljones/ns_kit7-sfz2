#!/bin/bash
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
  set_cc$MOD=000  label_cc$MOD=Mod Whl    (cc$MOD)
  set_cc$FC=127   label_cc$FC=Foot Ctrler (cc$FC)
  set_cc$VOL=127  label_cc$VOL=Kit VOL    (cc$VOL)
  set_cc$PAN=64   label_cc$PAN=Kit PAN    (cc$PAN)

  
<global>
 loop_mode=one_shot off_mode=normal
 volume_cc$VOL=0 pan_cc$PAN=0
 ampeg_release=.2

<control>
 octave_offset=0

// "Any other hand strike" to mute rolls
<group> sample=*silence
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
