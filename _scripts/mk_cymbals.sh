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
	[[ $fn =~ ^((ride|sizzle)_19|ride_20)_.+$ ]]
	has_bel=$?

	#crs - only ride_19_stx

	#elv - trigger for ride_20_stx, else articulation

	#grb/grt - everything (grt for ride_19_stx)

	#grc - only ride_19_stx

	#ord - everything

	#rim - stx not china_19, splash_8 or splash_9

	#rol - mlt but splash_9_mlt is different

	#sws - brs but splash_9_brs is different

	#top - stx (faked for bel/rol/sws - except for splash_9, which uses ord)

	while read x
	do
		[[ $x =~ /(.+)_cy(.+)_(.+)_(.+)\.sfz ]] || continue
		cy=${BASH_REMATCH[1]}
		sz=$(( 0 + ${BASH_REMATCH[2]} ))
		bt=${BASH_REMATCH[3]}
		art=${BASH_REMATCH[4]}

		# Working out what key
		key="${cy}_${sz}"
		if [[ $art == ord || $art == top || ( $art == bel && $has_bel == 0 ) ]]
		then
			key="${key}_${art}"
		elif [[ $art == rim && "${cy}${sz}" == ride19 ]]
		then
			key="${key}_bel"
		elif [[ $art == gr[bt] || "${cy}${sz}" == splash9 ]]
		then
			key="${key}_ord"
		else
			key="${key}_top"
		fi

		echo '<group>'
		echo " key=\$cy_${key}"

		if [[ $art == gr[bct] ]]
		then
			echo " group=500\$cy_${cy}_${sz}_ord000"
		else
			[[ $art != rol ]] && echo " group=600\$cy_${cy}_${sz}_ord000 off_by=500\$cy_${cy}_${sz}_ord000"
		fi

		# Sometimes we need to fake a trigger
		if [[ ( "${cy}${sz}" == splash8 && $art == bel ) || ( "${cy}${sz}" != splash9 && ( $art == rol || $art == sws ) ) ]]
		then
			[[ $art == rol ]] && echo " group=600\$cy_${cy}_${sz}_ord000 off_by=500\$cy_${cy}_${sz}_ord000"
			echo ' locc$MOD=000 hicc$MOD=045'
			echo ${x/${art}/ord}
			echo '<group>'
			echo " key=\$cy_${key}"
			[[ $art != rol ]] && echo " group=600\$cy_${cy}_${sz}_ord000 off_by=500\$cy_${cy}_${sz}_ord000"
		fi

		case $art in
			bel)
				# Sometimes trigger; splash 8 articulation needs fake trigger
				if [[ $has_bel == 0 ]]
				then
					[[ "${cy}${sz}" == ride19 ]] && { echo ' locc$MOD=000 hicc$MOD=085'; }
				else
					[[ "${cy}${sz}" == splash8 ]] && { echo ' locc$MOD=046 hicc$MOD=127'; } || { echo ' locc$MOD=046 hicc$MOD=085'; }
				fi
			;;
			crs)
				# Always trigger
				echo ' locc$MOD=000 hicc$MOD=085'
			;;
			elv)
				# Ride 19, crs articulation; ride 20 trigger
				[[ $sz == 19 ]] && { echo ' locc$MOD=086 hicc$MOD=126'; } || { echo ' locc$MOD=000 hicc$MOD=085'; }
			;;
			gr[bct])
				# Never trigger
				echo ' locc$MOD=127 hicc$MOD=127'
			;;
			ord)
				# Always trigger - splash9 allow for rol/sws
				[[ $fn =~ ^splash_9_(brs|mlt)\.inc$ ]] && { echo ' locc$MOD=000 hicc$MOD=045'; } || { echo ' locc$MOD=000 hicc$MOD=126'; }
			;;
			rim)
				# Never trigger
				echo ' locc$MOD=086 hicc$MOD=127'
			;;
			rol|sws)
				# Never trigger
				[[ "${cy}${sz}" == splash9 ]] && { echo ' locc$MOD=046 hicc$MOD=126'; } || { echo ' locc$MOD=046 hicc$MOD=127'; }
				[[ $art == rol ]] && echo " group=601\$cy_${cy}_${sz}_ord000 off_by=100000000"
			;;
			top)
				# Always trigger
				[[ $cy == china ]] && { echo ' locc$MOD=000 hicc$MOD=085'; } || { echo ' locc$MOD=000 hicc$MOD=045'; }
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
	cy=$(basename -s 19.sfz ${x:4})
	{
	echo "//cy_${cy} kit"
	cat <<-\@EOF
		#define $cy_crash_18_top 25
		#define $cy_ride_20_top 27
		#define $cy_china_19_top 28
		#define $cy_splash_12_top 30
		#define $cy_splash_8_top 31
		#define $cy_crash_15_top 33
		// no cy_splash_9_top
@EOF
	echo   "#define \$cy_${cy}_19_top 34"
	echo   ""
	cat <<-\@EOF
		#define $cy_crash_18_ord 049
		#define $cy_ride_20_ord 051
		#define $cy_china_19_ord 052
		#define $cy_splash_12_ord 054
		#define $cy_splash_8_ord 055
		#define $cy_crash_15_ord 057
		#define $cy_splash_9_ord 058
@EOF
	echo   "#define \$cy_${cy}_19_ord 059"
	echo   ""
	echo   "#define \$cy_ride_20_bel 53"
	echo   "#define \$cy_${cy}_19_bel 60"
	echo   ""
	} > x
	cat $x >> x
	mv x $x
done
#EOF
