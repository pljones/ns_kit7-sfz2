rm -f hh1[34]_{invcc4_,}{brs,hnd,mlt,stx}.sfz *.inc

max_psn=""
for x in hh1[34]_*_[a-z].sfz
do
	[[ $x =~ ^(hh1[34])_([^_]+)(_.+)?_([a-z])\.sfz$ ]] || continue
	hh=${BASH_REMATCH[1]}
	btr=${BASH_REMATCH[2]}
	art=${BASH_REMATCH[3]}
	psn=${BASH_REMATCH[4]}
	[[ $psn > $max_psn ]] && max_psn=$psn

	echo "#include \"hihats/${hh}_${btr}${art}_${psn}.sfz\"" >> ${hh}_${btr}${art}.inc
done


cat >/dev/null <<-\@COMMENT
Regions go from tight closed ('a') to wide open ('p').

A region triggering hi-hat position x
will be off_by a group that contains all positions less open / more closed than x.

So each triggered region has its unique group value (200-art-posn_x)
but a shared off_by group (100-posn_x-000).

Of course, two senses of FC mean two separate sets of group definitions.

sense=0 - low  CC4 means less open   ( i.e.   0 -> a; 127 -> p )
sense=1 - high CC4 means more closed ( i.e. 127 -> a;   0 -> p ) -> invcc4
@COMMENT

declare -A off_by=([a]=001 [b]=002 [c]=003 [d]=004 [e]=005 [f]=006 [g]=007 [h]=008 [i]=009 [j]=010 [k]=011 [l]=012 [m]=013 [n]=014 [o]=015 [p]=016)
declare -a keys=(${!off_by[@]})
n_keys=${#keys[@]}

declare -A lohi_locc
declare -A lohi_hicc
declare -A hilo_locc
declare -A hilo_hicc
for k in ${keys[@]}
do
	w=$(echo ${off_by[$k]} | sed -e 's/^0*//')
	lohi_locc[$k]=$(( (w - 1) * 128 / n_keys ))
	lohi_hicc[$k]=$(( ( w * 128 / n_keys ) - 1 ))
	hilo_locc[$k]=$(( (n_keys - w) * 128 / n_keys ))
	hilo_hicc[$k]=$(( ( (n_keys - (w - 1) ) * 128 / n_keys ) - 1 ))
	#echo $k ':' ${lohi_locc[$k]} ${lohi_hicc[$k]} ';' ${hilo_locc[$k]} ${hilo_hicc[$k]}
done

cat > hh_mute.inc <<-\@MUTE
<region> key=$hh_ped
<region> key=$hh_spl
<region> key=$hh_bel   locc$FC=000 hicc$FC=$HIFC
<region> key=$hh_grb
<region> key=$hh_ord_l locc$FC=000 hicc$FC=$HIFC
<region> key=$hh_ord_r locc$FC=000 hicc$FC=$HIFC
<region> key=$hh_rim   locc$FC=000 hicc$FC=$HIFC
<region> key=$hh_top_l locc$FC=000 hicc$FC=$HIFC
<region> key=$hh_top_r locc$FC=000 hicc$FC=$HIFC
<region> key=$hh_sws   locc$FC=000 hicc$FC=$HIFC
<region> key=$hh_opn   locc$FC=000 hicc$FC=$HIFC
@MUTE

{
for psn in ${keys[@]:0:$(( $n_keys - 1))}
do
	w=$(echo ${off_by[$psn]} | sed -e 's/^0*//')
	[[ $w > 1 ]] && {
		obg=${off_by[${keys[$(( w - 2 ))]}]}
	} || {
		obg=000
	}
	{
	echo "<group> sample=*silence group=100${obg}000"
	[[ $w > 1 ]] && {
		echo "#define \$HIFC ${lohi_hicc[${keys[$(( w - 2 ))]}]}"
		echo '#include "hihats/hh_mute.inc"'
	} || {
		echo '<region> key=$hh_ped'
		echo '<region> key=$hh_spl'
		echo '<region> key=$hh_grb'
	}
	} > hh_mute_steps_${psn}.inc
	echo "#include \"hihats/hh_mute_steps_${psn}.inc\""
done
} > hh_mute_steps.inc

cat > hh_mute-invcc4.inc <<-\@MUTE
<region> key=$hh_ped
<region> key=$hh_spl
<region> key=$hh_bel   locc$FC=$LOFC hicc$FC=127
<region> key=$hh_grb
<region> key=$hh_ord_l locc$FC=$LOFC hicc$FC=127
<region> key=$hh_ord_r locc$FC=$LOFC hicc$FC=127
<region> key=$hh_rim   locc$FC=$LOFC hicc$FC=127
<region> key=$hh_top_l locc$FC=$LOFC hicc$FC=127
<region> key=$hh_top_r locc$FC=$LOFC hicc$FC=127
<region> key=$hh_sws   locc$FC=$LOFC hicc$FC=127
<region> key=$hh_opn   locc$FC=$LOFC hicc$FC=127
@MUTE

{
for psn in ${keys[@]:1}
do
	w=$(echo ${off_by[$psn]} | sed -e 's/^0*//')
	[[ $w > 1 ]] && {
		obg=${off_by[${keys[$(( w - 2 ))]}]}
	} || {
		obg=000
	}
	{
	echo "<group> sample=*silence group=100${obg}000"
	[[ $w > 1 ]] && {
		echo "#define \$LOFC $(( ${hilo_hicc[$psn]} + 1 ))"
		echo '#include "hihats/hh_mute-invcc4.inc"'
	} || {
		echo '<region> key=$hh_ped'
		echo '<region> key=$hh_spl'
		echo '<region> key=$hh_grb'
	}
	} > hh_mute_steps_${psn}-invcc4.inc
	echo "#include \"hihats/hh_mute_steps_${psn}-invcc4.inc\""
done
} > hh_mute_steps-invcc4.inc

function do_fn() {
	local fn=$1; shift
	local sense=$1; shift

	[[ $fn =~ ^(hh1[34])_([^_]+)(_.+)?\.inc$ ]] || continue
	local n_psn=$(grep -c include $fn)

	[[ $fn =~ ^hh13_stx_bel(-invcc4)?.inc$ ]]
	local has_rim=$?

	local lohi_old_hicc=-1
	local hilo_old_locc=128

	local p=0
	local hh btr art psn w obg key
	local hicc locc
	local x

	while read x
	do
		[[ $x =~ /(hh1[34])_([^_]+)(_.+)?_([a-z])\.sfz ]] || continue
		((p++))
		hh=${BASH_REMATCH[1]}
		btr=${BASH_REMATCH[2]}
		art=${BASH_REMATCH[3]}
		psn=${BASH_REMATCH[4]}

		w=$(echo ${off_by[$psn]} | sed -e 's/^0*//')
		[[ $w > 1 ]] && {
			w=$(( w - 2 ))
			obg=${keys[$w]}
			obg=${off_by[$obg]}
		} || {
			obg=000
		}

		[[ $fn =~ ^hh1[34]_.{3}_opn.inc$ ]] && {
			key=opn
		} || {
			key=${art#_}
		}
		[[ $key == "" ]] && key=$btr

		echo '<group>'
		echo " key=\$hh_$key"
		[[ $key == rim ]] && {
			echo ' locc$MOD=127 hicc$MOD=127'
		} || {
			[[ $key == bel && $has_rim == 0 ]] && {
				echo ' locc$MOD=000 hicc$MOD=126'
			}
		}
		echo " group=200\$hh_${key}${obg} off_by=100${obg}000"
		[[ $n_psn > 1 ]] && {

			(( $sense )) && {
				[[ $p != $n_psn ]] && { locc=${hilo_locc[$psn]}; } || { locc=0; }
				echo " locc\$FC=$locc hicc\$FC=$(( hilo_old_locc - 1 ))"
				hilo_old_locc=$locc
			} || {
				[[ $p != $n_psn ]] && { hicc=${lohi_hicc[$psn]}; } || { hicc=127; }
				echo " locc\$FC=$(( lohi_old_hicc + 1 )) hicc\$FC=$hicc"
				lohi_old_hicc=$hicc
			}

		}
		echo $x

	done < $fn

}

for sense in 0 1
do

	(( $sense )) && {
		sfx=-invcc4.inc
	} || {
		sfx=.inc
	}

	# There is no MIDI "open" hi-hat specifically...
	# so decide on an "ord" openness to use and snatch one of the lines
	for hh in hh13 hh14
	do
		for btr in brs hnd mlt stx
		do
			fn=${hh}_${btr}_ord_r.inc
			[[ -f $fn ]] || continue
			n_ord_r=$(( 1 + ( $(grep -c 'include.*ord_r' $fn) / 2 ) ))
			grep 'include.*ord_r' $fn | sed -e "${n_ord_r}q;d" > ${hh}_${btr}_opn.inc
		done
	done

	for fn in hh1[34]_*.inc
	do
		[[ $fn == *-invcc4.inc ]] && continue
		do_fn $fn $sense > ${fn}-x
		mv ${fn}-x ${fn%.inc}${sfx}
	done

	# There are no hh14_brs_top_l samples...
	cp hh14_brs_top_r${sfx} hh14_brs_top_l${sfx}

done

function do_keys() {
	local hh=$1; shift
	local btr=$1; shift
	local sense=$1; shift
	local ped spl bel grb ord_l ord_r rim top_l top_r sws opn
	local sfx key
	local -A keymap=([ped]=044 [spl]=020 [bel]=022 [grb]=029 [ord_l]=017 [ord_r]=041 [rim]=022 [top_l]=018 [top_r]=042 [sws]=022 [opn]=046)

	(( $sense )) && {
		sfx=-invcc4.inc
	} || {
		sfx=.inc
	}

	for key in ${!keymap[@]}
	do
		local -n kref=$key
		case $key in
			ped|spl)
				fn=${hh}_${key}
			;;
			*)
				fn=${hh}_${btr}_${key}
			;;
		esac
		[[ -f "${fn}${sfx}" ]] && {
			kref=1
		} || {
			kref=0
			[[ $btr == brs && $key == rim ]] && kref=2
			[[ $btr != brs && $key == sws ]] && kref=2
		}
		unset -n kref
	done

	for key in ped spl bel grb ord_l ord_r rim top_l top_r sws opn
	do
		local -n kref=$key
		case "${hh}_${btr}_${key}" in
			hh1[34]_brs_ord*)
				[[ $key == *_l ]] && {
					echo "#define \$hh_${key} ${keymap[top_l]}"
				} || {
					echo "#define \$hh_${key} ${keymap[top_r]}"
				}
			;;
			*)
				case $kref in
					1) echo "#define \$hh_${key} ${keymap[${key}]}" ;;
#					2) echo "//#define \$hh_${key} ${keymap[${key}]}" ;;
					*) echo "#define \$hh_${key} 1${keymap[${key}]}" ;;
				esac
			;;
		esac
		unset -n kref
	done

	echo ""
	echo "#include \"hihats/hh_mute_steps${sfx}\""
	echo ""

	(( $ped )) || echo -n '//'; echo "#include \"hihats/${hh}_ped${sfx}\""
	(( $spl )) || echo -n '//'; echo "#include \"hihats/${hh}_spl${sfx}\""

	for key in bel grb ord_l ord_r rim top_l top_r sws opn
	do
		local -n kref=$key
		[[ $kref != 1 ]] && echo -n '//'; echo "#include \"hihats/${hh}_${btr}_${key}${sfx}\""
		unset -n kref
	done

}

function do_kits() {
	local sense=$1; shift
	local sfx hh btr

	(( $sense )) && {
		invcc4=invcc4_
	} || {
		invcc4=
	}

	for hh in hh13 hh14
	do
		for btr in brs hnd mlt stx
		do
			do_keys $hh $btr $sense > ${hh}_${invcc4}${btr}.sfz
		done
	done

}

for sense in 0 1
do
	do_kits $sense
done
