#!/bin/bash
rm -f *inc
for x in *.sfz
do
	[[ $x =~ ^(.+_)cy(.+)_.+\.sfz$ ]] && echo "#include \"cymbals/$x\"" >> ${BASH_REMATCH[1]}${BASH_REMATCH[2]}.inc
done
#cat >/dev/null <<-\#EOF
for fn in *inc
do {
	# Some bel articulations are straight triggers:
	[[ $fn =~ ^ride_(19_(brs|mlt|stx)|20_(brs|stx))\.inc$ ]]
	has_bel=$?

	#crs - only ride_19_stx

	#ride_20_elv is a trigger
	[[ $fn =~ ^(ride_19|sizzle_19)_stx.inc$ ]]
	has_elv=$?

	#grb/grc/grt - everything (ride_19_stx is complicated)

	#ord - everything

	#rim/rol/sws - only ever one; the following DO NOT have one
	[[ $fn =~ ^(.+_hnd|sizzle_19.+|(china_19|splash_[89])_stx).inc$ ]]
	no_rim=$?

	[[ $fn =~ ^(china_19|crash_1[58]|splash_12)_stx.inc$ ]]
	has_top=$?

	while read x
	do
		[[ $x =~ /(.+)_cy(.+)_(.+)_(.+)\.sfz ]] || continue
		cy=${BASH_REMATCH[1]}
		sz=$(( 0 + ${BASH_REMATCH[2]} ))
		bt=${BASH_REMATCH[3]}
		art=${BASH_REMATCH[4]}

		# Working out what key
		key="${cy}_${sz}"
		if [[ $art == ord || $art == top || ( $art == bel && "$cy$sz" =~ ^(ride(19|20)|sizzle19)$ ) ]]
		then
			key="${key}_${art}"
		elif [[ "$cy$sz" == "splash8" && $art =~ ^bel|rol$ ]]
		then
			key="${key}_ord"
		elif [[ $art == gr[bt] ]]
		then
			key="${key}_ord"
		elif [[ $art == grc ]]
		then
			key="${key}_top"
		elif [[ $art =~ ^bel|crs|elv|rim|rol|sws$ ]]
		then
			key="${key}_top"
		fi

		echo '<group>'
		echo " key=\$cy_${key}"
		[[ $art == gr[bct] ]] && {
			echo " group=500\$cy_${cy}_${sz}_ord000"
		} || {
			echo " group=600\$cy_${cy}_${sz}_ord000 off_by=500\$cy_${cy}_${sz}_ord000"
		}

		case $art in
			ord)
				echo ' locc$MOD=000 hicc$MOD=126'
				[[ $fn == *_hnd.inc ]] && {
                                    echo $x
                                    echo '<group>'
                                    echo " key=\$cy_${key/ord/top}"
                                    echo " group=600\$cy_${cy}_${sz}_ord000 off_by=500\$cy_${cy}_${sz}_ord000"
				}
			;;
			top)
				[[ $has_bel == 0 || $has_elv == 0 ]] && {
					echo ' locc$MOD=000 hicc$MOD=045'
				} || {
					[[ $no_rim != 0 ]] && echo ' locc$MOD=000 hicc$MOD=085'
				}
			;;
			bel)
				if [[ $has_bel == 0 ]]
				then
					[[ $no_rim != 0 ]] && { echo ' locc$MOD=046 hicc$MOD=127'; } || { echo ' locc$MOD=046 hicc$MOD=085'; }
				fi
			;;
			crs)
				echo ' locc$MOD=000 hicc$MOD=045'
			;;
			elv)
				[[ $has_elv == 0 ]] && {
					[[ $no_rim != 0 ]] && { echo ' locc$MOD=046 hicc$MOD=085'; } || { echo ' locc$MOD=046 hicc$MOD=126'; }
				}
			;;
			gr[bct])
				echo ' locc$MOD=127 hicc$MOD=127'
			;;
			sws)
				echo ' locc$MOD=000 hicc$MOD=085'
				echo ${x/sws/ord}
				echo '<group>'
				echo " key=\$cy_${key}"
				echo " group=600\$cy_${cy}_${sz}_ord000 off_by=500\$cy_${cy}_${sz}_ord000"
				echo ' locc$MOD=086 hicc$MOD=127'
			;;
			rim)
				[[ $fn == ride_19_stx.inc ]] && {
				 	echo ' locc$MOD=086 hicc$MOD=126'
				} || {
					[[ $has_bel == 0 ]] && {
						[[ $has_elv == 0 ]] && { echo ' locc$MOD=086 hicc$MOD=127'; } || { echo ' locc$MOD=046 hicc$MOD=127'; }
					} || {
						[[ $has_elv == 0 ]] && { echo ' locc$MOD=086 hicc$MOD=127'; }
					}
				}
			;;
			rol)
				[[ $has_bel == 0 ]] && {
					[[ $has_elv == 0 ]] && { echo ' locc$MOD=086 hicc$MOD=127'; } || { echo ' locc$MOD=046 hicc$MOD=127'; }
				} || {
					[[ $has_elv == 0 ]] && { echo ' locc$MOD=086 hicc$MOD=127'; }
				}
				echo " group=601\$cy_${cy}_${sz}_ord000 off_by=100000000"
			;;
		esac
		echo $x
	done < $fn
	} > x
	mv x $fn
done
#EOF
#cat >/dev/null <<-\#EOF
rm -f {brs,hnd,mlt,stx}_{ride19,sizzle19}.sfz
for y in ride19 sizzle19
do
	for x in *.inc
	do
		[[ $x =~ ^(.+)_(.+)_(.+)\.inc$ ]] || continue
		[[ $y == ride19 && $x == sizzle_19* ]] && continue
		[[ $y == sizzle19 && $x == ride_19* ]] && continue
		#crash_15_mlt.inc crash 15 mlt
		cy=${BASH_REMATCH[1]}
		sz=${BASH_REMATCH[2]}
		btr=${BASH_REMATCH[3]}
		echo "#include \"cymbals/$x\"" >> ${btr}_${y}.sfz
	done
done
#EOF
#cat >/dev/null <<-\#EOF
for x in {brs,hnd,mlt,stx}_{ride19,sizzle19}.sfz
do
	cat > x <<-\@EOF
		#define $cy_china_19_ord 052
		#define $cy_crash_15_ord 057
		#define $cy_crash_18_ord 049
		#define $cy_ride_20_ord 051
		#define $cy_splash_8_ord 055
		#define $cy_splash_9_ord 058
		#define $cy_splash_12_ord 054

		#define $cy_china_19_top 28
		#define $cy_splash_9_top 32
		#define $cy_crash_15_top 33
		#define $cy_crash_18_top 25
		#define $cy_ride_20_top 27
		#define $cy_splash_12_top 30
		#define $cy_splash_8_top 31
		//Does not appear to be mapped (for /rol):

		#define $cy_ride_20_bel 53

@EOF
	[[ $x == *ride19.sfz ]] && cat >> x <<-\@EOF
		//cy_ride_19 kit
		#define $cy_ride_19_ord 059
		#define $cy_ride_19_top 34
		#define $cy_ride_19_bel 60

@EOF
	[[ $x == *sizzle19.sfz ]] && cat >> x <<-\@EOF
		//cy_sizzle_19 kit
		#define $cy_sizzle_19_ord 059
		#define $cy_sizzle_19_top 34
		#define $cy_sizzle_19_bel 60

@EOF
	cat $x >> x
	mv x $x
done
#EOF
