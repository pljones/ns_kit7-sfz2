rm -f *inc
for x in *sfz
do
	[[ $x =~ ^(.+o[fn].?)_.+\.sfz$ ]] && echo "#include \"kicks/$x\"" >> ${BASH_REMATCH[1]}.inc
done

for fn in *inc
do {
	cat <<-\@EOF
		#define $kd_cls_a 11
		#define $kd_opn_a 12
		#define $kd_cls_b 35
		#define $kd_opn_b 36

@EOF

	while read x
	do
		[[ $x =~ (kd..)_([^_]+)_(snare_o[nf]f?)_(.+).sfz ]] || continue
		key=${BASH_REMATCH[4]}
		[[ $key = *x ]] && continue

		echo '<group>'
		if [[ $key != cls && $key != opn ]]
		then
			echo " key=\$kd_$key"
		else
			echo " key=\$kd_${key}_a"
			echo $x
			echo '<group>'
			echo " key=\$kd_${key}_b"
		fi
		echo $x
	done < $fn
	} > x
	mv x $fn
done
