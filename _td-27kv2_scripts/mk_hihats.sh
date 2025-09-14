#!/bin/bash -eu

. utils.sh

# off_by group 601yyy000
# trigger group 501xxxyyy

# ns_kit7 hi-hats

mkdir -p triggers
rm -rf triggers/*/hihats/ triggers/hihat-mutes.sfzh

: <<-'@COMMENT'
Hi-hat muting is fun.

Whilst a sounding hi-hat is playing, it can be muted in a number of ways:
- pressing down on the pedal
- splashing down on the pedal
- grabbing the cymbal to hit a note (*1)
- grabbing the cymbal without hitting a note (*2)
- closing the gap between the cymbals and triggering again (*3)

The first two are straight forward "mute that region if this one triggers" - just lots of regions.

*1: There are a couple of ways this works
    - some hardware eDrum kits just send out MIDI Note On Velocity zero and expect that to stop any sounding note
    - however, technically that's meant to be "Note Off" identical and most samplers studiously ignore note off for drums,
      so a back up technique is to send the Note On Velocity zero followed by a Polyphonic Aftertouch pressure 127 (or >= 64)
      message, indicating the grab
*2: However... that (*1) just ends of abruptly cutting the note (okay here for hi-hats)...
    but maybe the eDrum kit doesn't send that Note On Velocity zero because that abrupt stop isn't appropriate
    - now the sampler needs to process the PA note number to know what it's muting
*3: And then there's the real nitty-gritty of hi-hat muting -- that pedal position
    - currently, just moving the pedal to more closed (less open) doesn't affect the sounding sample
    - you need to go ahead and _hit_ the hi-hat in the new position to trigger the cut of the more open (less closed) sound.

Original explanation, in case it helps:
Regions go from tight closed to wide open (the expected openness list for a hihat is held in "${keys[@]}").

A region triggering hi-hat openness x
will be off_by a group that contains all opennesses less open / more closed than x.

So each triggered region has its unique group value (501-art-opn_x)
but a shared off_by group (601-opn_x-000).

Of course, two senses of FC mean two separate sets of group definitions:
    sense=0 - low  CC4 means less open   ( i.e.   0 -> a; 127 -> p )
    sense=1 - high CC4 means more closed ( i.e. 127 -> a;   0 -> p ) -> invcc4

Some triggers always mute: pedal, splash and grab; plus any polyphonic aftertouch for that note as a trigger.
@COMMENT

cat > triggers/hihat-grab-mutes.sfzh <<-'@EOF'
<region> key=$hh_bel      locc130=64    hicc130=127                                     sample=*silence
<region> key=$hh_top_l    locc130=64    hicc130=127                                     sample=*silence
<region> key=$hh_top_r    locc130=64    hicc130=127                                     sample=*silence
<region> key=$hh_rim_l    locc130=64    hicc130=127                                     sample=*silence
<region> key=$hh_rim_r    locc130=64    hicc130=127                                     sample=*silence
<region> key=-1        on_locc130=1  on_hicc130=127 locc133=$hh_bel   hicc133=$hh_bel   sample=*silence
<region> key=-1        on_locc130=1  on_hicc130=127 locc133=$hh_top_l hicc133=$hh_top_l sample=*silence
<region> key=-1        on_locc130=1  on_hicc130=127 locc133=$hh_top_r hicc133=$hh_top_r sample=*silence
<region> key=-1        on_locc130=1  on_hicc130=127 locc133=$hh_rim_l hicc133=$hh_rim_l sample=*silence
<region> key=-1        on_locc130=1  on_hicc130=127 locc133=$hh_rim_r hicc133=$hh_rim_r sample=*silence
@EOF
cat > triggers/hihat-pedal-mutes.sfzh <<-'@EOF'
<region> key=$hh_bel                                locc4=$LOCC4      hicc4=$HICC4      sample=*silence
<region> key=$hh_top_l                              locc4=$LOCC4      hicc4=$HICC4      sample=*silence
<region> key=$hh_top_r                              locc4=$LOCC4      hicc4=$HICC4      sample=*silence
<region> key=$hh_rim_l                              locc4=$LOCC4      hicc4=$HICC4      sample=*silence
<region> key=$hh_rim_r                              locc4=$LOCC4      hicc4=$HICC4      sample=*silence
@EOF

# Map hihat/beater/position/grab/hand to an "articulation" and return the available opennesses for that articulation.
# (This is all the messy logic.)
function make_articulation () {
	local hihat=$1; shift || { echo "No hihat supplied" >&2; exit 1; }
	local beater=$1; shift || { echo "No beater supplied" >&2; exit 1; }
	[[ $beater =~ ^brs|hnd|mlt|stx$ ]] || { echo "Unknown beater {$beater}" >&2; exit 1; }
	local position=$1; shift || { echo "No position supplied" >&2; exit 1; }
	[[ $position =~ ^bel|top|rim|ped|spl$ ]] || { echo "Unknown position {$position}" >&2; exit 1; }
	local grab=$1; shift || { echo "No grab supplied" >&2; exit 1; }
	[[ $grab =~ ^held|free|-$ ]] || { echo "Unknown grab {$grab}" >&2; exit 1; }
	local hand=$1; shift || { echo "No hand supplied" >&2; exit 1; }
	[[ $hand =~ ^l|r|-$ ]] || { echo "Unknown hand {$hand}" >&2; exit 1; }
	local -n _art_ref=$1; shift || { echo "No _art_ref supplied" >&2; exit 1; }
	local -n _opns=$1; shift || { echo "No _opns supplied" >&2; exit 1; }
	[[ $# -eq 0 ]] || { echo "Unexpected trailing parameters: [$@]" >&2; exit 1; }

	if [[ $position =~ ^ped|spl$ ]]
	then
		beater=$position
		position=-
	fi

	case $hihat in
	hh13)
		case $beater in
			ped) _art_ref=ped; _opns=(h j m p) ;;
			spl) _art_ref=spl; _opns=(j m p) ;;
			brs)
				if [[ $grab == held ]]
				then
					_art_ref=grb; _opns=(c e)
				else
					case $position in
						bel) _art_ref=bel; _opns=(f) ;;
						top) _art_ref=sws; _opns=(f) ;;
						rim) _art_ref=ord_$hand; _opns=(a b c d e f) ;;
					esac
				fi
			;;
			hnd) _art_ref=ord_r; _opns=(a b c) ;;
			mlt)
				if [[ $grab == held ]]
				then
					_art_ref=grb; _opns=(c e)
				else
					case $position in
						bel) _art_ref=bel; _opns=(f) ;;
						top|rim) _art_ref=ord_$hand; _opns=(a b c d e f) ;;
					esac
				fi
			;;
			stx)
				if [[ $grab == held ]]
				then
					if [[ $position == rim ]]
					then
						_art_ref=rim; _opns=(p)
					else
						_art_ref=grb; _opns=(e h j m p)
					fi
				else
					case $position in
						bel) _art_ref=bel; _opns=(a d g j m p) ;;
						top)
							if [[ $hand == l ]]
							then
								_art_ref=top_l; _opns=(a b c d e f g h i j k l m)
							else
								_art_ref=top_r; _opns=(a b c d e f g h i j k l m n o p)
							fi
						;;
						rim)
							if [[ $hand == l ]]
							then
								_art_ref=ord_l; _opns=(a b c d e f g h i j k l m)
							else
								_art_ref=ord_r; _opns=(a b c d e f g h i j k l m n o p)
							fi
						;;
					esac
				fi
			;;
		esac
	;;
	hh14)
		case $beater in
			ped|spl) _art_ref=$beater; _opns=(a) ;;
			brs)
				case $position in
					bel|top) _art_ref=top_r; _opns=(e) ;;
					rim)
						if [[ $hand == l ]]
						then
							_art_ref=ord_l; _opns=(b)
						else
							_art_ref=ord_r; _opns=(b d)
						fi
					;;
				esac
			;;
			hnd)
				if [[ $position == rim ]]
				then
					_art_ref=ord_r; _opns=(b)
				else
					_art_ref=top_r; _opns=(d)
				fi
			;;
			mlt)
				if [[ $position == rim ]]
				then
					_art_ref=ord_r; _opns=(b d)
				else
					_art_ref=top_r; _opns=(e)
				fi
			;;
			stx)
				if [[ $grab == held ]]
				then
					_art_ref=grb; _opns=(a)
				else
					case $position in
						bel) _art_ref=bel; _opns=(a b e) ;;
						top)
							if [[ $hand = l ]]
							then
								_art_ref=top_l; _opns=(a b)
							else
								_art_ref=top_r; _opns=(a b c d e)
							fi
						;;
						rim)
							if [[ $hand = l ]]
							then
								_art_ref=ord_l; _opns=(a b c)
							else
								_art_ref=ord_r; _opns=(a b c d e)
							fi
						;;
					esac
				fi
			;;
		esac
	;;
	*)
		echo "Unknown hihat {$hihat}" >&2
		exit 1
	;;
	esac
}

function do_group () {
	local f=$1;            shift || { echo "Missing f"         >&2; exit 1; }
	local a_o=$1;          shift || { echo "Missing a_o"       >&2; exit 1; }
	local group=$1;        shift || { echo "Missing group"     >&2; exit 1; }
	local trigger=$1;      shift || { echo "Missing trigger"   >&2; exit 1; }
	local off_by=$1;       shift || { echo "Missing off_by"    >&2; exit 1; }
	local grab=$1;         shift || { echo "Missing grab"      >&2; exit 1; }
	local lo=$1;           shift || { echo "Missing lo"        >&2; exit 1; }
	local hi=$1;           shift || { echo "Missing hi"        >&2; exit 1; }
	[[ $# -eq 0 ]] || { echo "Unexpected trailing parameters: [$@]" >&2; exit 1; }
	local off_group=$(printf '%s%s%s' $(( 100 + $group )) ${trigger} ${off_by})

	[[ -f "kit_pieces/hihats/${f}_${a_o}.sfzh" ]] || { echo "new $f not found" >&2; exit 1; }
	[[ -f "../hihats/${f}_${a_o}.sfz" ]] || { echo "existing $f not found" >&2; exit 1; }
	get_durations kit_pieces/hihats/${f}_${a_o}.sfzh max_duration

	echo "<group>"
	echo " group=${group}${trigger}${off_by} off_by=${off_group}"
	echo " key=$trigger"
	[[ $grab == free ]] && echo " lopolyaft=000 hipolyaft=063"
	[[ $grab == held ]] && echo " lopolyaft=064 hipolyaft=127"
	if [[ $lo != "000" || $hi != "127" ]]
	then
		echo " locc4=$lo hicc4=$hi"
	fi
	echo "#include \"kit_pieces/hihats/${f}_${a_o}.sfzh\""
}

function do_group_lo_to_hi () {
	do_group "${@:1:6}" "${@:7:2}"
}

function do_group_hi_to_lo () {
	do_group "${@:1:6}" "${@:9:2}"
}

function do_off_by () {
	local off_by=$1;  shift || { echo "Missing off_by"  >&2; exit 1; }
	local trigger=$1; shift || { echo "Missing trigger" >&2; exit 1; }
	local grab=$1;    shift || { echo "Missing grab"    >&2; exit 1; }
	local lo=$1;      shift || { echo "Missing lo"      >&2; exit 1; }
	local hi=$1;      shift || { echo "Missing hi"      >&2; exit 1; }
	[[ $# -eq 0 ]] || { echo "Unexpected trailing parameters: [$@]" >&2; exit 1; }
	local off_group=$(printf '%s%s%s' $(( 100 + $group )) ${trigger} ${off_by})

	echo "<group> group=${off_group} end=-1"
	if [[ $trigger != '$hh_ped' ]]
	then
		cat <<-'@EOF'
<region> key=$hh_ped sample=*silence
@EOF
	fi
	if [[ $trigger != '$hh_spl' ]]
	then
		cat <<-'@EOF'
<region> key=$hh_spl sample=*silence
@EOF
	fi
	if [[ $lo != "000" || $hi != "127" ]]
	then
		echo "#define \$LOCC4 $lo"
		echo "#define \$HICC4 $hi"
		echo "#include \"triggers/hihat-pedal-mutes.sfzh\""
	fi
	if [[ $grab == free ]]
	then
		echo "#include \"triggers/hihat-grab-mutes.sfzh\""
	fi
}

function do_off_by_lo_to_hi () {
	do_off_by "${@:1:3}" "${@:4:2}"
}

function do_off_by_hi_to_lo () {
	do_off_by "${@:1:3}" "${@:6:2}"
}

function write_articulation () {
	local beater=$1;          shift || { echo "Missing beater"       >&2; exit 1; }
	local hihat=$1;           shift || { echo "Missing hihat"        >&2; exit 1; }
	local movement=$1;        shift || { echo "Missing movement"     >&2; exit 1; }
	local group=$1;           shift || { echo "Missing group"        >&2; exit 1; }
	local position=$1;        shift || { echo "Missing position"     >&2; exit 1; }
	local grab=$1;            shift || { echo "Missing grab"         >&2; exit 1; }
	local hand=$1;            shift || { echo "Missing hand"         >&2; exit 1; }
	local -n off_by_index=$1; shift || { echo "Missing off_by_index" >&2; exit 1; }
	[[ $# -eq 0 ]] || { echo "Unexpected trailing parameters: [$@]" >&2; exit 1; }
#echo >&2 "write_articulation: beater {$beater}; hihat {$hihat}; movement {$movement}; group {$group}; position {$position}; grab {$grab}; hand {$hand}; off_by_index {$off_by_index}"

	# _opennesses comes back as a space-separated list of available openness keys but we need an array
	local -a opennesses
	local articulation
	make_articulation $hihat $beater $position $grab $hand articulation opennesses

	if [[ $articulation =~ ^grb|ped|spl|rim$ ]]
	then
		is_grab=true
	else
		is_grab=false
	fi

	local trigger f
	if [[ $articulation =~ ^ped|spl$ ]]
	then
		f="${hihat}_${articulation}"
		trigger="\$hh_${articulation}"
	else
		f="${hihat}_${beater}_${articulation}"
		trigger="\$hh_${position}$([[ $hand == - ]] || echo "_$hand")"
	fi

	if [[ ! -v triggers[$trigger] ]]
	then
		triggers[$trigger]=1
		if [[ -v triggers[keys] ]]
		then
			triggers[keys]="${triggers[keys]} $trigger"
		else
			triggers[keys]=$trigger
		fi
	fi

	local do_group=do_group_${movement} do_off_by=do_off_by_${movement}

	# So we have two "piles":
	# - a list of all required opennesses ("keys")
	# - a list of all available opennesses ("available_opennesses")
	#
	# Method
	# - set start point (lo=000 hi=127)
	# - read one entry from each pile
	# - if the available openness matches the required openness
	#   - set hi to the required hi and take the next required openness
	#   - emit the current lo/hi
	#   - set the lo to the value from the current required openness and the hi to 127
	#   - read the next available openness if possible
	# - else if the required openness is less than the current available openness
	#   - set hi to the required hi and take the next required openness
	# - when both "piles" are empty emit any trailing lo/hi
	#
	# ... and then for the other direction

	local r_n=0
	local r_o=${keys[$r_n]}
	(( r_n+=1 ))
	local a_o=${opennesses[0]}
	opennesses=(${opennesses[@]:1})
	local lohi_lo=000 lohi_hi=127 lohi_off_hi=127
	local hilo_lo=000 hilo_hi=127 hilo_off_lo=000
	local lo_x hi_x
	local off_by

	while [[ ${#opennesses[@]} -gt 0 && $r_n -lt ${#keys[@]} ]]
	do
		if [[ $a_o == $r_o ]]
		then
			read lo_x lohi_hi <<<"${hh_cc4_lohi[$r_o]}"
			read hilo_lo hi_x <<<"${hh_cc4_hilo[$r_o]}"
			off_by=$(printf '%03d' $off_by_index)
			(( off_by_index += 1 ))
			$do_group $f $a_o $group $trigger $off_by $grab $lohi_lo $lohi_hi $hilo_lo $hilo_hi
			$do_off_by $off_by $trigger $grab 000 $lohi_off_hi $hilo_off_lo 127
			echo ''

			lohi_off_hi=$lohi_hi
			hilo_off_lo=$hilo_lo
			r_o=${keys[$r_n]}
			(( r_n+=1 ))
			lohi_hi=127
			hilo_lo=000
			if [[ ${#opennesses[@]} -gt 0 ]]
			then
				read lohi_lo hi_x <<<"${hh_cc4_lohi[$r_o]}"
				read lo_x hilo_hi <<<"${hh_cc4_hilo[$r_o]}"
				a_o=${opennesses[0]}
				opennesses=(${opennesses[@]:1})
			fi
		elif [[ $r_o < $a_o ]]
		then
			read lo_x lohi_hi <<<"${hh_cc4_lohi[$r_o]}"
			read hilo_lo hi_x <<<"${hh_cc4_hilo[$r_o]}"
			r_o=${keys[$r_n]}
			(( r_n+=1 ))
		fi
	done
	off_by=$(printf '%03d' $off_by_index)
	(( off_by_index += 1 ))
	$do_group $f $a_o $group $trigger $off_by $grab $lohi_lo $lohi_hi $hilo_lo $hilo_hi
	$do_off_by $off_by $trigger $grab 000 $lohi_off_hi $hilo_off_lo 127
	echo ''

}

declare -a keys
declare -A hh_cc4_lohi hh_cc4_hilo

function get_hihat () {
	local beater=$1;   shift || { echo "No beater supplied"   >&2; exit 1; }
	local hihat=$1;    shift || { echo "No hihat supplied"    >&2; exit 1; }
	local position=$1; shift || { echo "No position supplied" >&2; exit 1; }
	[[ $# -eq 0 ]] || { echo "Unexpected trailing parameters: [$@]" >&2; exit 1; }

	if [[ $hihat == hh13 && ( $beater == stx || $position =~ ^ped|spl$ ) ]]
	then
		keys=(a b c d e f g h i j k l m n o p)
		hh_cc4_lohi=(a "000 007" b "008 015" c "016 023" d "024 031" e "032 039" f "040 047" g "048 055" h "056 063" i "064 071" j "072 079" k "080 087" l "088 095" m "096 103" n "104 111" o "112 119" p "120 127")
		hh_cc4_hilo=(p "000 007" o "008 015" n "016 023" m "024 031" l "032 039" k "040 047" j "048 055" i "056 063" h "064 071" g "072 079" f "080 087" e "088 095" d "096 103" c "104 111" b "112 119" a "120 127")
	elif [[ $hihat == hh13 ]]
	then
		keys=(a b c d e f)
		hh_cc4_lohi=(a "000 021" b "022 042" c "043 063" d "064 085" e "086 106" f "107 127")
		hh_cc4_hilo=(f "000 021" e "022 042" d "043 063" c "064 085" b "086 106" a "107 127")
	else
		keys=(a b c d e)
		hh_cc4_lohi=(a "000 025" b "026 051" c "052 076" d "077 102" e "103 127")
		hh_cc4_hilo=(e "000 025" d "026 051" c "052 076" b "077 102" a "103 127")
	fi
}

function write_articulations () {
	local beater=$1;   shift || { echo "Missing beater"       >&2; exit 1; }
	local hihat=$1;    shift || { echo "Missing hihat"        >&2; exit 1; }
	local movement=$1; shift || { echo "No movement supplied" >&2; exit 1; }
	local group=$1;    shift || { echo "Missing group"        >&2; exit 1; }
	[[ $# -eq 0 ]] || { echo "Unexpected trailing parameters: [$@]" >&2; exit 1; }

	local position grab hand

	local _off_by_index=0
	for position in bel top rim ped spl
	do

		get_hihat $beater $hihat $position

		[[ $position =~ ^ped|spl$ ]] && grabs=(-) || grabs=(free held)
		for grab in ${grabs[@]}
		do
			[[ $position =~ ^ped|spl|bel$ ]] && hands=(-) || hands=(l r)
			for hand in ${hands[@]}
			do
				write_articulation $beater $hihat $movement $group $position $grab $hand _off_by_index
			done
		done
	done
}

function write_triggers () {
	local max_duration=$1; shift || { echo "Missing max_duration" >&2; exit 1; }
	local -n _keys=$1;  shift || { echo "Missing _keys"     >&2; exit 1; }

	local key release midi_note

	# TODO: get the release time controlled by CC130 but stay at 0.2s if not muting by polyphonic aftertouch
	release=$(awk 'BEGIN { print '$max_duration' / 2; }' <&-)
	# echo "// Max duration $max_duration"
	# echo "//<master>"
	# echo "// ampeg_release=$release"
	# echo "// ampeg_releasecc130=$(awk 'BEGIN { print ('$release' > 0.4) ? '$release' - 0.2 : 0.2; }' <&-) ampeg_release_curvecc130=6"
	# echo

	# Start at MIDI note 001 for each hi-hat -- mk_kits.sh overrides these; mk_sfz.sh does not
	midi_note=1
	for key in $(echo ${_keys[keys]})
	do
		printf '#define %s %03d\n' ${key} ${midi_note}
		(( midi_note += 1 ))
	done

	echo
	echo "#include \"${inc_file}\""
}

declare -A triggers

for beater in brs hnd mlt stx
do
	# {
	mkdir -p triggers/$beater/hihats

	# Cymbal (hi-hat) identifier (regardless of beater)
	hihat_group_id=500

	for hihat in hh13 hh14
	do
		# {

		# Increment identifier for each hi-hat (regardless of direction)
		(( hihat_group_id += 1 ))

		for movement in lo_to_hi hi_to_lo
		do
			# {

			if [[ $movement == lo_to_hi ]]
			then
				inc_file="triggers/$beater/hihats/${hihat}.sfzh"
				out_file="triggers/$beater/${hihat}.sfzh"
			else
				inc_file="triggers/$beater/hihats/${hihat}_invcc4.sfzh"
				out_file="triggers/$beater/${hihat}_invcc4.sfzh"
			fi

			triggers=()
			max_duration=0

			rm -f "$inc_file" "$out_file"

			echo >&2 $inc_file
			write_articulations $beater $hihat $movement $(printf "%03d\n" $hihat_group_id) > "$inc_file"

			write_triggers $max_duration triggers > "$out_file"

			# } - movement
		done
		# } - hihat
	done
	# } - beater
done
