#!/bin/bash -e
print_range() {
	local nr=$1; shift
	local db1=$1; shift
	local db3=$1; shift
	local sample1=$1; shift
	local sample3=$1; shift

	echo $db1 $db3 | \
	awk '{ print $1 - $2}' | {
		read dbD
		echo $nr $db1 $db3 $dbD ${sample3%???.wav}
	}
}

grep '[0-9].wav$' ns_kits7-all_samples-db.txt | {
	nr=1
	db3=""
	sample3=""
	read db1 sample1
	while read db2 sample2
	do
		[[ "${sample1%???.wav}" == "${sample2%???.wav}" ]] && {
			(( nr++ ))
			db3="$db2"
			sample3="$sample2"
			continue
		}
		print_range "$nr" "$db1" "$db3" "$sample1" "$sample3"
		nr=1
		db3=""
		sample3=""
		db1=$db2
		sample1=$sample2
	done
	print_range "$nr" "$db1" "$db3" "$sample1" "$sample3"
}
