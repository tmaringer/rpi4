#!/bin/sh









#echo "TOPRMTMPDBG"; rm /tmp/.update* 2>/dev/null; sleep 1
#echo "TOPRMTMPDBG"; rm /tmp/.updateresult* 2>/dev/null; sleep 1




#echo "TOPSETx"; set -x; sleep 1

#[root@dca632 /usbstick 43°]# rm /tmp/ibbuildinformation.txt; rm /tmp/.updateurl*; rm /tmp/.updateresult*











#rm /tmp/.update*; /bin/rpi-sysup-online.sh -v dlonly downgrade











#wip >>> -q||-C @ autoscripted@luci||sysinfo.sh >>> -q = exitstatusonly -C=printlatestversion&&||-Lprintashtmlwlink?
#-R = restorepackages
#-v = verbose ( 1(normal) -> 2 )
#wip -Q = quick@verbose=z||0 ( 1(normal) -> 2 )
#-D = debug








#[root@dca632 /tmp 47°]# rpi-sysup-online.sh -v dlonly
#sh: -v: out of range
#sh: -v: out of range
#sh: -v: out of range
#no-flavour-given@ini> FLAVOUR=stable
#Downloading ibbuildinformation.txt...
#/tmp/ibbuildinformation.txt      100%[=========================================================>]  10.37K  --.-KB/s    in 0.001s
#   flavour:stable online:2.7.15-2[older] onsys:2.7.33-2
#use> 'downgrade'







#f7fcb1c6b94a67e3f6907a6f796356f63365e53fd0e9760ce832d71f1b4c013a  /tmp/rpi4.64-snapshot-25261-2.7.15-2-r15599-ext4-sys.img.gz

#f7fcb1c6b94a67e3f6907a6f796356f63365e53fd0e9760ce832d71f1b4c013a  *rpi4.64-snapshot-25261-2.7.15-2-r15599-ext4-sys.img.gz














ALLPARAMS=${*}
VERBOSE=1
RCSLEEP=0
#DEBUG=1


fails() {
    echo "$1" && exit 1
}



usage() {
cat <<EOG

    $0 [-R] [stable|current|testing|20.1] [downgrade/force|check] [-v] [dlonly]

	check   =   report 'upgradable' ( 'flavour' is newer )

        stable  =   long term image with minimal testing code
        current =   medium term image with some code + latest packages ( medium chance of bugs some new features )
        testing =   short term image with latest testing code / features / packages ( no opkg repos - removed anytime )


	NOTE: 'variants' @ extra||std are not yet supported -> all functionality is based on extra...
	      std is build / uploaded at the same time as extra so you can still use these checks
	      to know when builds are available


        (-D dbg)
        (-Q quick)
        (-q quiet exit status only @ check only) (possible if ! 'docmd' then)

EOG
}







################################################################### non-echo@-qetc... START
ecmd="echo "; i=$(basename $0); if [ -x /etc/custom/custfunc.sh  ]; then . /etc/custom/custfunc.sh; ecmd="echm ${i} "; fi
if [ -f /root/wrt.ini  ]; then . /root/wrt.ini; fi
if [ -z "$ffD"  ]; then ffD="/root"; fi
########################################3
#UPGRADEsFLAVOUR="current"
########################################3
#iM="$i" #iM="$(basename $0)"
iL="/$i.log"
LOGCHECKS=1 #???fromoldfunction-testdirname?
























echL() { SL=$(date +%Y%m%d%H%M%S)



### all cases except * had log anyway move above
[ -n "$LOGCHECKS" ] && echo "$i-$SL> ${1}" >> $iL



case "${2}" in
	log) :; ;; #MOVEDABOVE [ -n "$LOGCHECKS" ] && echo "$i-$SL> ${1}" >> $iL; return 0

	msg) #[ -n "$LOGCHECKS" ] && echo "$i-$SL> ${1}" >> $iL
		$ecmd "$1"
	;;

	console) #[ -n "$LOGCHECKS" ] && echo "$i-$SL> ${1}" >> $iL
		echo "$1" > /dev/console
	;;

	logger) #[ -n "$LOGCHECKS" ] && echo "$i-$SL> ${1}" >> $iL
		logger -p info -t $i "${*}"
	;;

	*) $ecmd "$1"; ;;


esac
}


#*) $ecmd "$1"; ;;
################################################################### non-echo@-qetc... END











WGETBIN=$(readlink -f $(type -p wget))
CURLBIN=$(readlink -f $(type -p curl))

WGETv="wget --no-parent -q -nd -l1 -nv --show-progress "
WGETs="wget --no-parent -q -nd -l1 -nv "




#case "$(cat /tmp/sysinfo/board_name)" in '4-model-b')
MODELf=$(cat /tmp/sysinfo/board_name)
Gbase="https://raw.github.com/wulfy23/rpi4/master"
SUMSname="sha256sums"


#WIP->multimodelsupport
#case "$(cat /tmp/sysinfo/board_name)" in
#esac




while [ "$#" -gt 0 ]; do
    case "${1}" in
    "-h"|"--help"|help) usage; shift 1; exit 0; ;;
    "-D") DEBUG=1; shift 1; ;;
    "-v") VERBOSE=2; shift 1; ;;
    "-Q") VERBOSE=0; shift 1; ;;

    stable) FLAVOUR="stable"; shift 1; ;;
    current) FLAVOUR="current"; shift 1; ;;
    testing) FLAVOUR="testing"; shift 1; ;;
    

	release) FLAVOUR="release"; shift 1; ;;
    
	#NOTUSINGBELOW-FORNOW-WAS-SAMPLE
	"20.1"*) FLAVOUR="${1}"; shift 1; ;; #20.1) FLAVOUR="20.1"

    check) DOCHECK="check"; shift 1; ;;
    downgrade) DOWNGRADE="downgrade"; shift 1; ;;
    force) FORCE="force"; shift 1; ;;
    "-R") RESTOREPACKAGES="-R"; shift 1; ;;


    dlonly) DLONLY=1; shift 1; ;;

    *)
        echo "$0 [stable|current|check] ?:$1"; exit 0 #NOPE echo "$0 [stable|current|check] ?:$1"; usage: exit 0
    ;;
    esac #if [ -f
done






if [ ! -z "$DEBUG" ]; then RCSLEEP=2; fi #@@@ similar||alsomod@VERBOSE
if [ ! -z "$DEBUG" ]; then VERBOSE=2; fi #@@@ && [ "$VERSBOSE" -lt 2]; then


#echo "debugnoflavourgiven"
#set -x






















################################################################################3 POPULATE VARS from INI if NOTGIVEN
#FLAVOUR="${FLAVOUR:-UPGRADEsFLAVOUR}"

############################################################## FLAVOUR
if [ -z "${FLAVOUR}" ] && [ ! -z "${UPGRADEsFLAVOUR}" ]; then

    #@@@if [ ! -z "$DEBUG" ] #|| VERSBOS
    if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then
        echo "no-flavour-given@ini> FLAVOUR=${UPGRADEsFLAVOUR}"; sleep 1
    fi
    FLAVOUR="${UPGRADEsFLAVOUR}"

elif [ -z "${FLAVOUR}" ] && [ -z "${UPGRADEsFLAVOUR}" ]; then
    echo "err> you must specify build flavour: [stable|current|testing|20.1]"
    echo "or UPGRADEsFLAVOUR=[stable|current|testing|20.1] in wrt.ini"
    #UPGRADEsFLAVOUR="current"
    exit 0

else
    if [ ! -z "$DEBUG" ]; then
        echo "flavour@cmdline> FLAVOUR=${FLAVOUR}"; sleep ${RCSLEEP:0}
    fi
fi



















#if [ ! -f /bin/mitigate.sh ]; then
#    $WGETs -O /bin/mitigate.sh "https://raw.githubusercontent.com/wulfy23/rpi4/master/utilities/mitigate.sh" || OOPSIE=1
#    if [ ! -z "$OOPSIE" ]; then
#	    rm /bin/mitigate.sh 2>/dev/null
#	    fails "dlprob"
#    else
#        chmod +x /bin/mitigate.sh
#    fi
#
#fi
###curl -sSL https://raw.githubusercontent.com/wulfy23/rpi4/master/utilities/mitigate.sh > /bin/mitigate.sh; chmod +x /bin/mitigate.sh
####if [ -f /bin/mitigate.sh ] && inival... mitigate.sh -S -N


#set +x



























    #################################### flavour paths set > phase2 moved lower due to ini < ifzFLAVOUR
    case "${FLAVOUR}" in
    
		
	#20210330-experimental latest release -> 21.02-SNAPSHOT	
	release)

		#Fsub="builds/devel/rpi-4_21.02-SNAPSHOT_1.0.17-3_r15932_std"
		#Bname="rpi4.64-21.02-SNAPSHOT-25770-1.0.17-3-r15932-r15932-e8cbdbbe97-bcm27xx-bcm2711-ext4-sys.img.gz"
		
		#Fsub="builds/devel/rpi-4_21.02-SNAPSHOT_1.0.17-3_r15932_std"
		#Bname="rpi4.64-21.02-SNAPSHOT-25770-1.0.17-3-r15932-r15932-e8cbdbbe97-bcm27xx-bcm2711-ext4-sys.img.gz"





#Fsub="builds/devel/rpi-4_21.02.0-rc4_1.0.5-2_r16256_extra"
#Bname="rpi4.64-21.02.0-rc4-26666-1.0.5-2-r16256-bcm27xx-bcm2711-ext4-sys.img.gz"


		echo "no release build available"; exit 0

	;;
    




	stable)
		
		#Fsub="
		#Bname="


#REVERTBUILD
#Fsub="builds/rpi-4_snapshot_3.2.61-30_r17073_extra"
#Bname="rpi4.64-snapshot-26379-3.2.61-30-r17073-ext4-sys.img.gz"

#rtl1111-pci-boarddesc-interrupt
#Fsub="builds/rpi-4_snapshot_3.2.61-36_r17073_extra"
#Bname="rpi4.64-snapshot-26516-3.2.61-36-r17073-ext4-sys.img.gz"

#Fsub="builds/rpi-4_snapshot_3.2.61-39_r17073_extra"
#Bname="rpi4.64-snapshot-26520-3.2.61-39-r17073-ext4-sys.img.gz"

#Fsub="builds/rpi-4_snapshot_3.2.61-53_r17073_extra"
#Bname="rpi4.64-snapshot-26535-3.2.61-53-r17073-ext4-sys.img.gz"



#Fsub="builds/rpi-4_snapshot_3.2.61-55_r17073_extra"
#Bname="rpi4.64-snapshot-26535-3.2.61-55-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-63_r17073_extra"
#Bname="rpi4.64-snapshot-26560-3.2.61-63-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-67_r17073_extra"
#Bname="rpi4.64-snapshot-26565-3.2.61-67-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-69_r17073_extra"
#Bname="rpi4.64-snapshot-26566-3.2.61-69-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-70_r17073_extra"
#Bname="rpi4.64-snapshot-26567-3.2.61-70-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-72_r17073_extra"
#Bname="rpi4.64-snapshot-26570-3.2.61-72-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.100-11_r17143_extra"
#Bname="rpi4.64-snapshot-26591-3.2.100-11-r17143-ext4-sys.img.gz"

#Fsub="builds/rpi-4_snapshot_3.2.100-63_r17143_extra"
#Bname="rpi4.64-snapshot-26607-3.2.100-63-r17143-ext4-sys.img.gz"


#Fsub="builds/rpi-4_snapshot_3.2.100-95_r17143_extra"
#Bname="rpi4.64-snapshot-26639-3.2.100-95-r17143-ext4-sys.img.gz"



#Fsub="builds/rpi-4_snapshot_3.2.107-5_r17232_extra"
#Bname="rpi4.64-snapshot-26663-3.2.107-5-r17232-ext4-sys.img.gz"

#Fsub="builds/rpi-4_snapshot_3.2.107-9_r17232_extra"
#Bname="rpi4.64-snapshot-26666-3.2.107-9-r17232-ext4-sys.img.gz"




		echo "no stable build available"; exit 0

	;;





	current)
		#Fsub="
		#Bname="


#Fsub="builds/rpi-4_snapshot_3.2.61-30_r17073_extra"
#Bname="rpi4.64-snapshot-26379-3.2.61-30-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-36_r17073_extra"
#Bname="rpi4.64-snapshot-26516-3.2.61-36-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-39_r17073_extra"
#Bname="rpi4.64-snapshot-26520-3.2.61-39-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-53_r17073_extra"
#Bname="rpi4.64-snapshot-26535-3.2.61-53-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-55_r17073_extra"
#Bname="rpi4.64-snapshot-26535-3.2.61-55-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-63_r17073_extra"
#Bname="rpi4.64-snapshot-26560-3.2.61-63-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-67_r17073_extra"
#Bname="rpi4.64-snapshot-26565-3.2.61-67-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-69_r17073_extra"
#Bname="rpi4.64-snapshot-26566-3.2.61-69-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-70_r17073_extra"
#Bname="rpi4.64-snapshot-26567-3.2.61-70-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.61-72_r17073_extra"
#Bname="rpi4.64-snapshot-26570-3.2.61-72-r17073-ext4-sys.img.gz"
#Fsub="builds/rpi-4_snapshot_3.2.100-2_r17143_extra"
#Bname="rpi4.64-snapshot-26570-3.2.100-2-r17143-ext4-sys.img.gz"

#Fsub="builds/rpi-4_snapshot_3.2.100-11_r17143_extra"
#Bname="rpi4.64-snapshot-26591-3.2.100-11-r17143-ext4-sys.img.gz"


#Fsub="builds/rpi-4_snapshot_3.2.100-63_r17143_extra"
#Bname="rpi4.64-snapshot-26607-3.2.100-63-r17143-ext4-sys.img.gz"


#Fsub="builds/rpi-4_snapshot_3.2.100-95_r17143_extra"
#Bname="rpi4.64-snapshot-26639-3.2.100-95-r17143-ext4-sys.img.gz"

#Fsub="builds/rpi-4_snapshot_3.2.107-5_r17232_extra"
#Bname="rpi4.64-snapshot-26663-3.2.107-5-r17232-ext4-sys.img.gz"




#Fsub="builds/rpi-4_snapshot_3.2.107-9_r17232_extra"
#Bname="rpi4.64-snapshot-26666-3.2.107-9-r17232-ext4-sys.img.gz"




		echo "no current build available"; exit 0

	;;






    testing)



		echo "no testing build available"; exit 0
    ;;







    "21.02"*) #echo ""; echo "version: 20.1 has not been released yet"; usage; exit 0
        echo "version: ${FLAVOUR} no build available"; exit 0 #usage; exit 0
    ;;

    *) echo "unknown flavour ${FLAVOUR} no build available"; usage; exit 0; ;;
    esac








#############################################################################MODEL/ENVspecificSANITYCHECKS
######if ! grep -q '4-model-b' /tmp/sysinfo/board_name; then echo "only: raspberrypi,4-model-b [issupported]" && exit 0; fi
if [ "$(blkid | grep '^/dev/mmcblk0p2' | grep ext4 | wc -l)" -ne 1 ]; then echo "ext4 sysupgrade only" && exit 0; fi





if [ -z "$DOCHECK" ]; then if [ -z "$Bname" ]; then echo "no> $0 stable|current|check@@@" && exit 0; fi; fi
if [ -z "$Bname" ]; then echo "no> $0 stable|current|check@@@" && exit 0; fi ###paranoid/checksforgitextrapathsetvars


oSYSURL="$Gbase/$Fsub/$Bname"
SYSout="/tmp/${Bname}" #SYSout="/tmp/rpisysup.sh"

#echo "$oSYSURL"









#@@@prereqwget||curlcheckmods
if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -eq 2 ]; then
    WGET="$WGETv"
elif [ -z "$DOCHECK" ]; then
    WGET="$WGETs"
else
    WGET="$WGETs"
    #WGET="$WGETv"
fi



rm ${SYSout} 2>/dev/null; rm /tmp/sha256sums 2>/dev/null; rm /tmp/ibbuildinformation.txt 2>/dev/null; #sync





if [ ! -z "$DEBUG" ]; then
    echo "# $0 ${ALLPARAMS}"
    echo "    git-repo: $Gbase"
    echo "######################################################"
    echo "      modelf: $MODELf"
    echo "     flavour: $FLAVOUR"
    echo "######################################################"
    sleep ${RCSLEEP:-0}; sleep ${RCSLEEP:-0}; sleep ${RCSLEEP:-0}
fi















if [ ! -z "$DEBUG" ]; then echo "${Gbase}/${Fsub}/ibbuildinformation.txt"; sleep ${RCSLEEP:-0}; fi
if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then echo "Downloading ibbuildinformation.txt..."; sleep 1; fi
$WGET -O /tmp/ibbuildinformation.txt "${Gbase}/${Fsub}/ibbuildinformation.txt" || fails "buildinfo-dlprob"








#forupdatecheck.sh to show hyperlink
#WRONG HAS RAW echo "${Gbase}/${Fsub}" > /tmp/.updateurl
echo "${oSYSURL}" > /tmp/.updateurl #OLD-addflavourforfaster-safer-use
echo "${oSYSURL}" > /tmp/.updateurl.$FLAVOUR













onsysVERSION=$(cat /etc/custom/buildinfo.txt | grep '^localversion' | cut -d'=' -f2 | sed 's/"//g' | sed "s/'//g")
onsysVERSIONn=$(echo $onsysVERSION | sed 's/\.//g' | sed "s/\-//g")
onsysVERSION_M=$(echo $onsysVERSION | cut -d'.' -f1)
onsysVERSION_m=$(echo $onsysVERSION | cut -d'.' -f2)
onsysVERSION_s=$(echo $onsysVERSION | cut -d'.' -f3 | sed 's/\-.*$//g') #onsysVERSION_s=$(echo $onsysVERSION | cut -d'.' -f3)
if echo $onsysVERSION | grep -q '\-'; then onsysVERSION_r=$(echo $onsysVERSION | cut -d'-' -f2); else onsysVERSION_r=0; fi
onsysVERSION_c="${onsysVERSION_M}${onsysVERSION_m}${onsysVERSION_s}${onsysVERSION_r}"
onlineVERSION=$(cat /tmp/ibbuildinformation.txt | grep '^localversion' | cut -d'=' -f2 | sed 's/"//g' | sed "s/'//g")

#onlineVERSION="1.15.17-53" #dummyolder
#onlineVERSION="2.15.17-53" #dummyolder
#onlineVERSION="0.15.17-53" #dummyolder

onlineVERSIONn=$(echo $onlineVERSION | sed 's/\.//g' | sed "s/\-//g")
onlineVERSION_M=$(echo $onlineVERSION | cut -d'.' -f1)
onlineVERSION_m=$(echo $onlineVERSION | cut -d'.' -f2)
onlineVERSION_s=$(echo $onlineVERSION | cut -d'.' -f3 | sed 's/\-.*$//g') #onlineVERSION_s=$(echo $onlineVERSION | cut -d'.' -f3)
if echo $onlineVERSION | grep -q '\-'; then onlineVERSION_r=$(echo $onlineVERSION | cut -d'-' -f2); else onlineVERSION_r=0; fi
onlineVERSION_c="${onlineVERSION_M}${onlineVERSION_m}${onlineVERSION_s}${onlineVERSION_r}"



##############################################################################################################3
#echo "    onsysVERSION: $onsysVERSION"
#####echo "   onsysVERSIONn: $onsysVERSIONn"
#####echo "$onsysVERSION_M $onsysVERSION_m $onsysVERSION_s $onsysVERSION_r"
#echo "   onlineVERSION: $onlineVERSION"
#####echo "  onlineVERSIONn: $onlineVERSIONn"
#####echo "$onlineVERSION_M $onlineVERSION_m $onlineVERSION_s $onlineVERSION_r "
#####echo "$onsysVERSIONn -lt $onlineVERSIONn"; sleep 2
#####if [ "$onsysVERSIONn" -lt "$onlineVERSIONn" ]; then echo "newer"; else echo "notnewer"; fi #&& exit 0
#####echo "${onsysVERSION_c} -lt ${onlineVERSION_c}"; sleep 3
#####if [ "$onsysVERSION_c" -lt "$onlineVERSION_c" ]; then echo "newer"; else echo "notnewer"; fi #&& exit 0
##############################################################################################################3

########rewrite while-zNEWER:
#exit 0
#set -x










#echo "SOUPx"
#set -x






























if [ "${onsysVERSION_M}" -lt "${onlineVERSION_M}" ]; then
    M_newer=1
    NEWER=1
fi
if [ -z "$M_newer" ] && [ "${onsysVERSION_M}" -eq "${onlineVERSION_M}" ]; then
    if [ "${onsysVERSION_m}" -lt "${onlineVERSION_m}" ]; then m_newer=1; fi
    if [ "${onsysVERSION_m}" -lt "${onlineVERSION_m}" ]; then m_newer=$((${onlineVERSION_m} - ${onsysVERSION_m})); fi
fi


















if [ -z "$m_newer" ]; then
    if [ "${onsysVERSION_M}" -eq "${onlineVERSION_M}" ] && [ "${onsysVERSION_m}" -eq "${onlineVERSION_m}" ]; then
        #if [ "${onsysVERSION_s}" -lt "${onlineVERSION_s}" ]; then s_newer=1; fi
        if [ "${onsysVERSION_s}" -lt "${onlineVERSION_s}" ]; then s_newer=$((${onlineVERSION_s} - ${onsysVERSION_s})); fi
    fi
fi



















if [ -z "$s_newer" ]; then
    if [ "${onsysVERSION_M}" -eq "${onlineVERSION_M}" ] && [ "${onsysVERSION_m}" -eq "${onlineVERSION_m}" ] && \
        [ "${onsysVERSION_s}" -eq "${onlineVERSION_s}" ]; then
            #if [ "${onsysVERSION_r}" -lt "${onlineVERSION_r}" ]; then r_newer=1; fi
            if [ "${onsysVERSION_r}" -lt "${onlineVERSION_r}" ]; then r_newer=$((${onlineVERSION_r} - ${onsysVERSION_r})); fi
        fi
fi








#if [ -z "$r_newer" ]; then OLDER=1; fi
if [ -z "$r_newer" ] && [ -z "$M_newer" ] && [ -z "$m_newer" ] && [ -z "$s_newer" ]; then
    #if [ -z "$M_newer" ] && [ -z "$m_newer" ] && [ -z "$s_newer" ]; then
        OLDER=1
    #fi
#else
fi

























###################################
#if [ ! -z "$DEBUG" ]; then echo "OLDER: $OLDER M_newer: $M_newer m_newer: $m_newer s_newer: $s_newer r_newer: $r_newer"; fi
###sleep 3; #exit 0
###################################















































if [ "$onlineVERSION" = "$onsysVERSION" ]; then
    echo "   online:$onlineVERSION = onsys:$onsysVERSION"; #sleep 1
    if [ ! -z "$FORCE" ] || [ ! -z "$DOWNGRADE" ]; then  #if [ -z "$FORCE" ]; then #-z DOWNGRADE
		echo "force:$FORCE/downgrade:$DOWNGRADE given flash(continue) anyway (unless check given)"
        DOWNGRADE=1
    else

		if ([ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]) || [ ! -z "$DEBUG" ]; then
			echo "force:$FORCE/downgrade:$DOWNGRADE notgiven-sameversion -> exit"
        fi

		exit 0 #if [ -z "$FORCE" ]; then #|| [ -z "$DOWNGRADE" ]; then  #if [ -z "$FORCE" ]; then #-z DOWNGRADE
    fi



























#############ORIGINAL pre ignore MINOR
################fi ################################### TESTEXACTLYTHESAME #@TESTING elif if [ ! -z "$OLDER" ]; then
#elif [ ! -z "$OLDER" ]; then
#    ###################checkfor'downgrade' || DOCHECK return etc...
#    ###############echo "   onlineVERSION: [${FLAVOUR}-older:$onlineVERSION] $onsysVERSION ${DOWNGRADE}"; #sleep 2
#	#echo "FISH1.1"
#    echo "   flavour:${FLAVOUR} online:$onlineVERSION[older] onsys:$onsysVERSION ${DOWNGRADE}"; #sleep 2
#else
#    ############echo "   onlineVERSION: ${FLAVOUR}-${onlineVERSION} [newer:$onsysVERSION]"; #sleep 2
#	#echo "FISH1.2"
#    echo "   flavour:${FLAVOUR} online:${onlineVERSION}[newer] onsys:$onsysVERSION"; #sleep 2
#fi















################fi ################################### TESTEXACTLYTHESAME #@TESTING elif if [ ! -z "$OLDER" ]; then
elif [ ! -z "$OLDER" ]; then
    ###################checkfor'downgrade' || DOCHECK return etc...
    ###############echo "   onlineVERSION: [${FLAVOUR}-older:$onlineVERSION] $onsysVERSION ${DOWNGRADE}"; #sleep 2
	#echo "FISH1.1"
    echo "   flavour:${FLAVOUR} online:$onlineVERSION[older] onsys:$onsysVERSION ${DOWNGRADE}"; #sleep 2
else
    ############echo "   onlineVERSION: ${FLAVOUR}-${onlineVERSION} [newer:$onsysVERSION]"; #sleep 2
	#echo "FISH1.2"


    


if [ "${onsysVERSION_M}" -eq "${onlineVERSION_M}" ] && [ "${onsysVERSION_m}" -eq "${onlineVERSION_m}" ] && \
        [ "${onsysVERSION_s}" -eq "${onlineVERSION_s}" ]; then
            if [ "${onsysVERSION_r}" -lt "${onlineVERSION_r}" ]; then
		    #r_newer=$((${onlineVERSION_r} - ${onsysVERSION_r})); 


	#!@updatecheck.sh
	#!echo "   flavour:${FLAVOUR} online:${onlineVERSION}[newer] onsys:$onsysVERSION minor"; #sleep 2
	#CHECKS FOR newer | = | or older

	

	#echo "   flavour:${FLAVOUR} online:${onlineVERSION}[minor] onsys:$onsysVERSION"; #sleep 2
	echo "   ${FLAVOUR}[minor-update] online:${onlineVERSION}($onsysVERSION)"; #sleep 2





####################### TESTINGTHISFORNOW@updatecheck.sh 2021DEBUG
echo "${r_newer:-0}" > /tmp/.updatecheck.numrevisionsM









	#else
	#echo "   flavour:${FLAVOUR} online:${onlineVERSION}[newer] onsys:$onsysVERSION major"; #sleep 2
	


else
	echo "   flavour:${FLAVOUR} online:${onlineVERSION}[newer] onsys:$onsysVERSION notminorFIXMENOIDEAWHATENTERSHERE"; #sleep 2








	fi




#################### DOESNOTENTERTHIS CORRECTION... NEWER[major]HITSHERE
else

	#echo "   flavour:${FLAVOUR} online:${onlineVERSION}[newer] onsys:$onsysVERSION major"; #sleep 2
	echo "   ${FLAVOUR} [newer-major] ${onlineVERSION}($onsysVERSION)"; #sleep 2





fi












fi

















































#sleep 1








    if [ ! -z "$DOCHECK" ]; then exit 0; fi #echo "checkonly... " && exit 0; fi



    if [ ! -z "$OLDER" ] && [ -z "$DOWNGRADE" ]; then
            echo "use> 'downgrade'"; sleep 1; exit 0 #echo "use> $0 'downgrade'"; sleep 1; exit 0
    elif [ ! -z "$OLDER" ] && [ ! -z "$DOWNGRADE" ]; then
            : #echo "downgrading..."; sleep 1 ######echo "downgrading...: ${DOWNGRADE}"; sleep 1
    fi



    #if [ -z "$DOWNGRADE" ]; then echo "DOWNempty"; fi
    #if [ ! -z "$OLDER" ] && [ -z "$DOWNGRADE" ]; then


    #echo "MUNG"; exit 0

#if ! -z m_newer && m_newer -gt 30 && RESTOREPACKAGES...
    #echo "use force"
    #TAINTSverSPAN=1
#fi


#echo "RUMMY"; exit 1













if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -eq 1 ]; then
    echo "Downloading... $FLAVOUR"; sleep 1 #echo "Download: wulfy23/rpi4 $FLAVOUT"; sleep 1 #FLAVOUT?
elif [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then
    echo "Download: wulfy23/rpi4 $FLAVOUR $Bname ($oSYSURL)"; sleep 1
fi
$WGET -O ${SYSout} "${oSYSURL}" || fails "dl-img-prob"




#if [ ! -z "$VERBOSE" ]; then echo "/tmp/sha256sums"; sleep 1; fi
#if [ ! -z "$VERBOSE" ]; then
if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then
    echo "Download: sha256sums"; sleep 1
fi
$WGET -O /tmp/sha256sums "${Gbase}/${Fsub}/sha256sums" || fails "dl-shasum-prob"





if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then echo "sha256sum check"; sleep 1; fi
CDIR="${PWD}"; cd /tmp; sha256sum -c sha256sums 2>/dev/null|grep OK || fails "shasum-chk-issue"; cd $CDIR
#echo "cd /tmp; sha256sum -c sha256sums 2>/dev/null|grep OK; cd $CDIR" #sha256sum -c /tmp/sha256sums 2>/dev/null|grep OK









if [ ! -z "$RESTOREPACKAGES" ]; then #prep-dootherstuffhere
    :
else
    :
fi









#@@@new@20201212
if [ ! -z "$DLONLY" ]; then
	echo "DLONLY img @ ${SYSout}"
	exit 0
fi





#if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -eq 1 ]; then echo "run> sysupgrade $RESTOREPACKAGES ${SYSout}"; sleep 2; fi

if [ ! -z "$VERBOSE" ] && [ "$VERBOSE" -gt 1 ]; then
    echo "sysupgrade -v $RESTOREPACKAGES ${SYSout}"; sleep 2
    sysupgrade -v $RESTOREPACKAGES ${SYSout}
else
    #echo "runthiscommand> sysupgrade $RESTOREPACKAGES ${SYSout}"
    sysupgrade $RESTOREPACKAGES ${SYSout}
fi






exit 0














COMPARISONclunky1() {
if [ "$onlineVERSION" = "$onsysVERSION" ]; then
    echo "   online:$onlineVERSION = onsys:$onsysVERSION"; sleep 1
    if [ ! -z "$FORCE" ] || [ ! -z "$DOWNGRADE" ]; then  #if [ -z "$FORCE" ]; then #-z DOWNGRADE
		echo "force:$FORCE/downgrade:$DOWNGRADE given flash(continue) anyway (unless check given)"
        DOWNGRADE=1
    else
        exit 0 #if [ -z "$FORCE" ]; then #|| [ -z "$DOWNGRADE" ]; then  #if [ -z "$FORCE" ]; then #-z DOWNGRADE
    fi

####fi ################################### TESTEXACTLYTHESAME #@TESTING elif if [ ! -z "$OLDER" ]; then
elif [ ! -z "$OLDER" ]; then
    #checkfor'downgrade' || DOCHECK return etc...
    echo "   onlineVERSION: [${FLAVOUR}-older:$onlineVERSION] $onsysVERSION ${DOWNGRADE}"; #sleep 2
else
    echo "   onlineVERSION: ${FLAVOUR}-${onlineVERSION} [newer:$onsysVERSION]"; #sleep 2
fi
sleep 2
}









exit 0

gtarurl="https://github.com/wulfy23/rpi4/raw/master/utilities/putty/putty.tar.gz"
gtarfname=$(basename $gtarurl)
WGET="wget --no-parent -q -nd -l1 -nv --show-progress "
POSTRUN="/boot/rpi-multiboot-setup.sh"

fail() {
    echo "$@" && exit 1
}


if [ -f /$gtarfname ]; then
    #echo "Removing previous /$gtarfname"; sleep 1
    rm /"${gtarfname:-0}"
fi

#echo "Downloading: $gtarfname"; sleep 1
(cd / && $WGET $gtarurl) || fail "Download issues: /$gtarurl" #) && (cd / && tar -xvzf /$gtarfname)

if file /$gtarfname | grep -q "gzip compressed data"; then echo "gzipok"; else echo "gzipnope" && fail "oops"; fi
(cd / && tar -xvzf $gtarfname 2>/dev/null) || fail "Extract issues: /$gtarfname"
if [ -f "$POSTRUN" ]; then
    echo "Running setupscr: $POSTRUN"
    sh $POSTRUN
else
    echo "setupscr: $POSTRUN [missing]" && fail "oops"
fi


exit 0




#####################################################################################################################
#echo "Download: wulfy23/rpi4-multiboot/master/multiboot/setup/rpi-multiboot.sh > /bin"
#$WGET -O /bin/rpi-multiboot.sh https://raw.github.com/wulfy23/rpi4-multiboot/master/multiboot/setup/rpi-multiboot.sh || fails "dlprob"
#####echo "ok > /bin/rpi-multiboot.sh init"
#chmod +x /bin/rpi-multiboot.sh
#####################################################################################################################
#echo "Downloading: $gtarfname"; sleep 1; (cd / && $WGET $gtarurl) && (cd / && tar -xvzf /$gtarfname)
#gtarurl="https://raw.githubusercontent.com/wulfy23/rpi4/master/builds/special.bin"
#https://github.com/wulfy23/rpi4/raw/master/utilities/putty/putty.tar.gz
#BEST gittarurl="https://raw.githubusercontent.com/wulfy23/rpi4/master/builds/special.bin"
#https://raw.githubusercontent.com/wulfy23/rpi4/master/builds/README
#NEEDS -O gittarurl="https://github.com/wulfy23/rpi4/blob/master/builds/special.bin?raw=true"
#NOPEgittarurl="https://github.com/wulfy23/rpi4/blob/master/builds/special.bin"
#####################################################################################################################
#WGET="wget --no-parent -nd -N -l1 -nv --show-progress "
#WGET="wget --no-parent -nd -N -l1 -r -nv --show-progress "
#WGET="wget --no-parent -nd -l1 -nv --show-progress "
#####################################################################################################################
#sed -i -e "/special/d" $FOLDr/sha256sums








#Fsub="builds/rpi-4_snapshot_3.1.57-50_r16707_extra"
#Bname="rpi4.64-snapshot-26360-3.1.57-50-r16707-ext4-sys.img.gz"

#Fsub="builds/devel/rpi-4_21.02.0-rc4_1.0.5-2_r16256_extra"
#Bname="rpi4.64-21.02.0-rc4-26666-1.0.5-2-r16256-bcm27xx-bcm2711-ext4-sys.img.gz"

