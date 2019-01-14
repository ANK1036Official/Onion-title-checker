#!/bin/bash
RESTORE='\033[0m'
LRED='\033[01;31m'
LGREEN='\033[01;32m'
LYELLOW='\033[01;33m'
if pgrep -x "tor" > /dev/null
then
    echo "Tor running..."
    sleep 1
    reset
else
    echo "Tor not running..."
    echo 'Start Tor before running this script.'
    exit 1
fi
if [ "$#" -ne 1 ]
then
    echo 'Title grabber v1'
    echo 'ANK Exposure 2019'
    echo ''
    echo 'Gets titles of onion links.'
    echo "Usage: $0 list_file"
    exit 1
fi
echo 'Title grabber v1'
echo 'ANK Exposure 2019'
echo ''
echo 'All links will be stored in links.txt'
echo 'Any links with no title will be stored in unknown.txt'
echo ''
for link in `cat $1`; do
    addr=`echo "$link" | sed 's~http[s]*://~~g'`
    output=`curl --connect-timeout 20 -s --socks5-hostname localhost:9050 $link | grep -iPo '(?<=<title>)(.*)(?=</title>)'`
    printf "$LGREEN"
    printf "$addr"
    printf "$RESTORE"
    printf " -- "
    if [[ -z "$output" ]] ; then
        printf "$LRED"
        printf "No Title"
        printf "$RESTORE"
        printf "\n"
        echo "$link" >> unknown.txt
    else
        printf "$LYELLOW"
        printf "$output"
        printf "$RESTORE"
        printf "\n"
        echo "$link" >> links.txt
    fi
done
echo ''
echo 'Would you like to check hosts that did not contain a title? Y/N'
read -p ">> " CHOICE
if [[ $CHOICE =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    for j in `cat unknown.txt`; do
        addr_unk=`echo "$j" | sed 's~http[s]*://~~g'`
        output_unk=`curl --socks5-hostname localhost:9050 --connect-timeout 20 -Is $j | head -n 1`
        printf "$LGREEN"
        printf "$addr_unk -- "
        printf "$RESTORE"
        if [[ -z "$output_unk" ]] ; then
            printf "$LRED"
            printf "No response"
            printf "$RESTORE"
            printf "\n"
        else
            printf "$LYELLOW"
            printf "Responded"
            printf "$RESTORE"
            printf "\n"
        fi
    done
    echo "Would you like to clear unknown.txt? Y/N"
    read -p '>> ' CHOICE2
    if [[ $CHOICE =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        > unknown.txt
    else
        continue
    fi
fi
