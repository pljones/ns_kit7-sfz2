#!/bin/bash -eu

# ns_kit7 hi-hats

mkdir -p triggers
rm -rf triggers/*/hihats/ triggers/hihat-mutes.inc

cat >/dev/null <<-\@COMMENT
Regions go from tight closed to wide open (the expected openness list for a hihat is held in "${keys[@]}").

A region triggering hi-hat openness x
will be off_by a group that contains all opennesses less open / more closed than x.

So each triggered region has its unique group value (601-art-opn_x)
but a shared off_by group (501-opn_x-000).

Of course, two senses of FC mean two separate sets of group definitions:
    sense=0 - low  CC4 means less open   ( i.e.   0 -> a; 127 -> p )
    sense=1 - high CC4 means more closed ( i.e. 127 -> a;   0 -> p ) -> invcc4

Some triggers always mute: pedal, splash and grab; plus any polyphonic aftertouch as a trigger
@COMMENT

cat > triggers/hihat-mutes.inc <<-'@EOF'
<region> key=$hh_ped
<region> key=$hh_spl
<region> key=$hh_rim_l lopolyaft=64 hipolyaft=127
<region> key=$hh_rim_r lopolyaft=64 hipolyaft=127
<region> on_locc130=1 on_hicc130=127 locc133=$hh_bel   hicc133=$hh_bel
<region> on_locc130=1 on_hicc130=127 locc133=$hh_top_l hicc133=$hh_top_l
<region> on_locc130=1 on_hicc130=127 locc133=$hh_top_r hicc133=$hh_top_r
<region> on_locc130=1 on_hicc130=127 locc133=$hh_rim_l hicc133=$hh_rim_l
<region> on_locc130=1 on_hicc130=127 locc133=$hh_rim_r hicc133=$hh_rim_r
<region> key=$hh_bel   locc4=$LOCC4 hicc4=$HICC4
<region> key=$hh_top_l locc4=$LOCC4 hicc4=$HICC4
<region> key=$hh_top_r locc4=$LOCC4 hicc4=$HICC4
@EOF

# Map hihat/beater/position/grab/hand to an "articulation" and return the available opennesses for that articulation.
# (This is all the messy logic.)
function make_articulation () {
	local hihat=$1; shift || { echo "No hihat supplied" >&2; exit 1; }
	[[ $hihat =~ ^hh13|hh14$ ]] || { echo "Unknown hihat {$hihat}" >&2; exit 1; }
	local beater=$1; shift || { echo "No beater supplied" >&2; exit 1; }
	[[ $beater =~ ^brs|hnd|mlt|stx|ped|spl$ ]] || { echo "Unknown beater {$beater}" >&2; exit 1; }
	local position=$1; shift || { echo "No position supplied" >&2; exit 1; }
	[[ $position =~ ^bel|top|rim|-$ ]] || { echo "Unknown position {$position}" >&2; exit 1; }
	local grab=$1; shift || { echo "No grab supplied" >&2; exit 1; }
	[[ $grab =~ ^held|free|-$ ]] || { echo "Unknown grab {$grab}" >&2; exit 1; }
	local hand=$1; shift || { echo "No hand supplied" >&2; exit 1; }
	[[ $hand =~ ^l|r|-$ ]] || { echo "Unknown hand {$hand}" >&2; exit 1; }

	case $hihat in
	hh13)
		case $beater in
			ped) echo ped h j m p ;;
			spl) echo spl j m p ;;
			brs)
				[[ $grab == held ]] && { echo grb c e; return 0; } || true
				case $position in
					bel) echo bel f ;;
					top) echo sws f ;;
					rim) echo ord_$hand a b c d e f ;;
				esac
			;;
			hnd) echo ord_r a b c ;;
			mlt)
				[[ $grab == held ]] && { echo grb c e; return 0; } || true
				case $position in
					bel) echo bel f ;;
					top|rim) echo ord_$hand a b c d e f ;;
				esac

			;;
			stx)
				[[ $grab == held ]] && {
					[[ $position == rim ]] && echo rim p || echo grb e h j m p
					return 0
				} || true
				case $position in
					bel) echo bel a d g j m p ;;
					top)
						[[ $hand == l ]] && {
							echo top_l a b c d e f g h i j k l m
						} || {
							echo top_r a b c d e f g h i j k l m n o p
						}
					;;
					rim)
						[[ $hand == l ]] && {
							echo ord_l a b c d e f g h i j k l m
						} || {
							echo ord_r a b c d e f g h i j k l m n o p
						}
					;;
				esac
			;;
		esac
	;;
	hh14)
		case $beater in
			ped|spl) echo $beater a ;;
			brs)
				case $position in
					bel|top) echo top_r e ;;
					rim) [[ $hand == l ]] && echo ord_l b || echo ord_r b d ;;
				esac
			;;
			hnd) [[ $position == rim ]] && echo ord_r b || echo top_r d ;;
			mlt) [[ $position == rim ]] && echo ord_r b d || echo top_r e ;;
			stx)
				[[ $grab == held ]] && { echo grb a; return 0; } || true
				case $position in
					bel) echo bel a b e ;;
					top) [[ $hand = l ]] && echo top_l a b || echo top_r a b c d e ;;
					rim) [[ $hand = l ]] && echo ord_l a b c || echo ord_r a b c d e ;;
				esac
			;;
		esac
	;;
	esac
}

function get_durations () {
	local current_max=$1; shift || { echo "Missing current_max" >&2; exit 1; }
	local sfz_file=$1   ; shift || { echo "Missing sfz_file"    >&2; exit 1; }

	local line x duration
	while read line
	do
		read x duration <<<$(echo $line)
		current_max=$(awk '{ print ( ( 0.0 + $1 ) > ( 0.0 + $2 ) ? $1 : $2 ) }' <<<"$duration $current_max")
	done < <(
		grep 'sample=' $sfz_file | sed -e 's!^.*sample=\.\./samples/!!' | while read sample
		do
			grep "^$sample " ../ns_kits7-all_samples-duration.txt
		done
	)
	echo $current_max
}

function do_group () {
	local f=$1;            shift || { echo "Missing f"         >&2; exit 1; }
	local a_o=$1;          shift || { echo "Missing a_o"       >&2; exit 1; }
	local trigger=$1;      shift || { echo "Missing trigger"   >&2; exit 1; }
	local lo=$1;           shift || { echo "Missing lo"        >&2; exit 1; }
	local hi=$1;           shift || { echo "Missing hi"        >&2; exit 1; }
	local grab=$1;         shift || { echo "Missing grab"      >&2; exit 1; }
	local is_grab=$1;      shift || { echo "Missing is_grab"   >&2; exit 1; }
	local group=$1;        shift || { echo "Missing group"     >&2; exit 1; }
	local off_by=$1;       shift || { echo "Missing off_by"    >&2; exit 1; }
	local -n durations=$1; shift || { echo "Missing durations" >&2; exit 1; }

	[[ -f "kit_pieces/hihats/${f}_${a_o}.sfz" ]] || { echo "new $f not found" >&2; exit 1; }
	[[ -f "../hihats/${f}_${a_o}.sfz" ]] || { echo "existing $f not found" >&2; exit 1; }
	echo "<group>"
	echo " key=$trigger"
	echo " locc4=$lo hicc4=$hi"
	[[ $grab == free ]] && echo " lopolyaft=000 hipolyaft=063"
	[[ $grab == held ]] && echo " lopolyaft=064 hipolyaft=127"
	$is_grab && {
		echo " group=${group}${trigger}000"
	} || {
		echo " group=${group}${trigger}${off_by} offby=601${off_by}000"
	}
	echo "#include \"kit_pieces/hihats/${f}_${a_o}.sfz\""
	durations=$(get_durations $durations kit_pieces/hihats/${f}_${a_o}.sfz)
}

function do_off_by () {
	local off_by=$1; shift || { echo "Missing off_by" >&2; exit 1; }
	local lo=$1;     shift || { echo "Missing lo"     >&2; exit 1; }
	local hi=$1;     shift || { echo "Missing hi"     >&2; exit 1; }

	echo "<group> group=601${off_by}000 end=-1 sample=*silence"
	echo "#define \$LOCC4 $lo"
	echo "#define \$HICC4 $hi"
	echo "#include \"triggers/hihat-mutes.inc\""
}

function do_hihat () {
	local movement=$1;     shift || { echo "Missing movement"  >&2; exit 1; }
	local beater=$1;       shift || { echo "Missing beater"    >&2; exit 1; }
	local hihat=$1;        shift || { echo "Missing hihat"     >&2; exit 1; }
	local f=$1;            shift || { echo "Missing f"         >&2; exit 1; }
	local trigger=$1;      shift || { echo "Missing trigger"   >&2; exit 1; }
	local grab=$1;         shift || { echo "Missing grab"      >&2; exit 1; }
	local is_grab=$1;      shift || { echo "Missing is_grab"   >&2; exit 1; }
	local group=$1;        shift || { echo "Missing group"     >&2; exit 1; }
#echo >&2 "do_hihat: movement {$movement}; beater {$beater}; hihat {$hihat}; f {$f}; trigger {$trigger}; grab {$grab}; is_grab {$is_grab}; group {$group}"

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

	local o=0
	local r_n=0
	local r_o=${keys[$r_n]}
	(( r_n+=1 ))
	local -a opennesses
	opennesses=($available_opennesses)
	local a_o=${opennesses[0]}
	opennesses=(${opennesses[@]:1})
	local lo=000
	local hi=127
	local lo_x hi_x
	local off_lo=000 off_hi=127

	{
		if [[ $movement == lo_to_hi ]]
		then
			while [[ ${#opennesses[@]} -gt 0 && $r_n -lt ${#keys[@]} ]]
			do
				[[ $a_o == $r_o ]] && {
					read lo_x hi <<<"${hh_cc4_lohi[$r_o]}"
					if $is_grab || [[ $lo == 000 ]]
					then
						do_group $f $a_o $trigger $lo $hi $grab true $group 000 max_duration
					else
						do_group $f $a_o $trigger $lo $hi $grab $is_grab $group $(printf '%03d\n' $o) max_duration
						do_off_by $(printf '%03d\n' $o) 000 $off_hi
					fi
					echo ''
					off_hi=$hi
					(( o += 1 ))
					r_o=${keys[$r_n]}
					(( r_n+=1 ))
					hi=127
					[[ ${#opennesses[@]} -gt 0 ]] && {
						read lo hi_x <<<"${hh_cc4_lohi[$r_o]}"
						a_o=${opennesses[0]}
						opennesses=(${opennesses[@]:1})
					} || true
				} || {
					[[ $r_o < $a_o ]] && {
						read lo_x hi <<<"${hh_cc4_lohi[$r_o]}"
						r_o=${keys[$r_n]}
						(( r_n+=1 ))
					} || true
				}
			done
			do_group $f $a_o $trigger $lo $hi $grab $is_grab $group $(printf '%03d\n' $o) max_duration
			$is_grab || [[ $lo == 000 ]] || do_off_by $(printf '%03d\n' $o) 000 $off_hi
		else
			while [[ ${#opennesses[@]} -gt 0 && $r_n -lt ${#keys[@]} ]]
			do
				[[ $a_o == $r_o ]] && {
					read lo hi_x <<<"${hh_cc4_hilo[$r_o]}"
					if $is_grab || [[ $hi == 127 ]]
					then
						do_group $f $a_o $trigger $lo $hi $grab true $group 000 max_duration_invcc
					else
						do_group $f $a_o $trigger $lo $hi $grab $is_grab $group $(printf '%03d\n' $o) max_duration_invcc
						do_off_by $(printf '%03d\n' $o) $off_lo 127
					fi
					echo ''
					off_lo=$lo
					(( o += 1 ))
					r_o=${keys[$r_n]}
					(( r_n+=1 ))
					lo=000
					[[ ${#opennesses[@]} -gt 0 ]] && {
						read lo_x hi <<<"${hh_cc4_hilo[$r_o]}"
						a_o=${opennesses[0]}
						opennesses=(${opennesses[@]:1})
					} || true
				} || {
					[[ $r_o < $a_o ]] && {
						read lo hi_x <<<"${hh_cc4_hilo[$r_o]}"
						r_o=${keys[$r_n]}
						(( r_n+=1 ))
					} || true
				}
			done
			do_group $f $a_o $trigger $lo $hi $grab $is_grab $group $(printf '%03d\n' $o) max_duration_invcc
			$is_grab || [[ $hi == 127 ]] || do_off_by $(printf '%03d\n' $o) $off_lo 127
		fi
		echo ''

	} >> $inc_file
}

declare -A hh_cc4_lohi hh_cc4_hilo

declare -A triggers

for beater in brs hnd mlt stx
do
	# {
	c=500
	for hihat in hh13 hh14
	do
		# {
		(( c+=1 ))
		group=$(printf "%03d\n" $c)

		triggers=()
		mkdir -p triggers/$beater/hihats
		rm -f triggers/$beater/hihats/${hihat}.inc
		rm -f triggers/$beater/hihats/${hihat}_invcc4.inc
		max_duration=0
		max_duration_invcc=0

		i=0
		for position in bel top rim ped spl
		do

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

			[[ $position =~ ^ped|spl$ ]] && grabs=(-) || grabs=(free held)
			for grab in ${grabs[@]}
			do
				[[ $position =~ ^ped|spl|bel$ ]] && hands=(-) || hands=(l r)
				for hand in ${hands[@]}
				do

					[[ $position =~ ^ped|spl$ ]] && {
						read articulation available_opennesses <<<"$(make_articulation $hihat $position - $grab $hand)"
					} || {
						read articulation available_opennesses <<<"$(make_articulation $hihat $beater $position $grab $hand)"
					}
					is_grab=$([[ $articulation =~ ^grb|ped|spl|rim$ ]] && echo true || echo false)
					$is_grab || (( i+=1 ))

					[[ $articulation =~ ^ped|spl$ ]] && {
						f="${hihat}_${articulation}"
						trigger="\$hh_${articulation}"
					} || {
						f="${hihat}_${beater}_${articulation}"
						trigger="\$hh_${position}$([[ $hand == - ]] || echo "_$hand")"
					}

					[[ -v triggers[$trigger] ]] || { triggers[$trigger]=1; [[ -v triggers[keys] ]] && triggers[keys]="${triggers[keys]} $trigger" || triggers[keys]=$trigger; }

#echo >&2 "hihat {$hihat}; beater {$beater}; position {$position}; grab {$grab}; hand {$hand} -> articulation {$articulation}; available_opennesses {$available_opennesses}"
					inc_file="triggers/$beater/hihats/${hihat}.inc"
[[ -f $inc_file ]] || echo >&2 $inc_file
#echo >&2 do_hihat lo_to_hi $beater $hihat $f $trigger $grab $is_grab $group $i
					do_hihat lo_to_hi $beater $hihat $f $trigger $grab $is_grab $group $(printf '%03d\n' $i) >> $inc_file

					inc_file="triggers/$beater/hihats/${hihat}_invcc4.inc"
[[ -f $inc_file ]] || echo >&2 $inc_file
#echo >&2 do_hihat hi_to_lo $beater $hihat $f $trigger $grab $is_grab $group $i
					do_hihat hi_to_lo $beater $hihat $f $trigger $grab $is_grab $group $(printf '%03d\n' $i) >> $inc_file

				done
			done
		done

		{
			release=$(awk 'BEGIN { print '$max_duration' / 2; }' <&-)
			echo "// Max duration $max_duration"
			echo "<master>"
			echo " ampeg_release=$release"
			echo " ampeg_releasecc130=$(awk 'BEGIN { print ('$release' > 0.4) ? '$release' - 0.2 : 0.2; }' <&-) ampeg_release_curvecc130=6"
			echo
			i=1
			for key in $(echo ${triggers[keys]})
			do
				printf '#define %s %03d\n' ${key} $i
				(( i += 1 ))
			done
			echo ""
			echo "#include \"triggers/$beater/hihats/${hihat}.inc\""
		} > triggers/$beater/${hihat}.inc
		{
			release=$(awk 'BEGIN { print '$max_duration_invcc' / 2; }' <&-)
			echo "// Max duration $max_duration_invcc"
			echo "<master>"
			echo " ampeg_release=$release"
			echo " ampeg_releasecc130=$(awk 'BEGIN { print ('$release' > 0.4) ? '$release' - 0.2 : 0.2; }' <&-) ampeg_release_curvecc130=6"
			echo
			i=1
			for key in $(echo ${triggers[keys]})
			do
				printf '#define %s %03d\n' ${key} $i
				(( i += 1 ))
			done
			echo ""
			echo "#include \"triggers/$beater/hihats/${hihat}_invcc4.inc\""
		} > triggers/$beater/${hihat}_invcc4.inc
		# } - hihat
	done
	# } - beater
done
