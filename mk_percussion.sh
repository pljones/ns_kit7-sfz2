#!/bin/bash
rm -f *inc
for x in cowbell_pn*.sfz
do
	[[ $x =~ ^(.+_)pn(._...)_.+\.sfz$ ]] && echo "#include \"percussion/$x\"" >> ${BASH_REMATCH[1]}${BASH_REMATCH[2]}.inc
done
#cat >/dev/null <<-\#EOF
for fn in cowbell_8*inc
do
	[[ $fn =~ ^cowbell_8_(mlt|stx).inc$ ]]
	has_mo=$?

	{

	echo '#define $pn_cowbell_ord 56'
	[[ $fn == cowbell_8_stx.inc ]] && echo '#define $pn_cowbell_top 32'
	echo ''

	while read x
	do
		#include "cymbals/cowbell_pn8_brs_ord.sfz"
		[[ $x =~ cowbell_pn8_(...)(_muted|_open)?_(...)\.sfz  ]] || continue
		bt=${BASH_REMATCH[1]}
		mo=${BASH_REMATCH[2]}
		art=${BASH_REMATCH[3]}

		echo '<group>'
		echo " key=\$pn_cowbell_${art}"

		if [[ $has_mo == 0 ]]
		then
			[[ "$mo" == "_open" ]] && {
				echo ' locc$MOD=000 hicc$MOD=085'
			} || {
				echo ' locc$MOD=086 hicc$MOD=127'
			}
		fi

		echo $x
	done < $fn

	} > x
	mv x $fn
done
##EOF
cat > tambourine_9_hnd.inc <<-\#EOF
//Steal cy_ride_20_top and cy_splash_12_top keys as not used for hnd
#define $pn_tamborine_hit 27
#define $pn_tamborine_jng 030

// Fix up for normalised samples
<curve> curve_index=99 v1=0.03125 v127=1

<group> amplitude=4.42 amp_veltrack=0 amplitude_oncc131=100 amplitude_curvecc131=99
 key=$pn_tamborine_hit
 locc$MOD=000 hicc$MOD=085
#include "percussion/tambourine_pn9_hnd_hit.sfz"
<group> amplitude=4.42 amp_veltrack=0 amplitude_oncc131=100 amplitude_curvecc131=99
 key=$pn_tamborine_hit
 locc$MOD=086 hicc$MOD=127
#include "percussion/tambourine_pn9_hnd_thm.sfz"
<group> amplitude=4.42 amp_veltrack=0 amplitude_oncc131=100 amplitude_curvecc131=99
 key=$pn_tamborine_jng
 locc$MOD=000 hicc$MOD=045
#include "percussion/tambourine_pn9_hnd_jng_l.sfz"
<group> amplitude=4.42 amp_veltrack=0 amplitude_oncc131=100 amplitude_curvecc131=99
 key=$pn_tamborine_jng
 locc$MOD=046 hicc$MOD=085
#include "percussion/tambourine_pn9_hnd_jng_r.sfz"
<group> amplitude=4.42 amp_veltrack=0 amplitude_oncc131=100 amplitude_curvecc131=99
 key=$pn_tamborine_jng
 group=800$pn_tamborine_jng000 off_by=100000000
 locc$MOD=086 hicc$MOD=127
#include "percussion/tambourine_pn9_hnd_rol.sfz"
#EOF
