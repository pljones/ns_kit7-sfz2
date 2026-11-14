#!/usr/bin/env bash
set -euo pipefail

# Require bash >= 4.3 for declare -n and namerefs
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
  echo "This script requires bash >= 4.3" >&2
  exit 1
fi

# Supply two parameters:
# - ranges:  ns_kits7-all_samples-db_ranges.txt - the output of the to_ranges.sh script
#            Format: dB_hi dB_lo base_path hi_num lo_num
# - samples: ns_kits7-all_samples-db.txt        - the output of VelLeveler or similar
#            Format: dB_sample sample_path

ranges=$1; shift || { echo "Missing ranges" >&2; exit 1; }
samples=$1; shift || { echo "Missing samples" >&2; exit 1; }

# Velocities are assigned by clustering sample loudness (see cluster_velocity below), not by SFZ's default
# dB curve, so quiet detail and loud "all the same" samples both get a sensible share of 1..127.
# The "mishits" are factored out.  Maybe they shouldn't be?
#
# Reads "dB_sample sample_path" lines in ascending dB order on stdin.
# Writes "dB_sample sample_path vel hi_vel amp_veltrack lo_vel seq_position seq_length" lines.
# 1. Samples closer than GAP dB to their neighbour form a cluster ("more or less the same loudness").
#    If that gives too many clusters, the gap is widened until at most MAXC clusters remain.
# 2. Clusters are ordered by mean dB and given contiguous velocity bands covering exactly 1..127.
#    Band width is half the cluster's share of the dB range, half its share of the samples,
#    with a minimum of MINW velocities each (reduced if there are too many clusters).
# 3. Every sample in a cluster shares the band and is a round robin member.
# 4. amp_veltrack (column name kept) is the gain at the band bottom (lo_vel): the cluster mean relative to the one below,
#    so each band starts as loud as the previous band ends. The band top has gain 1.
function cluster_velocity() {
	local dB_hi=$1; shift || { echo "Missing dB_hi" >&2; return 1; }

	awk -v dB_hi="$dB_hi" -v GAP=1.5 -v MAXC=24 -v MINW=4 '
	{ db[NR] = $1; path[NR] = $2 }
	END {
		n = NR; if (n == 0) exit;
		gap = GAP;
		for (;;) {
			k = 1; start[1] = 1;
			for (i = 2; i <= n; i++) if (db[i] - db[i-1] > gap) { k++; start[k] = i }
			if (k <= MAXC) break;
			gap *= 1.25;
		}
		for (c = 1; c <= k; c++) {
			e = (c < k) ? start[c+1] - 1 : n;
			cnt[c] = e - start[c] + 1; sum = 0;
			for (i = start[c]; i <= e; i++) sum += db[i];
			mean[c] = sum / cnt[c];
		}
		# dB territory of each cluster: half the distance between neighbouring means
		total = 0;
		for (c = 1; c <= k; c++) {
			lo = (c > 1) ? (mean[c] + mean[c-1]) / 2 : mean[c] - (k > 1 ? (mean[2] - mean[1]) / 2 : 0);
			hi = (c < k) ? (mean[c] + mean[c+1]) / 2 : mean[c] + (k > 1 ? (mean[k] - mean[k-1]) / 2 : 0);
			terr[c] = hi - lo; total += terr[c];
		}
		minw = MINW; if (k * minw > 127) minw = int(127 / k);
		spare = 127 - k * minw;
		acc = 0; prev = 0;
		for (c = 1; c <= k; c++) {
			w = (total > 0) ? terr[c] / total : 1 / k;
			wt = 0.5 * w + 0.5 * cnt[c] / n;
			acc += wt;
			cum = (c == k) ? 127 : int(c * minw + spare * acc + 0.5);
			bhi[c] = cum; blo[c] = prev + 1; prev = cum;
		}
		for (c = 1; c <= k; c++) {
			e = (c < k) ? start[c+1] - 1 : n;
			# gain at the bottom of the band, so this cluster starts as loud as the one below tops out
			amp = (c > 1) ? 10 ^ ((mean[c-1] - mean[c]) / 20) : 0.5;
			for (i = start[c]; i <= e; i++)
				printf("%s %s %d %d %.2f %d %d %d\n", db[i], path[i], bhi[c], bhi[c], amp, blo[c], i - start[c] + 1, cnt[c]);
		}
	}'
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

	# Cluster by loudness, allocate velocity bands, round robin within clusters
	group_seq=()
	while read -r line
	do
		group_seq+=("$line")
	done < <(printf '%s\n' "${group[@]}" | cluster_velocity "$dB_hi")
	[[ ${#group_seq[@]} -eq ${#group[@]} ]] || {
		echo "Clustering dropped samples -- now {${#group_seq[@]}}; was {${#group[@]}}" >&2
		exit 1
	}

	# Finally write out a nicely formatted line
	for i in ${!group_seq[@]}
	do
		read dB_sample sample_path vel hi_vel amp_veltrack lo_vel seq_position seq_length <<<"${group_seq[$i]}"
		curve="amp_velcurve_$hi_vel=1"
		[[ $lo_vel -lt $hi_vel ]] && curve="amp_velcurve_$lo_vel=$amp_veltrack $curve"
		echo "<region> lovel=$lo_vel hivel=$hi_vel $curve seq_position=$seq_position seq_length=$seq_length sample=../samples/$sample_path"; # dB_sample {$dB_sample}
	done > "kit_pieces/${f}.sfzh"

echo >&2 "base_path {$base_path}; f {$f}"
done < "$ranges"