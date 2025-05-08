rm -f *inc
for x in *sfz
do
	[[ $x =~ ^(.+o[fn]f?)_.+\.sfz$ ]] && echo "#include \"snares/$x\"" >> ${BASH_REMATCH[1]}.inc
done

# Sadly, some extra magic is needed at this point.
grep 'inc.*sw' sn12_bop_brs_snare_on.inc >> sn12_bop_brs_snare_off.inc
grep 'inc.*clsrls_r' sn12_bop_brs_snare_on.inc >> sn12_bop_brs_snare_off.inc

for fn in *inc
do

	[[ $fn =~ ^sn.+_brs_snare_o(n|ff).inc$ ]]
	is_brs=$?

	[[ $fn =~ ^sn.+_hnd_snare_o(n|ff).inc$ ]]
	is_hnd=$?

	[[ $fn =~ ^(sn10_jungle|sn12_(bop_muted|bop_open|funk|orleans|tight)|sn14_rock)_stx_snare_on.inc$ ]]
	has_rol=$?

	[[ $fn =~ (sn10_jungle_stx_snare_(off|on)|sn12_bop_(muted_stx_snare_on|open_stx_snare_off)) ]]
	has_rim=$?

	[[ $fn == sn14_rock_brs_snare_on.inc || $fn == sn12_bop_brs_snare_*.inc ]]
	has_sw=$?

	{
	[[ $is_hnd == 0 ]] && {
		echo '#define $sn_slp_l 13'
		echo '#define $sn_slp_r 37'
	}
	[[ $fn == sn12_funk_brs_snare_on.inc ]] && {
		cat <<-\@EOF
		#define $sn_cls_l 14
		#define $sn_cls_r 38

@EOF
	} ||  { [[ $is_brs == 0 ]] && {
		cat <<-\@EOF
		#define $sn_sws 13
		#define $sn_opn_l 14
		#define $sn_rms_l 15
		#define $sn_cls_l 16
		#define $sn_swc 17
		#define $sn_swl 37
		#define $sn_opn_r 38
		#define $sn_rms_r 39
		#define $sn_cls_r 40
		#define $sn_swu 41

@EOF

		if [[ $has_sw == 0 ]]
		then
			cat <<-\@EOF
<group> sample=*silence
 group=301000000
<region> lokey=013 hikey=034

@EOF
		fi
	}; } || {
		cat <<-\@EOF
		#define $sn_xtka 13
		#define $sn_ord_l 14
		#define $sn_e2c_l 14
		#define $sn_rms_l 15
		#define $sn_rmh_l 15
		#define $sn_rim_l 15
		#define $sn_prs_l 16
		#define $sn_rol_l 16
		#define $sn_xtkb 37
		#define $sn_ord_r 38
		#define $sn_e2c_r 38
		#define $sn_rms_r 39
		#define $sn_rmh_r 39
		#define $sn_rim_r 39
		#define $sn_prs_r 40
		#define $sn_rol_r 40

@EOF
	}

	while read x
	do
		[[ $x =~ (sn1.?)_(.*)_([^_]+)_(snare_o[nf]f?)_(.+).sfz ]] || continue
		key=${BASH_REMATCH[5]}
		[[ $key == *x || $key == sw[ls]rpt ]] && continue

		echo '<group>'
		if [[ $key != xtk && $key != xtkc && $key != rol && $key != rim && $key != clsrls_[lr] ]]
		then
			echo " key=\$sn_$key"
		fi
		case $key in
			xtk[ab])
				[[ $fn == sn12_bop_muted_stx_snare_on.inc ]] && echo ' lorand=0 hirand=0.75'
				;;
			xtk|xtkc)
				echo ' key=$sn_xtka'
				[[ $key == xtkc ]] && echo ' lorand=0.75 hirand=1'
				echo $x
				echo '<group>'
				echo ' key=$sn_xtkb'
				[[ $key == xtkc ]] && echo ' lorand=0.75 hirand=1'
				;;
			clsrls_[lr])
				[[ $fn == sn12_bop_brs_snare_off.inc && $x == *_snare_on_* ]] && {
					echo ' key=$sn_swu'
				} || {
					echo " key=\$sn_${key/rls/}"
				}
				echo ' trigger=release'
				;;
			ord_[lr])
				if [[ $fn =~ ^((sn10_jungle|sn12_(bop_muted|bop_open|funk|tight))_stx_snare_on|sn12_bop_open_stx_snare_off).inc$ ]]
				then
					echo ' locc$MOD=000 hicc$MOD=045'
				fi
				;;
			e2c_[lr])
				echo ' locc$MOD=046 hicc$MOD=127'
				;;
			prs_[lr])
				if [[ $has_rol == 0 ]] 
				then
					echo ' locc$MOD=000 hicc$MOD=085'
				fi
				;;
			rol)
				echo ' key=$sn_rol_l'
				echo ' group=400$sn_rol_l000 off_by=100000000'
				echo ' locc$MOD=086 hicc$MOD=127'
				echo $x
				echo '<group>'
				echo ' key=$sn_rol_r'
				echo ' group=400$sn_rol_r000 off_by=100000000'
				echo ' locc$MOD=086 hicc$MOD=127'
				;;
			rms_[lr])
				if [[ $fn =~ ^(sn10_jungle_stx_snare_(off|on)|sn12_(bop_open_stx_snare_off|(bop_muted|bop_open|funk|orleans|tight)_stx_snare_on)).inc$ ]]
				then
					echo ' locc$MOD=000 hicc$MOD=085'
				fi
				;;
			rmh_[lr])
				if [[ $has_rim == 0 ]]
				then
					echo ' locc$MOD=086 hicc$MOD=126'
				else
					echo ' locc$MOD=086 hicc$MOD=127'
				fi
				;;
			rim)
				echo ' key=$sn_rim_l'
				echo ' locc$MOD=127 hicc$MOD=127'
				echo $x
				echo '<group>'
				echo ' key=$sn_rim_r'
				echo ' locc$MOD=127 hicc$MOD=127'
				;;
			swc)
				echo ' group=401$sn_swc000 off_by=301000000'
				echo ' loop_mode=loop_sustain'
				;;
			sw[ls])
				echo " group=302\$sn_${key}000"
				{
				# rock kit uses swsrpt on both swl and sws repeats
				[[ $fn == sn14_rock_brs_snare_on.inc && $key == swl ]] && {
					echo ${x/swl/sws}
				} || {
					echo $x
				}
				} | sed -e 's/\.sfz/rpt&/'
				echo '<group>'
				echo " key=\$sn_${key}"
				echo " group=402\$sn_${key}000 off_by=302${key}000"
				echo ' trigger=release ampeg_release=0'
				echo ' volume=-15'
				;;
		esac
		echo $x
	done < $fn
	} > x
	mv x $fn
done
