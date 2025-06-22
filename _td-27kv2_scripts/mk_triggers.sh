#!/bin/bash -eu
exit 1

# Do not use this

declare -A grabcc zonecc handcc
declare -A kit1 kit2 kit3 kit4
declare -A kick snare tom1 tom2 tom3 crash1 crash2 ride aux1 aux2 aux3
declare -A hihat_open hihat_closed hihat_pedal

zone_inner='locc{GP}=000 hicc{GP}=063'
zone_outer='locc{GP}=064 hicc{GP}=127'
grab_free='lo{GP}=000 hi{GP}=063'
grab_held='lo{GP}=064 hi{GP}=127'
hand_left='locc{GP}=000 hicc{GP}=063'
hand_right='locc{GP}=064 hicc{GP}=127'

: <<-'@EOF'
// Control Nos
fc      = 4;  // 0x04;
gp1     = 16; // 0x10; # snare inner/outer
gp2     = 17; // 0x11; # ride inner/outer
gp3     = 18; // 0x12;
gp4     = 19; // 0x13; # hihat inner/outer
gp5     = 80; // 0x50;
gp6     = 81; // 0x51;
gp7     = 82; // 0x52;
gp8     = 83; // 0x53; # hihat left/right
hrVel   = 88; // 0x58; 
@EOF

# Foot Controller is use is built into the hi-hat kit piece files
grabcc=([crash1]='polyaft' [crash2]='polyaft' [ride]='polyaft')
zonecc=([snare]='016' [ride]='017' [hihat]='019')
handcc=([hihat]='083')

: <<-'@EOF'
// TD-27 default trigger note assignments
kick           = 36;
@EOF
kick=([head]=36)

kit1[kick]='kd20_full_snare_on'
kit2[kick]='kd20_full_snare_on'
kit3[kick]='kd20_full_snare_on'
kit4[kick]='kd20_full_snare_on'

: <<-'@EOF'
snareHead      = 38;
snareRim       = 40;
snareBrush     = 23; // but this is just head with brush mode on
snareXstick    = 37;
@EOF
snare=([head]=38 [rim]=40 [brush]=23 [xstick]=37)

kit1[snare]='sn14_rock_stx_snare_on'
kit2[snare]='sn14_rock_stx_snare_on'
kit3[snare]='sn14_rock_stx_snare_on'
kit4[snare]='sn14_rock_stx_snare_on'

: <<-'@EOF'
tom1Head       = 48;
tom1Rim        = 50;
tom2Head       = 45;
tom2Rim        = 47;
tom3Head       = 43;
tom3Rim        = 58;
@EOF
tom1=([head]=48 [rim]=50)
tom2=([head]=45 [rim]=47)
tom3=([head]=43 [rim]=58)

kit1[tom1]='tm12_rock_stx_snare_on'
kit1[tom2]='tm14_rock_stx_snare_on'
kit1[tom3]='tm16_rock_stx_snare_on'

kit2[tom1]='tm10_rock_stx_snare_on'
kit2[tom2]='tm14_rock_stx_snare_on'
kit2[tom3]='tm16_rock_stx_snare_on'

kit3[tom1]='tm8_rock_stx_snare_on'
kit3[tom2]='tm12_rock_stx_snare_on'
kit3[tom3]='tm14_rock_stx_snare_on'

kit4[tom1]='tm8_rock_stx_snare_on'
kit4[tom2]='tm12_rock_stx_snare_on'
kit4[tom3]='tm16_rock_stx_snare_on'


: <<-'@EOF'
hiHatOpenBow   = 46;
hiHatOpenEdge  = 26;
hiHatCloseBow  = 42;
hiHatCloseEdge = 22;
hiHatPedal     = 44;
@EOF
# Hihat gets triggered by notes 46 and 26 when open (fc > 10?)
hihat_open=([top]=46 [rim]=26)
# Hihat gets triggered by notes 42 and 22 when closed (fc <= 10?)
hihat_closed=([top]=42 [rim]=22)
# Hihat pedal triggers okay but I don't think there's a "splash"
# ... or rather, "ped" is a "choked" splash... hm... this might work
hihat_pedal=([ped]='44 locc004=000 hicc004=010' [spl]='44 locc004=011 hicc004=127')

kit1[hihat_open]=

: <<-'@EOF'
crash1Bow      = 49;
crash1Edge     = 55;
crash2Bow      = 57;
crash2Edge     = 52;
@EOF
crash1=([top]=49 [rim]=55)
crash2=([top]=57 [rim]=52)

kit1[crash1]='splash_12'
kit2[crash1]='splash_8'
kit3[crash1]='crash_15'
kit4[crash1]='splash_9'

kit1[crash2]='crash_18'
kit2[crash2]='crash_15'
kit3[crash2]='china_19'
kit4[crash2]='crash_18'

: <<-'@EOF'
rideBow        = 51;
rideEdge       = 59;
rideBell       = 53;
@EOF
ride=([bel]=53 [top]=51 [rim]=59)

kit1[ride]='ride_19'
kit2[ride]='ride_20'
kit3[ride]='sizzle_19'
kit4[ride]='ride_19'

: <<-'@EOF'
aux1Head       = 27;
aux1Rim        = 28;
aux2Head       = 29;
aux2Rim        = 30;
aux3Head       = 31;
aux3Rim        = 32;
@EOF
aux1=([head]=27 [rim]=28)
aux2=([head]=29 [rim]=30)
aux3=([head]=31 [rim]=32)

#crash2 does not have a bell trigger but we can steal aux3 head
#crash2=([top]=57 [rim]=52)
crash2[bel]=${aux3[rim]}

function mk_kit_cymbals () {
	local kit=$1; shift || {
		echo "Missing kit array name" >&2
		exit 1
	}
	local trigger=$1; shift || {
		echo "Missing trigger" >&2
	}
	local cy pos zone grab kit_piece z

	[[ $trigger =~ ^\$([^_]*_[0-9]*)_(bel|top|rim)(|_inner|_outer)(|_free|_held)$ ]] || {
		echo "Unexpected trigger {$trigger}" >&2
		exit 1
	}
	cy=${BASH_REMATCH[1]}
	pos=${BASH_REMATCH[2]}
	zone="$([[ "x${BASH_REMATCH[3]}" == "x" ]] && echo '' || {
		[[ ${BASH_REMATCH[3]} == _inner ]] && echo $zone_inner || echo $zone_outer
	})"
	grab="$([[ "x${BASH_REMATCH[4]}" == "x" ]] && echo '' || {
		[[ ${BASH_REMATCH[4]} == _free ]] && echo $grab_free || echo $grab_held
	})"

	for kit_piece in $(eval echo '${!'$kit'[@]}')
	do
		[[ $(eval echo '${'$kit'['$kit_piece']}') == $cy ]] || continue
		z=$(eval [[ -v $kit_piece[$pos] ]] && echo $(eval echo '${'$kit_piece'['$pos']}') || echo '')
		[[ "x$z" != "x" ]] || { echo "$d $trigger -1"; continue; }
#echo >&2 "cy {$cy}; pos {$pos}; kit_piece {$kit_piece}; kit[$kit_piece] {${kit[$kit_piece]}}; z {$z}; zone {$zone}; grab {$grab}"
		[[ "x$zone" == "x" || ! -v zonecc[$kit_piece] ]] || z="$z ${zone//\{GP\}/${zonecc[$kit_piece]}}"
		[[ "x$grab" == "x" || ! -v grabcc[$kit_piece] ]] || z="$z ${grab//\{GP\}/${grabcc[$kit_piece]}}"
		echo "#define $trigger $z"
		cymbals[$cy]=1
	done

}

function mk_kit_hihats () {
	local kit=$1; shift || {
		echo "Missing kit array name" >&2
		exit 1
	}
	local trigger=$1; shift || {
		echo "Missing trigger" >&2
	}
}

declare -A cymbals hihats
for kit in 1 2 3 4
do
	rm -f triggers/kit$kit.sfzh
	{
	echo '// TD-27KV2 Kit '$kit
	echo ''

	cymbals=()
	while read d trigger z; do mk_kit_cymbals kit$kit $trigger; done < triggers/cymbals.sfzh
	for cy in ${!cymbals[@]}; do echo '#include "triggers/stx/cymbals/'$cy'.sfzh'; done
	echo ''

	hihats=()
	while read d trigger z; do mk_kit_hihats kit$kit $trigger; done < triggers/hihats.sfzh
	for hh in ${!hihats[@]}; do echo '#include "triggers/stx/hihats/'$hh'.sfzh'; done
	} ;# >> triggers/kit$kit.sfzh
done

#include "cymbals/stx_ride19.sfzh"
#include "cymbals/china_19_stx.sfzh"
#include "cymbals/crash_15_stx.sfzh"
#include "cymbals/crash_18_stx.sfzh"
#include "cymbals/ride_19_stx.sfzh"
#include "cymbals/ride_20_stx.sfzh"
#include "cymbals/splash_12_stx.sfzh"
#include "cymbals/splash_8_stx.sfzh"
#include "cymbals/splash_9_stx.sfzh"
#
#include "hihats/hh13_stx.sfzh"
#include "kicks/kd20_punch_snare_on.sfzh"
#include "snares/sn14_rock_stx_snare_on.sfzh"
#include "toms/rock_stx_snare_on.sfzh"
#include "percussion/cowbell_8_stx.sfzh"

