#!/usr/bin/env bash
set -euo pipefail

# Require bash >= 4.3 for declare -n and namerefs
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
	echo "This script requires bash >= 4.3" >&2
	exit 1
fi

ARIA_PRESETS_DIR="${ARIA_PRESETS_DIR:-./com.Plogue.Aria-ns_kit7}"

kits=(bop bop_muted bop_open dead funk jungle metal orleans piccolo rock tight)
for kit in "${kits[@]}"
do
	declare -A "$kit"
done
bop=(      [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop       [toms]=tm_bop    [btrs_off]="brs hnd mlt" [btrs_on]="brs hnd mlt")
bop_muted=([hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop_muted [toms]=tm_bop    [btrs_off]="stx"         [btrs_on]="stx")
bop_open=( [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn12_bop_open  [toms]=tm_bop    [btrs_off]="stx"         [btrs_on]="stx")
dead=(     [hihats]=hh14 [kicks]=kd22_noreso [snares]=sn12_dead      [toms]=tm_dry                             [btrs_on]="stx")
funk=(     [hihats]=hh13 [kicks]=kd20_punch  [snares]=sn12_funk      [toms]=tm_rock                            [btrs_on]="brs stx")
jungle=(   [hihats]=hh13 [kicks]=kd14_bop    [snares]=sn10_jungle    [toms]=tm_bop    [btrs_off]="hnd stx"     [btrs_on]="stx")
metal=(    [hihats]=hh13 [kicks]=kd22_boom   [snares]=sn14_metal     [toms]=tm_noreso [btrs_off]="stx"         [btrs_on]="stx")
orleans=(  [hihats]=hh14 [kicks]=kd22_boom   [snares]=sn12_orleans   [toms]=tm_rock                            [btrs_on]="stx")
piccolo=(  [hihats]=hh13 [kicks]=kd22_noreso [snares]=sn10_piccolo   [toms]=tm_dry                             [btrs_on]="stx")
rock=(     [hihats]=hh13 [kicks]=kd20_punch  [snares]=sn14_rock      [toms]=tm_rock   [btrs_off]="stx"         [btrs_on]="brs stx")
tight=(    [hihats]=hh14 [kicks]=kd20_full   [snares]=sn12_tight     [toms]=tm_rock                            [btrs_on]="stx")

declare -A polycount=([cymbals]=8 [hihats]=4 [kicks]=4 [snares]=4 [toms]=8 [cowbell]=1 [tambourine]=3)
function poly () {
	local name=$1; shift || { echo "poly: Missing name" >&2; exit 1; }
	local piece="${name#*_}"
	local piece="${piece%%_*}"
	case "$piece" in
		cy*) piece="cymbals" ;;
		hh*) piece="hihats" ;;
		kd*) piece="kicks" ;;
		sn*) piece="snares" ;;
		tm*) piece="toms" ;;
		pn8) piece="cowbell" ;;
		pn9) piece="tambourine" ;;
		*) echo "Unknown piece for name {$name}" >&2; exit 1 ;;
	esac
	#echo "poly: name {$name}; piece {$piece}" >&2
	echo "${polycount[$piece]}"
}

function UUIDGEN () {
	uuidgen | tr '[:lower:]' '[:upper:]'
}

function mk_kit () {
	local kit=$1; shift || { echo "mk_kit: Missing kit" >&2; exit 1; }
	local snares=$1; shift || { echo "mk_kit: Missing snares" >&2; exit 1; }
	local btr=$1; shift || { echo "mk_kit: Missing btr" >&2; exit 1; }
	local track=$1; shift || { echo "mk_kit: Missing track" >&2; exit 1; }
	local -n _sends=$1; shift || { echo "mk_kit: Missing sends" >&2; exit 1; }

	local -n k=$kit

	[[ -v _sends[${btr}_cymbals] ]] || _sends[${btr}_cymbals]=""
	[[ -v _sends[${btr}_${k[hihats]}_invcc4] ]] || _sends[${btr}_${k[hihats]}_invcc4]=""
	[[ -v _sends[ped_${k[kicks]}_snare_${snares}] ]] || _sends[ped_${k[kicks]}_snare_${snares}]=""
	[[ -v _sends[${btr}_${k[snares]}_snare_${snares}] ]] || _sends[${btr}_${k[snares]}_snare_${snares}]=""
	[[ -v _sends[${btr}_${k[toms]}_snare_${snares}] ]] || _sends[${btr}_${k[toms]}_snare_${snares}]=""
	[[ -v _sends[${btr}_pn8_cowbell] ]] || _sends[${btr}_pn8_cowbell]=""
	[[ -v _sends[hnd_pn9_tambourine] ]] || _sends[hnd_pn9_tambourine]=""

	_sends[${btr}_cymbals]="${_sends[${btr}_cymbals]} $track"
	_sends[${btr}_${k[hihats]}_invcc4]="${_sends[${btr}_${k[hihats]}_invcc4]} $track"
	_sends[ped_${k[kicks]}_snare_${snares}]="${_sends[ped_${k[kicks]}_snare_${snares}]} $track"
	_sends[${btr}_${k[snares]}_snare_${snares}]="${_sends[${btr}_${k[snares]}_snare_${snares}]} $track"
	_sends[${btr}_${k[toms]}_snare_${snares}]="${_sends[${btr}_${k[toms]}_snare_${snares}]} $track"
	_sends[${btr}_pn8_cowbell]="${_sends[${btr}_pn8_cowbell]} $track"
	_sends[hnd_pn9_tambourine]="${_sends[hnd_pn9_tambourine]} $track"
}

: <<'@EOF'
container       -> ISBUS 1 1, BUSCOMP <content_depth> 0 0 0 0
not a container ->
  - is contained
    - not last -> ISBUS 0 0,  BUSCOMP 0 0 0 0 0
    - last     -> ISBUS 2 <close_depth>, BUSCOMP 0 0 0 0 0
  - is not contained -> ISBUS 0 0, BUSCOMP 0 0 0 0 0

<track-id> -- uuid
<track-name> -- string
<close_depth> -- integer, negative to close 1 or more levels of container tracks, else 0
<content_depth> -- integer, positive to open 1 or more levels of container tracks, else 0
@EOF
function mk_reaper_track () {
	local trackid=$1; shift || { echo "mk_reaper_track: Missing trackid" >&2; exit 1; }
	local name=$1; shift || { echo "mk_reaper_track: Missing name" >&2; exit 1; }
	local close_depth=$1; shift || { echo "mk_reaper_track: Missing close_depth" >&2; exit 1; }
	local content_depth=$1; shift || { echo "mk_reaper_track: Missing content_depth" >&2; exit 1; }
	local layout=$1; shift || { echo "mk_reaper_track: Missing layout" >&2; exit 1; }
	local callback=$1; shift || { echo "mk_reaper_track: Missing callback" >&2; exit 1; }

	cat <<@EOF
  <TRACK {${trackid}}
    NAME "${name}"$(echo ''; if [[ "$content_depth" -ne 0 ]]
	then
		echo '    ISBUS 1 1'
		echo "    BUSCOMP $content_depth 0 0 0 0"
	elif [[ "$close_depth" -ne 0 ]]
	then
		echo "    ISBUS 2 $close_depth"
		echo '    BUSCOMP 0 0 0 0 0'
	else
		echo '    ISBUS 0 0'
		echo '    BUSCOMP 0 0 0 0 0'
	fi)
    SEL 0
    LAYOUTS "" "$(case $layout in
		name) echo ef --- Strip Just the track name ;;
		meter) echo ed --- Strip Meter Bridge ;;
		*) echo ee --- Strip Meter FX Bridge ;;
	esac)"
@EOF
	eval $callback
	echo '  >'
}

declare -A td_27_to_ns_kit7_presets=(
	["bop"]='        4 5 8 0 1 3 4 5 2 3 0 1 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "ns_kit7 bop"'
	["jungle"]='        0 2 5 0 2 3 0 1 2 3 4 5 0 0 0 127 0 58 0 78 64 43 61 78 33 0 0 -1 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "ns_kit7 jungle"'
	["funk"]='        1 2 3 0 2 4 4 5 2 3 5 7 0 127 121 64 127 66 0 44 64 40 68 44 34 0 0 -1 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "ns_kit7 funk"'
	["orleans"]='        1 2 3 0 2 4 4 5 2 3 5 7 0 6 127 85 0 60 0 42 64 38 92 42 37 0 0 -1 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "ns_kit7 orleans"'
	["metal"]='        2 3 4 1 2 4 4 5 2 3 0 1 0 0 127 21 118 58 0 80 64 43 106 80 12 0 0 -1 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "ns_kit7 metal"'
	["dead"]='        2 3 5 1 2 4 4 5 2 3 0 1 0 4 115 85 78 64 0 38 64 44 19 38 16 0 1 -1 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "ns_kit7 dead"'
	["rock"]='        2 4 8 0 2 4 4 5 2 3 0 1 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 -1 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "ns_kit7 rock"'
	["piccolo"]='        4 5 7 1 2 4 4 5 2 3 4 5 0 2 127 85 0 65 0 79 64 43 19 79 26 0 0 -1 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "ns_kit7 piccolo"'
	["bop"]='        4 5 8 0 1 3 4 5 2 3 0 1 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "ns_kit7 bop"'
	["tight"]='        6 5 7 0 2 4 4 5 2 3 0 1 0 1 9 127 0 0 0 42 64 38 93 42 30 0 0 -1 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "ns_kit7 tight"'
)
function send_fxchain () {
	local preset=$1; shift || { echo "mk_send_fxchain: Missing preset" >&2; exit 1; }

	#echo "!td_27_to_ns_kit7_preset[*] {${!td_27_to_ns_kit7_presets[*]}; preset {$preset}" >&2
	[[ -v td_27_to_ns_kit7_presets[$preset] ]] || { echo "preset {$preset} not found in td_27_to_ns_kit7_presets" >&2; exit 1; }

	cat <<@EOF
    REC 1 5088 1 0 0 0 0 0
    FX 0
    MAINSEND 0 0
    <FXCHAIN
      WNDRECT 25 60 655 408
      SHOW 0
      LASTSEL 1
      DOCKED 1
      BYPASS 0 0 0
      <JS pljones/TD-27_hihat_splash.jsfx ""
        44 96 1 30 8 -1 0 0 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - Default
      >
      PRESETNAME Default
      FLOATPOS 0 0 0 0
      FXID {$(UUIDGEN)}
      WAK 0 0
      BYPASS 0 0 0
      <JS pljones/TD-27-to-ns_kit7.jsfx ""
${td_27_to_ns_kit7_presets[$preset]}
      >
      PRESETNAME "ns_kit7 $preset"
      FLOATPOS 0 0 0 0
      FXID {$(UUIDGEN)}
      WAK 0 0
    >
@EOF
}

#AUXRECV 17 0 1 0 0 0 0 -1 0 -1:U 0 -1 ''
function mk_auxrecv () {
	for recv in "$@"
	do
		echo "    AUXRECV $recv 1 1 0 1 0 0 -1 0 -1:U 0 -1 ''"
	done
}

function nop () {
	echo '    FX 0'
	echo '    MAINSEND 0 0'
}

function parent_send () {
	echo '    FX 1'
	echo '    MAINSEND 1 0'
}

function clap_fxchain () {
	local file=$1; shift || { echo "clap_fxchain: Missing file" >&2; exit 1; }
	local fxid=$1; shift || { echo "clap_fxchain: Missing fxid" >&2; exit 1; }
	local -n __sends="$1"; shift || { echo "clap_fxchain: Missing sends" >&2; exit 1; }

	cat <<@EOF
    FX 0
    MAINSEND 1 0
$(mk_auxrecv "${__sends[@]}")
    <FXCHAIN
      WNDRECT 24 52 655 408
      SHOW 0
      LASTSEL 0
      DOCKED 1
      BYPASS 0 0 0
      <CLAP "CLAPi: sforzando (Plogue Art et Technologie, Inc)" "com.Plogue Art et Technologie, Inc.sforzando" Sfz/${file}
        CFG 0 774 498 ""
      >
      FLOATPOS 972 32 790 564
      FXID {${fxid}}
      WAK 0 0
    >
@EOF
}

function mk_clap_track () {
	local trackid=$1; shift || { echo "mk_clap_track: Missing trackid" >&2; exit 1; }
	local fxid=$1; shift || { echo "mk_clap_track: Missing fxid" >&2; exit 1; }
	local name=$1; shift || { echo "mk_clap_track: Missing name" >&2; exit 1; }
	local file=$1; shift || { echo "mk_clap_track: Missing file" >&2; exit 1; }
	local close_depth=$1; shift || { echo "mk_clap_track: Missing close_depth" >&2; exit 1; }
	local sends=$1; shift || { echo "mk_clap_track: Missing sends" >&2; exit 1; }

	declare -a _sends=($sends)
	mk_reaper_track \
		"$trackid" \
		"$name" \
		"$close_depth" \
		0 \
		fx \
		"clap_fxchain "$file" "$fxid" _sends"
}

# naturalstudios/ns_kit7/ns_kit7_td-27/hnd_cymbals
function mk_sfozando_ariax () {
	local name=$1; shift || { echo "mk_sfozando_ariax: Missing name" >&2; exit 1; }
	local poly=$(poly "$name")

	case "$name" in
		hnd_pn9*) file="${name#hnd_}" ;;
		ped_kd*) file="${name#ped_}" ;;
		*) file="$name" ;;
	esac

	[[ -f tmp/${file}.sfz ]] || { echo "SFZ file tmp/${file}.sfz not found" >&2; exit 1; }

	#cat <<@EOF
	cat > ${ARIA_PRESETS_DIR}/${name}.ariax <<@EOF
<?xml version="1.0" ?>
<AriaSave version="1981" productID="1014">
    <Settings quality="1" streaming="256" maxStreamAllocMB="32768" MIDIOutMode="1" automationSlot="0" liveMode="0" sc="13" scala="01 - equal.scl" scalaCenter="60" globalTuning="0" />
    <Slot id="0" name="naturalstudios/ns_kit7/ns_kit7_td-27/${file}" bankId="5000" version="0" channel="-1" poly="${poly}" tuning="0" pb_range="-1" ptrans="0" mtrans="0" moctave="0" sc="10" mute="0">
        <Main id="0" value="1" />
    </Slot>
    <EffectSlot id="0" sc="13" name="Ambience" bankId="1014" version="1949" procMode="0" />
    <GUI id="0" activeISlot="0" activeESlot="0" selectedTab="-1" />
</AriaSave>
@EOF
}

function do_sfzfile () {
	local btr=$1; shift || { echo "do_sfzfile: Missing btr" >&2; exit 1; }
	local sfzfile=$1; shift || { echo "do_sfzfile: Missing sfzfile" >&2; exit 1; }
	local close_depth=$1; shift || { echo "do_sfzfile: Missing close_depth" >&2; exit 1; }
	local sends=$1; shift || { echo "do_sfzfile: Missing sends" >&2; exit 1; }

	#echo "do_sfzfile: sends {$sends}" >&2
	[[ -z "$sends" ]] && { echo "do_sfzfile: btr {$btr}; sfzfile {$sfzfile} - empty sends" >&2; }

	#echo "btr {$btr}; sfzfile {$(basename "$sfzfile" .sfz)}" >&2

	trackname="$(basename "$sfzfile" .sfz | sed -e 's/^'$btr'_//' -e 's/_snare_off//' -e 's!_snare_on! /w!' -e 's/[_-]/ /g')"
	mk_clap_track \
		"$(UUIDGEN)" \
		"$(UUIDGEN)" \
		"$trackname" \
		"$(basename "$sfzfile" .sfz)" \
		$close_depth \
		"$sends"
	mk_sfozando_ariax "$(basename "$sfzfile" .sfz)"
}

[[ -d _kit_piece_groups ]] || { echo "Directory _kit_piece_groups not found" >&2; exit 1; }

echo '<REAPER_PROJECT 0.1 "5.0" 1551567848'
echo '  RECORD_PATH "" ""'
echo '  SAMPLERATE 48000 0 0'
echo '  TEMPO 120 4 4 0'

declare -A sends=()

declare -a brs_kits
declare -a hnd_kits
declare -a mlt_kits
declare -a stx_kits

# Sound source parent send track
# ns_kit7 container track
t=1
tns=()
for btr in brs hnd mlt stx
do
	declare -n btr_kits="${btr}_kits"
	# ns_kit7 $btr track
	(( t++ )) || :

	for kit in "${kits[@]}"
	do
		declare -n k="$kit"
		for snares in off on
		do
			if [[ ! -v k[btrs_${snares}] ]]
			then
				#echo "kit {${kit}}; snares {${snares}} - no kits" >&2
				continue
			fi
			#echo "k[btrs_${snares}] {${k[btrs_${snares}]}}; btr {${btr}}" >&2

			found=0
			for b in ${k[btrs_${snares}]}
			do
				if [[ "$b" == "$btr" ]]
				then
					found=1
					break
				fi
			done
			if [[ $found -eq 0 ]]
			then
				#echo "kit {$kit}; snares {$snares}; btr {$btr} - no such kit" >&2
				continue
			fi

			#echo "kit {$kit}; snares {$snares}; btr {$btr}; t {$t}" >&2

			mk_kit "$kit" "$snares" "$btr" $t sends
			# kit track
			(( t++ )) || :

			tn="${kit} ${btr}$( [[ "$snares" == "on" ]] && echo "-w" || : )"
			btr_kits+=("${tn}")

		done
	done
done

mk_reaper_track "$(UUIDGEN)" "Sound source parent" 0 2 meter nop

for btr in brs hnd mlt stx
do
	declare -n _b="${btr}_kits"
	declare -a tns=("${_b[@]}")
	if [[ ${#tns[@]} -eq 0 ]]
	then
		#echo "No tracks for btr {$btr}" >&2
		continue
	fi

	mk_reaper_track "$(UUIDGEN)" "ns_kit7 $btr parent SEND" 0 1 name nop

	i=0
	while (( i < ${#tns[@]} ))
	do
		tn="${tns[$i]}"
		preset=${tn//[ _]*}
		uuid="$(UUIDGEN)"
		#echo "btr {$btr}; tn {$tn}; preset {$preset}" >&2
		mk_reaper_track "$uuid" "$tn" $(
			if [[ $i -lt $((${#tns[@]} - 1)) ]]; then echo 0
			elif [[ $btr == "stx" ]]; then echo -2
			else echo -1
			fi
		) 0 fx "send_fxchain $preset"
		(( i++ )) || :
	done
done

mk_reaper_track "$(UUIDGEN)" "... lots of other tracks ..." 0 0 name nop
(( t++ )) || :

# Copy/paste this into the project, then wire this track to the sound source parent send track
mk_reaper_track "$(UUIDGEN)" "ns_kit7 groups" 0 2 name nop
(( t++ )) || :

#for x in "${!sends[@]}"
#do
#	echo "Send: {$x}: ${sends[$x]}" >&2
#done

declare -a groups
for btr in brs hnd mlt stx ped
do
	#echo "btr {$btr}" >&2
	if [[ "$btr" == "hnd" ]]
	then
		groups=($({ cd _kit_piece_groups/; ls -1 ${btr}_*.sfz; ls -1 pn*.sfz | sed -e 's/pn/hnd_pn/'; } | sort))
	elif [[ "$btr" == "ped" ]]
	then
		groups=($(cd _kit_piece_groups/; ls -1 kd??_*.sfz | sed -e 's/kd/ped_kd/'))
	else
		groups=($(cd _kit_piece_groups/; ls -1 ${btr}_*.sfz))
	fi
	[[ ${#groups[@]} -eq 0 ]] && { echo "No groups found for btr {$btr}" >&2; continue; }

	mk_reaper_track "$(UUIDGEN)" "ns_kit7 ${btr}" 0 1 name parent_send

	gn=1
	while [[ $gn -le ${#groups[@]} ]]
	do
		sfzfile="${groups[$(( gn - 1 ))]}"

		if [[ "$sfzfile" =~ ^..._hh && ! "$sfzfile" =~ _invcc4 ]]
		then
			#echo "Skip non-invcc4 hh: {$sfzfile}" >&2
			:
		else
			_group="$(basename "$sfzfile" .sfz)"
			[[ -v sends[$_group] ]] && _sends="$(echo ${sends[$_group]})" || _sends=""
			do_sfzfile "$btr" "$sfzfile" $(
				if [[ $gn -lt ${#groups[@]} ]]; then echo 0
				elif [[ $btr == "ped" ]]; then echo -2
				else echo -1
				fi
			) "$_sends"
		fi
		(( gn++ )) || :
	done
done

echo ">"
