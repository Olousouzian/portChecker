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


if [[ "$#" > 2 || "$#" < 1 ]]
then
  usage
fi

cat $1 | ( while read a b c d; 

do 
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
done

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
)
