#!/bin/bash

# Supply two parameters:
# - ranges:  ns_kits7-all_samples-db_ranges.txt - the output of the to_ranges.sh script
#            Format: dB_hi dB_lo base_path hi_num lo_num
# - samples: ns_kits7-all_samples-db.txt        - the output of VelLeveler or similar
#            Format: dB_sample sample_path

ranges=$1; shift || { echo "Missing ranges" >&2; exit 1; }
samples=$1; shift || { echo "Missing samples" >&2; exit 1; }

# SFZ uses the following as the default method of determining dB adjustment based on velocity:
#     dB = -20 * log(127^2 / Velocity^2)
# The aim here is to determine, for a given sample, what the "best" velocity to trigger it would be.
# I start by reversing the calculation:
#     dB / -20 = log(127^2 / Velocity^2)              -- divide through by "-20"
#     dB / -20 = log(127^2) - log(Velocity^2)         -- split the division inside the log function to subtraction of two logs
#     dB / -20 + log(Velocity^2) = log(127^2)         -- add through by "log(Velocity^2)" 
#     log(Velocity^2) = log(127^2) - (dB / -20)       -- subtract through by "dB / -20"
#     Velocity^2 = exp(log(127^2) - (dB / -20))       -- apply through by exponent
#     Velocity = sqrt(exp(log(127^2) - (dB / -20)))   -- apply through by square root
#
# The idea then is to
# - for each "dB path" matching "base_path"
#   - sqrt(10^(( (dB - hi_dB) / -20) - log(127^2))) = Velocity
#
# That gives a _velocity_ range from "lovel" to 127.
# To spread the available samples over the full range, the "spread_velocity" function:
#     Divides 127 by size of the initial range "127 / (128 - lo_vel)" to get the scaling factor "f"
#     Multiplies the reduction from 127 of the sample velocity by "f" and adds this to 127
#
# As an extra bonus, I then go through the groups of samples that make up one kit piece to find those with the same hivel
# (well, "amp_velcurve_N=1" value) and make them round robin groups.
#
# The "mishits" are factored out.  Maybe they shouldn't be?
#
function velocity() {
	local dB_hi=$1; shift || { echo "Missing dB_hi" >&2; return 1; }
	local dB_lo=$1; shift || { echo "Missing dB_lo" >&2; return 1; }

	awk '{
		f=sqrt( exp( log(127^2) - (($2 - $1) / -20) ) );
		printf("%d\n", f + 0.5);
	}' <<<"$dB_hi $dB_lo"
}

function spread_velocity() {
	local lo_vel=$1; shift || { echo "Missing lo_vel" >&2; return 1; }
	local vel=$1; shift || { echo "Missing vel" >&2; return 1; }

	awk '{
		f = 127 / (128 - $1);
		vel = ($2 - 127) * f + 127;
		printf("%d\n", vel);
	}' <<<"$lo_vel $vel"
}

declare -a group

rm -rf kit_pieces
mkdir -p kit_pieces

while read dB_hi dB_lo base_path hi_num lo_num
do
	dB_hi=${dB_hi//;}
	dB_lo=${dB_lo//;}
	base_path=${base_path//;}
	hi_num=${hi_num%.wav}
	lo_num=${lo_num%.wav}

	mishit=""
	ns_rr=""
	group_sfx=""
	if [[ $base_path =~ ^x_ ]]
	then
		mishit="x"
		filter=".*_[0-9][0-9][0-9]x\.wav"
		split=( $(IFS="/"; split=(${base_path#x_}); echo "${split[@]}") )
		group_sfx="_x"
	elif [[ $base_path =~ ^([abcrp])_ ]]
	then
		if [[ "${BASH_REMATCH[1]}" == "r" ]]
		then
			ns_rr="rls"
			filter=".*_[0-9][0-9][0-9]r\.wav"
		elif [[ "${BASH_REMATCH[1]}" == "p" ]]
		then
			ns_rr="rpt"
			filter=".*_[0-9][0-9][0-9]p\.wav"
		else
			ns_rr="${BASH_REMATCH[1]}"
			filter="_.*${BASH_REMATCH[1]}[0-9][0-9][0-9]\.wav"
		fi
		split=( $(IFS="/"; split=(${base_path#${BASH_REMATCH[1]}_}); echo "${split[@]}") )
		group_sfx="_$ns_rr"
	else
		filter="_.*[0-9][0-9][0-9]\.wav"
		split=( $(IFS="/"; split=($base_path); echo "${split[@]}") )
	fi

	[[ "$mishit" != "" && "$ns_rr" != "" ]] && {
		echo "Both mishit {$mishit} and ns_rr {$ns_rr} set; this should never happen!" >&2
		exit 1
	} || true

	[[ ${split[0]} == _nsmr ]] && {
		case "${split[1]:0:2}" in
			cy) instrument=cymbals; split=( "${split[@]:1}" ) ;;
			sn) instrument=snares; split=( "${split[@]:1}" ) ;;
			pr) echo "pre-roll: $base_path" >&2; continue;;
			hh) echo "hi-hat 't'? $base_path" >&2; continue;;
			*)
				echo "Unsupported _nsmr: $base_path; this should never happen!" >&2
				;;
		esac
	} || {
		instrument="${split[0]}"; split=( "${split[@]:1}" )
	}
	[[ "${split[0]}" =~ ^([a-z][a-z][0-9]*)(.*)$ ]] || true
	size="${BASH_REMATCH[1]}"    ;# Will contain something
	tuning="${BASH_REMATCH[2]}"  ;# May be empty
	split=( "${split[@]:1}" )
	[[ "$instrument" == "kicks" ]] && beater="" || { beater="${split[0]}"; split=( "${split[@]:1}" ); }
	openness=""
	snare=""
	left_right=""
		
	case "$instrument" in
		cymbals)
			size="${tuning}_${size}"
			tuning=""
		;;
		hihats)
			openness="a"
			[[ ${split[0]} =~ ^[a-z]$ ]] && { openness="${split[0]}"; split=( "${split[@]:1}" ); } || true
			[[ "$base_path" =~ ^hihats/hh14/stx/e/ord/hh14_stxr_ebel ]] && { split=( bel "${split[@]:1}" ); } || true
		;;
		kicks)
			snare="${split[0]}"; split=( "${split[@]:1}" )
			[[ "$ns_rr" == "" ]] || ns_rr="_$ns_rr"
		;;
		percussion)
			[[ "$tuning" == "cowbell" && $beater =~ ^mlt|stx$ ]] && { beater="${beater}_${split[0]}"; split=( "${split[@]:1}" ); } || true
			size="${tuning}_${size}"
			tuning=""
		;;
		snares)
			[[ "$tuning" == "bop" && "$beater" == "stx" ]] && { tuning="${tuning}_${split[0]}"; split=( "${split[@]:1}" ); } || true
			snare="${split[0]}"; split=( "${split[@]:1}" )
		;;
		toms)
			snare="${split[0]}"; split=( "${split[@]:1}" )
		;;
		*)
			echo "Unsupported instrument {$instrument}; this should never happen!" >&2
			exit 1
		;;
	esac
	articulation="${split[0]}"; split=( "${split[@]:1}" )
	[[ "${split[0]}" =~ _${beater}([lr]) ]] && left_right=${BASH_REMATCH[1]} || true
	[[ ${#split[@]} -eq 1 ]] || {
		echo "Unprocessed path data: ${split[@]} -- base_path {$base_path}" >&2
		exit 1
	}

	if [[ "$instrument" == "hihats" ]]
	then
		[[ "$size" == "hh14" && "$articulation" == "bel" ]] && left_right="" || true
		[[ "$articulation" =~ ped|spl ]] && beater="" || true
	fi

	f="$instrument/$size"
	f="$f$([[ "$tuning" != "" ]] && echo "_$tuning" || true)"
	f="$f$([[ "$beater" != "" ]] && echo "_$beater" || true)"
	f="$f$([[ "$snare" != "" ]] && echo "_$snare" || true)"
	f="$f$([[ "$articulation" != "" ]] && echo "_$articulation" || true)"
	f="$f$([[ "$ns_rr" != "" ]] && echo "$ns_rr" || true)"
	f="$f$([[ "$left_right" != "" ]] && { echo "_$left_right$mishit"; } || { [[ "$mishit" != "" ]] && echo "_$mishit" || true; })"
	f="$f$([[ "$openness" != "" ]] && echo "_$openness" || true)"
	[[ -f "../${f}.sfz" ]] || {
		echo "base_path {$base_path}; mishit {$mishit}; ns_rr {$ns_rr}; group_sfx {$group_sfx}; filter {$filter}; split {${split[@]}}; f {$f}" >&2
		echo "unexpected filename {../${f}.sfz}" >&2
		exit 1
	}

	mkdir -p "kit_pieces/$instrument"
	rm -f "kit_pieces/${f}.sfzh"

	# Read in a group of samples in ascending dB order
	group=()
	while read dB_sample sample_path
	do
		group+=("$dB_sample $sample_path")
	done < <(grep "${base_path#[abcprx]_}$filter" "$samples" | sort -k1,1n)

	# Append "standard velocity" for each dB
	vel_min=0
	group_vels=()
	for i in ${!group[@]}
	do
		read dB_sample sample_path <<<"${group[$i]}"
		vel=$(velocity $dB_hi $dB_sample) || exit 1
		[[ $vel_min -eq 0 || $vel_min -gt $vel ]] && vel_min=$vel || true ;# catch the lowest velocity
		[[ $vel -le 127 ]] || {
			echo "{$dB_sample} converted to out of range velocity {$vel}" >&2
			exit 1
		}
		group_vels+=("$dB_sample $sample_path $vel")
	done
	[[ ${#group_vels[@]} -eq ${#group[@]} ]] || {
		echo "Append standard velocity dropped samples" >&2
		exit 1
	}

	# Spread velocities from 1 to 127 and compute amp_veltrack to compensate the curve
	dB_prev=""
	spread_vels=()
	for i in ${!group_vels[@]}
	do
		read dB_sample sample_path vel <<<"${group_vels[$i]}"

		hi_vel=$(spread_velocity $vel_min $vel)
		[[ $hi_vel -le 127 ]] || {
			echo "{$vel} spread from {$vel_min} to out of range velocity {$hi_vel}" >&2
			exit 1
		}

		[[ "$dB_prev" != "" ]] || dB_prev="$dB_sample" ;# catch the first (lowest) amplitude
		amp_veltrack=$(awk '{ printf("%.3f\n", $1 / $2); }' <<<"$dB_sample $dB_prev")

		spread_vels+=("$dB_sample $sample_path $vel $hi_vel $amp_veltrack")
		dB_prev="$dB_sample"
	done
	[[ ${#spread_vels[@]} -eq ${#group_vels[@]} ]] || {
		echo "Spread velocities dropped samples" >&2
		exit 1
	}

	# Now process in descending order to assign lovel
	group_desc=()
	i=${#spread_vels[@]}
	while [[ $i -gt 0 ]]
	do
		(( i-=1 ))
		group_desc+=("${spread_vels[$i]}")
	done
	[[ ${#group_desc[@]} -eq ${#spread_vels[@]} ]] || {
		echo "Group descending dropped samples" >&2
		exit 1
	}

	with_lovel=()
	read dB_sample sample_path vel hi_vel amp_veltrack <<<"${group_desc[0]}"
	hi_vel=127  ;# because this is first in descending order
	for i in ${!group_desc[@]}
	do
		(( i+=1 ))
		[[ $i -lt ${#group_desc[@]} ]] || break
		read n_dB_sample n_sample_path n_vel n_hi_vel n_amp_veltrack <<<"${group_desc[$i]}"

		# use one above the next hivel in descending order:
		with_lovel+=("$dB_sample $sample_path $vel $hi_vel $amp_veltrack $(( $n_hi_vel + 1 ))")

		# and save that row
		read dB_sample sample_path vel hi_vel amp_veltrack <<<"${group_desc[$i]}"
	done
	with_lovel+=("$dB_sample $sample_path $vel $hi_vel $amp_veltrack 1") ;# because this is last in descending order
	[[ ${#with_lovel[@]} -eq ${#group_desc[@]} ]] || {
		echo "Adding lovel dropped samples" >&2
		exit 1
	}

	# Back to ascending for round robins
	group_asc=()
	i=${#spread_vels[@]}
	while [[ $i -gt 0 ]]
	do
		(( i-=1 ))
		group_asc+=("${with_lovel[$i]}")
	done
	[[ ${#group_asc[@]} -eq ${#with_lovel[@]} ]] || {
		echo "Group ascending dropped samples" >&2
		exit 1
	}

	group_seq=()
	i=0
	while [[ $i -lt ${#group_asc[@]} ]]
	do
		rr_g=($i)
		read dB_sample sample_path vel hi_vel amp_veltrack lo_vel <<<"${group_asc[$i]}"

		# Get a list of all samples with the same hivel
		(( i+=1 ))
		while [[ $i -lt ${#group_asc[@]} ]]
		do
			read n_dB_sample n_sample_path n_vel n_hi_vel n_amp_veltrack n_lo_vel <<<"${group_asc[$i]}"
			[[ $n_hi_vel == $hi_vel ]] || break
			rr_g+=($i)
			(( i+=1 ))
		done

		# All use the same lovel
		read l_dB_sample l_sample_path l_vel l_hi_vel l_amp_veltrack l_lo_vel <<<"${group_asc[${rr_g[0]}]}"
		for r_i in ${!rr_g[@]}
		do
			r=${rr_g[$r_i]}
			read s_dB_sample s_sample_path s_vel s_hi_vel s_amp_veltrack s_lo_vel <<<"${group_asc[$r]}"
			group_seq+=("$s_dB_sample $s_sample_path $s_vel $s_hi_vel $s_amp_veltrack $l_lo_vel $(( $r_i + 1 )) ${#rr_g[@]}")
		done
		read dB_sample sample_path vel hi_vel amp_veltrack lo_vel <<<"${group_asc[$i]}"
		rr_g=()
	done
	[[ ${#group_seq[@]} -eq ${#group_asc[@]} ]] || {
		echo "Round robin dropped samples -- now {${#group_seq[@]}}; was {${#group_asc[@]}}" >&2
		exit 1
	}

	# Finally write out a nicely formatted line
	for i in ${!group_seq[@]}
	do
		read dB_sample sample_path vel hi_vel amp_veltrack lo_vel seq_position seq_length <<<"${group_seq[$i]}"
		echo "<region> lovel=$lo_vel hivel=$hi_vel amp_velcurve_$hi_vel=1 amp_veltrack=$amp_veltrack seq_position=$seq_position seq_length=$seq_length sample=../samples/$sample_path"; # dB_sample {$dB_sample}
	done > "kit_pieces/${f}.sfzh"

echo >&2 "base_path {$base_path}; f {$f}"
done < "$ranges"
