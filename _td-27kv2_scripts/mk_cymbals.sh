#!/bin/bash -eu

# ns_kit7 cymbals

# trigger = (cymbal)_(articulation)(|_inner|_outer)_(free|held)
# <group>
#   ..trigger definition..
#   group=(trigger group or trigger grab group)
#   off_by=(if not trigger grab, trigger grab group)
# #include (from the tables)

# beater will be brs|hnd|mlt|stx
# trigger will be bel|top|rim

# brs
#         china_19 crash_15 crash_18 ride_19 ride_20 sizzle_19 splash_8 splash_9 splash_12
#            ord      ord      ord     bel     bel      bel       ord      ord      ord      trigger: bel (or fake, PAT<64)
#            ord      ord      ord     ord     ord      ord       ord      ord      ord      trigger: top (PAT<64)
#            sws      sws      sws     sws     sws      sws       sws      sws      sws      trigger: rim (PAT<64)
#            grb      grb      grb     grb     grb      grb       grb      grb      grb      trigger: *** (PAT>=64)

# hnd
#         china_19 crash_15 crash_18 ride_19 ride_20 sizzle_19 splash_8 splash_9 splash_12
#            ord      ord      ord     ord     ord      ord       ord      ord      ord      trigger: *** (PAT<64)
#            grb      grb      grb     grb     grb      grb       grb      grb      grb      trigger: *** (PAT>=64)

# mlt
#         china_19 crash_15 crash_18 ride_19 ride_20 sizzle_19 splash_8 splash_9 splash_12
#            ord      ord      ord     bel     ord      bel       ord      ord      ord      trigger: bel (or fake, PAT<64)
#            ord      ord      ord     ord     ord      ord       ord      ord      ord      trigger: top (PAT<64)
#            rol      rol      rol     rol     rol      ord       rol      rol      rol      trigger: rim (PAT<64)
#            grb      grb      grb     grb     grb      grb       grb      grb      grb      trigger: *** (PAT>=64)

# stx
#         china_19 crash_15 crash_18 ride_19 ride_20 sizzle_19 splash_8 splash_9 splash_12
#            top      bel      bel     bel     bel      bel       bel      ord      bel      trigger: bel (or fake, PAT<64)
#            top      top      top                                ord      ord      top      trigger: top (PAT<64)
#                                      ord     ord      ord                                  trigger: top (PAT<64, posn<96)
#                                      elv     elv      elv                                  trigger: top (PAT<64, posn>=96)
#            ord      ord      ord     crs     ord      ord       ord      ord      ord      trigger: rim (PAT<64)
#            grb                                        grb       grb      grb               trigger: *** (PAT>=64)
#                     rim      rim     rim     rim                                  rim      trigger: bel (PAT>=64)
#                     grb      grb     grt     grb                                  grb      trigger: top (PAT>=64)
#                     grb      grb     grc     grb                                  grb      trigger: rim (PAT>=64)

function make_articulation () {
	local grab=$1; shift || { echo "No grab supplied" >&2; exit 1; }
	[[ $grab =~ ^held|free$ ]] || { echo "Unknown grab {$grab}" >&2; exit 1; }
	local beater=$1; shift || { echo "No beater supplied" >&2; exit 1; }
	[[ $beater =~ ^brs|hnd|mlt|stx$ ]] || { echo "Unknown beater {$beater}" >&2; exit 1; }
	local cymbal=$1; shift || { echo "No cymbal supplied" >&2; exit 1; }
	[[ $cymbal =~ ^cy19_china|cy15_crash|cy18_crash|cy19_ride|cy20_ride|cy19_sizzle|cy8_splash|cy9_splash|cy12_splash$ ]] || { echo "Unknown cymbal {$cymbal}" >&2; exit 1; }
	local position=$1; shift || { echo "No position supplied" >&2; exit 1; }
	[[ $position =~ ^bel|top|rim$ ]] || { echo "Unknown position {$position}" >&2; exit 1; }
	local zone=$1; shift || { echo "No zone supplied" >&2; exit 1; }
	[[ $zone =~ ^inner|outer|-$ ]] || { echo "Unknown zone {$zone}" >&2; exit 1; }

	if [[ $grab == held ]]
	then
		if [[ $beater == stx && $cymbal =~ ^cy1[58]_crash|cy19_ride|cy20_ride|cy12_splash$ ]]
		then
			if [[ $position == bel ]]
			then
				articulation=rim
			elif [[ $cymbal == cy19_ride && $position == top ]]
			then
				articulation=grt
			elif [[ $cymbal == cy19_ride && $position == rim ]]
			then
				articulation=grc
			else
				articulation=grb
			fi
		else
			articulation=grb
		fi
	else
		if [[ $beater == brs && $cymbal =~ ^cy19_ride|cy20_ride|cy19_sizzle$ && $position == bel ]]
		then
			articulation=bel
		elif [[ $beater == brs && $position == rim ]]
		then
			articulation=sws
		elif [[ $beater == mlt && $cymbal != cy19_sizzle && $position == rim ]]
		then
			articulation=rol
		elif [[ $beater == stx && $position == bel && $cymbal != cy19_china && $cymbal != cy9_splash ]]
		then
			articulation=bel
		elif [[ $beater == stx && $position == top && $cymbal =~ ^cy19_china|cy1[58]_crash|cy12_splash$ ]]
		then
			articulation=top
		elif [[ $beater == stx && $position == top && $cymbal =~ ^cy19_ride|cy20_ride|cy19_sizzle$ && $zone == outer ]]
		then
			articulation=elv
		elif [[ $beater == stx && $position == rim && $cymbal == cy19_ride ]]
		then
			articulation=crs
		else
			articulation=ord
		fi
	fi
	echo $articulation
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

rm -rf triggers/*/cymbals/

declare -A keys
for beater in brs hnd mlt stx
do
	# {
	c=0
	for cymbal in cy19_china cy15_crash cy18_crash cy19_ride cy20_ride cy19_sizzle cy8_splash cy9_splash cy12_splash
	do
		# {
		(( c+=1 ))
		keys=()
		mkdir -p triggers/$beater/cymbals
		rm -f triggers/$beater/$cymbal.inc
		rm -f triggers/$beater/cymbals/$cymbal.inc
echo >&2 "triggers/$beater/cymbals/${cymbal}.inc"
		i=0
		max_duration=0
		for position in bel top rim
		do
			for grab in free held
			do
				#if [[ "${beater}_${cymbal}_${position}_${grab}" =~ ^stx_(cy19_ride|cy20_ride|cy19_sizzle)_top_free$ ]]
				if [[ ${position} == top ]]
				then
					zones=(inner outer)
				else
					zones=(-)
				fi
				for zone in "${zones[@]}"
				do
					articulation=$(make_articulation $grab $beater $cymbal $position $zone)
					if [[ $articulation =~ ^gr[bct]|rim$ ]]
					then
						is_grab=true
					else
						is_grab=false
					fi
					$is_grab || (( i+=1 ))
					f="$(echo $cymbal | sed -e 's/\(cy[^_]*\)_\(.*\)$/\2_\1/')_${beater}_${articulation}"
					[[ -f "kit_pieces/cymbals/${f}.sfz" ]] || { echo "new $f not found" >&2; exit 1; }
					[[ -f "../cymbals/${f}.sfz" ]] || { echo "existing $f not found" >&2; exit 1; }

					max_duration=$(get_durations $max_duration kit_pieces/cymbals/${f}.sfz)
					key="\$${cymbal}_${position}$([[ $zone == - ]] || echo "_${zone}")"
					group=$(printf "%03d\n" $c)
					[[ -v keys[$key] ]] || { keys[$key]=1; [[ -v keys[keys] ]] && keys[keys]="${keys[keys]} $key" || keys[keys]=$key; }
					echo "<group>"
					echo " key=${key}"
					if $is_grab
					then
						echo " lopolyaft=064 hipolyaft=127"
						echo " group=600${group}000"
					else
						echo " lopolyaft=000 hipolyaft=063"
						echo " group=500${group}$(printf "%03d\n" $i) off_by=600${group}000"
					fi
					echo "#include \"kit_pieces/cymbals/${f}.sfz\""
					if ! $is_grab
					then
						echo "<region> key=-1 end=-1"
						echo " on_locc130=001 on_hicc130=127"
						echo " locc133=${key} hicc133=${key}"
						echo " group=600${group}000"
						echo " sample=*silence"
					fi
				done
			done
			echo ""
		done >> triggers/$beater/cymbals/$cymbal.inc

		{
			release=$(awk 'BEGIN { print '$max_duration' / 2; }' <&-)
			echo "// Max duration $max_duration"
			echo "//<master>"
			echo "// ampeg_release=$release"
			echo "// ampeg_releasecc130=$(awk 'BEGIN { print ('$release' > 0.4) ? '$release' - 0.2 : 0.2; }' <&-) ampeg_release_curvecc130=6"
			echo
			i=1
			for key in $(echo ${keys[keys]})
			do
				printf '#define %s %03d\n' ${key} $i
				(( i += 1 ))
			done
			echo ""
			echo "#include \"triggers/$beater/cymbals/$cymbal.inc\""
		} > triggers/$beater/$cymbal.inc
		# } - do cymbal
	done
	# } - do beater
done
