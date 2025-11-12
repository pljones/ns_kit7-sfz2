#!/usr/bin/env bash
set -euo pipefail

# Require bash >= 4.3 for declare -n and namerefs
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
  echo "This script requires bash >= 4.3" >&2
  exit 1
fi

function header() {
	echo "Emitted at: $(date -Iseconds)"
	echo
	cat <<-"EOF"
//***
// Aria Player sfz Mapping for Natural Studio ns_kit7
// Mapping Copyright (C) 2025 Peter L Jones
//***

// Work in progress:
//
// head <<== 0 tomAuxCC 127 ==>> rim
//
// #define $tomAuxCC   081
// #define $tomAuxLoCC 120
// 
// key=head
//  xfout_locc$tomAuxCC=$tomAuxLoCC xfout_hicc$tomAuxCC=127
//  include->head
// key=head
//  locc$tomAuxCC=$tomAuxLoCC hicc$tomAuxCC=127
//  xfin_locc$tomAuxCC=$tomAuxLoCC xfin_hicc$tomAuxCC=127
//  include->rim
// 
// key=rim
//  include->rim
//
// Also in progress is progress polyphonic aftertouch muting,
// whereby the polypressure controls how fast the muting happens.

// Done but undocumented:
//
// // TD-27 default trigger note assignments
// kick           = 36;
// 
// crash1Bow      = 49;
// crash1Edge     = 55;
// crash2Bow      = 57;
// crash2Edge     = 52;
// 
// rideBow        = 51;
// rideEdge       = 59;
// rideBell       = 53;
// rideBowAlt     =  9;
// 
// // 23 is snare head in brush mode
// // no idea where 24 and 25 are but I choose to keep clear
// 
// aux1Head       = 27; // module built-in
// aux1Rim        = 28; // module built-in
// aux2Head       = 29; // module built-in
// aux2Rim        = 30; // module built-in
// aux3Head       = 31; // module built-in
// aux3Rim        = 32; // module built-in
// 

//
// Done:
//

// hiHatOpenBow     = 46; // hihatCC > 15 & hihatLRCC in (48..79)      A#2  -> top_l D-1 (L) / top_r D#-1 (R)
// hiHatCloseBow    = 42; // hihatCC > 15 & hihatLRCC in (48..79)      F#2  -> top_l D-1 (L) / top_r D#-1 (R)

// hiHatOpenEdge    = 26; // hihatLRCC in (48..79)                     D1   -> rim_l E-1 (L) / rim_r F-1  (R)
// hiHatCloseEdge   = 22; // hihatLRCC in (48..79)                     G#0  -> rim_l E-1 (L) / rim_r F-1  (R)

// hiHatOpenBowL    = 18; // hihatCC > 15 & hihatLRCC < 48             F#0  -> top_l D-1
// hiHatCloseBowL   = 15; // hihatCC > 15 & hihatLRCC < 48             D#0  -> top_l D-1

// hiHatOpenEdgeL   = 13; // hihatLRCC < 48                            C#0  -> rim_l E-1
// hiHatCloseEdgeL  = 11; // hihatLRCC < 48                            B-1  -> rim_l E-1

// hiHatOpenBowR    = 17; // hihatCC > 15 & hihatLRCC > 79             F0   -> top_r D#-1
// hiHatCloseBowR   = 14; // hihatCC > 15 & hihatLRCC > 79             D0   -> top_r D#-1

// hiHatOpenEdgeR   = 12; // hihatLRCC > 79                            C0   -> rim_r F-1
// hiHatCloseEdgeR  = 10; // hihatLRCC > 79                            A#-1 -> rim_r F-1

// hiHatOpenBowAlt  = 19; // hihatCC < 16                              G0   -> bel   C#-1
// hiHatCloseBowAlt = 16; // hihatCC < 16                              E0   -> bel   C#-1

// hiHatPedal       = 44;                                              G#2  -> ped   F#-1


// tom1Head    = 48; // tomAuxCC < 96    C3   -> C#-1 ord_l / D-1 ord_r
// tom1HeadAlt =  8; // tomAuxCC > 95    G#-1 -> E-1  rms_l / F-1 rms_r
// tom1Rim     = 50; // tomAuxCC < 96    D3   -> D#-1 rim
// tom1RimAlt  =  7; // tomAuxCC > 95    G-1  -> D#-1 rim

// tom2Head    = 45; // tomAuxCC < 96    A2   -> C#-1 ord_l / D-1 ord_r
// tom2HeadAlt =  6; // tomAuxCC > 95    F#-1 -> E-1  rms_l / F-1 rms_r
// tom2Rim     = 47; // tomAuxCC < 96    B2   -> D#-1 rim
// tom2RimAlt  =  5; // tomAuxCC > 95    F-1  -> D#-1 rim

// tom3Head    = 43; // tomAuxCC < 96    G2   -> C#-1 ord_l / D-1 ord_r
// tom3HeadAlt =  4; // tomAuxCC < 96    E-1  -> E-1  rms_l / F-1 rms_r
// tom3Rim     = 58; // tomAuxCC > 95    A#3  -> D#-1 rim
// tom3RimAlt  =  3; // tomAuxCC > 95    D#-1 -> D#-1 rim

// ---- sticks ----
// snareHead      = 38; // D2  -> ord_l D#-1 / ord_r E-1
// snareHeadAlt   = 21; // A0  -> rmh_l G#-1 / rmh_r A-1
// snareRim       = 40; // E2  -> rms_l A#-1 / rms_r B-1
// snareRimAlt    = 20; // G#0 -> rim   G-1
// snareXstick    = 37; // C#2 -> xtk   C#0
// snareBrush     = 23; // -> snareHead

// ------------------------------------------------------------------

<control>
// #include "default_path.sfzh"
// hint_ram_based=1
 octave_offset=0
 set_cc7=127  set_cc10=64
 set_cc4=0    label_cc4=Pedal
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
EOF
#cat > _sfzs/default_path_windows.sfzh <<-"EOF"
# default_path=G:/naturalstudios/ns_kit7/samples/
#EOF
#cat > _sfzs/default_path_linux.sfzh <<-"EOF"
# default_path=/mnt/content/space/shared/samples/
#EOF
}

rm -rf _sfzs
mkdir -p _sfzs

for x in $(cd triggers; echo */)
do
	for y in $(cd triggers/$x; echo *.sfzh)
	do
	{
		header
		cat triggers/$x/$y
	} > "_sfzs/${x%%/}_${y%.sfzh}.sfz"
	done
done
