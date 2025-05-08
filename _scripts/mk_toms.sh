rm -f *{n,ff}.sfz *inc

# Fix missing articulations
for x in off on
do
	for y in tm*_${x}*.sfz
	do
		[[ $y = *[lr]x.sfz ]] && continue
		[[ $y =~ ^(.+_o[nf]f?)_.+\.sfz$ ]] && echo "#include \"toms/$y\"" >> ${BASH_REMATCH[1]}.inc
		if [[ $x == off ]]
		then
			z=${y/_off/_on}
		else
			z=${y/_on/_off}
		fi
		[[ -f $z ]] && continue
		[[ $z =~ ^(.+_o[nf]f?)_.+\.sfz$ ]] && echo "#include \"toms/$y\"" >> ${BASH_REMATCH[1]}.inc
	done
done

# Fix missing kit pieces
for x in off on
do
	for y in tm*_*_*_snare_${x}.inc
	do
		if [[ $x == off ]]
		then
			z=${y/_off.inc/_on.inc}
		else
			z=${y/_on.inc/_off.inc}
		fi
		[[ -f $z ]] && continue
		rm -f $z
		cp $y $z
	done
done

#cat >/dev/null <<-\@FOO
for fn in *inc
do {
	[[ $fn =~ ^(tm..?_)(bop|rock)_stx_snare_o[fn]f?.inc$ ]]
	has_rms=$?

	[[ $fn =~ ^(tm..?_)(bop|rock)_stx_snare_o[fn]f?.inc$ ]]
	has_rim=$?

	while read x
	do
		[[ $x =~ (tm..?)_([^_]+)_([^_]+)_(snare_o[nf]f?)_([^_]+)(_.+)?.sfz ]] || continue
		key=${BASH_REMATCH[1]}
		art=${BASH_REMATCH[5]}
		sfx=${BASH_REMATCH[6]}
		[[ $sfx = *x ]] && continue
		sfx=${sfx#_}

		echo '<group>'
		if [[ $sfx != "" ]]
		then
			echo " key=\$${key}_${sfx}"
		else
			echo " key=\$${key}_l"
			echo ' locc$MOD=127 hicc$MOD=127'
			echo $x
			echo '<group>'
			echo " key=\$${key}_r"
			echo ' locc$MOD=086 hicc$MOD=127'
		fi
		if [[ $art == ord ]]
		then
			if [[ $has_rms == 0 ]]
			then
				if [[ "${key}_${sfx}" != tm1[46]_l ]]
				then
					echo ' locc$MOD=000 hicc$MOD=045'
				elif [[ $has_rim == 0 ]]
				then
					echo ' locc$MOD=000 hicc$MOD=126'
				fi
			fi
		fi
		if [[ $art == rms ]]
		then
			if [[ $has_rim == 0 ]]
			then
				if [[ $sfx == l ]]
				then
					echo ' locc$MOD=046 hicc$MOD=126'
				else
					echo ' locc$MOD=046 hicc$MOD=085'
				fi
			else
				echo ' locc$MOD=046 hicc$MOD=127'
			fi
		fi
		echo $x
	done < $fn
	} > x
	mv x $fn
done
#cat >/dev/null <<-\@
rm -f *{on,off}.sfz
for x in *.inc
do
	[[ $x =~ ^(tm..?)_([^_]+)_([^_]+)_(snare_o[nf]f?).inc$ ]] || continue
	#tm8_rock_stx_snare_off.inc tm8 rock stx snare_off
	hd=${BASH_REMATCH[2]}
	btr=${BASH_REMATCH[3]}
	sn=${BASH_REMATCH[4]}
	echo "#include \"toms/$x\"" >> ${hd}_${btr}_${sn}.sfz
done

for x in *{on,off}.sfz
do
	cat > x <<-\@EOF
		#define $tm8_l 26
		#define $tm8_r 50
		#define $tm10_l 24
		#define $tm10_r 48
		#define $tm12_l 23
		#define $tm12_r 47
		#define $tm14_l 21
		#define $tm14_r 45
		#define $tm16_l 19
		#define $tm16_r 43

@EOF
	cat $x >> x
	mv x $x
done
