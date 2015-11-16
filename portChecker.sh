#!/bin/bash

export IFS=","
recap=""
nbError=0
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

usage ()
{
  echo 'Usage : portChecker.sh [filename.csv] -v'
  exit
}

help ()
{
    echo 'Requirements : This script needs tcping and nc for working.'
    exit   
}

trap _summary SIGHUP SIGINT SIGTERM

_summary ()
{
    progress 50
    echo -e "\n--------------------"
    echo -e "${GREEN}PORT CHECKER${NC}"
    echo "--------------------"
    echo -e "Nb error : ${RED}$nbError${NC}"
    echo "--------------------"
    if [[ -z $recap ]]; then
        echo -ne "${RED}{EMPTY}${NC}\n"
    else
        echo -ne "${RED}$recap${NC}"
    fi
    echo "--------------------"
}

# PROGRESSBAR RATIO 0.5
function progress () {

    nb=$[$1 * 2];
    echo -en "\rProgression $nb% ["
    if [[ ! -z $1 ]]; then
        it=0
        while [ $it != $1 ]; do
            echo -en "${GREEN}#${NC}"
            it=$[$it+1]
        done
    fi 
    while [[ $it != 50 ]]; do
        echo -en "."
        it=$[$it+1]
    done
    echo -ne "]"
}

if [[ "$#" > 2 || "$#" < 1 ]]
then
  usage
fi


if [[ "$#" == 1 ]]; then
    lines=$(wc -l < $1)
    linectr=0
fi

cat $1 | ( while read a b c d; 

do 

    if [[ "$#" == 1 ]]; then
        perc=$(( linectr * 100 / lines ))
        perc=$[$perc/2]
        #echo $perc
        progress $perc
    fi
    # REGION TCP
    if [[ -z "$c" ]]; then
        if [[ $2 == "-v" ]]; then
            echo -en "TCP :\t$a PORT :\t$b"
        fi
        
        # TEST
        tcping -t 1 $a $b > /dev/null
        error=$?

        if [[ $error != 0 ]]; then
            nbError=$((nbError+1))
            recap="$recap TCP : $a PORT :\t$b\n"
        fi

        if [[ $2 == "-v" ]]; then
            if [[ $error == 0 ]]; then
        	   echo -e "\t\t${GREEN}[OK]${NC}"
            else
               echo -e "\t\t${RED}[KO]${NC}"
            fi
        fi
    fi
    # END REGION

    # REGION UPD
    if [[ ! -z "$d" ]]; then
        i=$c
        d=$[$d+1]
        while [ $i != $d ]
        do
            if [[ $2 == "-v" ]]; then
                echo -en "UDP :\t$a PORT :\t$i"
            fi

            # TEST
            nc -zu $a $i > /dev/null 2>&1
            error=$?

            if [[ $error == 0 ]]; then
                nbError=$((nbError+1))
                recap="$recap ERROR : UDP :\t$a PORT :\t$i\n"
            fi

            if [[ $error == "0" ]]; then
                if [[ $2 == "-v" ]]; then
                    echo -e "\t\t${GREEN}[OK]${NC}"
                fi
            else
                if [[ $2 == "-v" ]]; then
                    echo -e "\t\t${RED}[KO]${NC}"
                fi
            fi
            i=$[$i+1]
        done
    fi
    #END REGION
    linectr=$[$linectr+1]
done

# END PROGRESSBAR
_summary
)
