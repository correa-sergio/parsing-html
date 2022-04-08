#!/bin/bash

# Title: PAHS - PArsing Html Script            
# Developed by Sérgio Corrêa
# Date: 20/12/2019 (Updated 05/04/2022)
# Tested on: MacOS / Linux

### Constants to help to use colors:

RED='\033[31;1m'
GREEN='\033[32;1m'
BLUE='\033[34;1m'
YELLOW='\033[33;1m'
RED_BLINK='\033[31;5;1m'
CYAN="\033[1;36m"
PURPLE="\033[0;35m"
END='\033[m'

### Constant used to save the script version:

VERSION='1.1'

### Constant used to Script:

SCRIPT=$0

### Variable used to URL:

URL=$1

### Variable used to save date:

DATE=$(date +"%Y_%m_%d-%H_%M_%S")

### Directory to save temporary data 

DIR=/tmp

### Variable for wget 

WGET=$(which wget)

### Function to show how to use it

function helpPanel(){
  
  echo -e "${PURPLE}=============================================================================================${END}"

  echo -e "\t${GREEN} [*] Usage: $SCRIPT <URL>${END}"

  echo -e "\t${GREEN} [*] Usage Mode: $SCRIPT just-an-example.com.br${END}"

  echo -e "\t${GREEN} [*] Version: $VERSION${END}"

  echo -e "${PURPLE}=============================================================================================${END}"

  exit 1

}

### Function to start and create temporary directory:

function startFunc(){

  echo -e "${GREEN} [+] Start with address: $URL [√]${END}"

  mkdir -p /tmp/$URL-$DATE

  sleep 0.2

  echo -e "${GREEN} [+] Created folder: /tmp/$URL-$DATE [√]${END}"

}

### Function to Download and Check file:

function downloadCheck(){

  $WGET -P $DIR/$URL-$DATE/ $URL --no-check-certificate 2> /dev/null

  sleep 0.3

  CHECK=$(ls "$DIR/$URL-$DATE/index.html" 2>/dev/null)

    if [ -n "$CHECK" ]; then

      echo -e "${GREEN} [+] Successful download - index.html [√]${END}"

       else
     
       echo -e "${RED} [-] Problem - Check the URL ${END}"

       exit 1 

    fi

}


### Function to analyzing collected data

function dataAnalysis(){

  ANALISE_PART1=$(cat $DIR/$URL-$DATE/index.html | tr ' ' '\n' | sed 's/<[^>]*>//g' | sed '/^$/d' | sed 's/href\=\"//g' >> $DIR/$URL-$DATE/part1.txt)

  ANALISE_PART2=$(cat $DIR/$URL-$DATE/part1.txt  | sed -n '/^http/p'| sed 's/\/\///g' | awk -F ":" '{print $2}' >> $DIR/$URL-$DATE/part2.txt)

  ANALISE_PART3=$(cat $DIR/$URL-$DATE/part2.txt  | awk -F "/" '{print $1}'| awk -F "\"" '{print $1}' | tr -d "=" >> $DIR/$URL-$DATE/part3.txt)

  ANALISE_Part4=$(cat $DIR/$URL-$DATE/part3.txt | tr -d "+" | tr -d "?" | tr -d "\'" | cut -d "#" -f 1 | sort -u | uniq -u | sed '/^$/d' > $DIR/$URL-$DATE/part4.txt)

  echo $URL > $DIR/$URL-$DATE/site.txt

  ID=$(cat $DIR/$URL-$DATE/site.txt | cut -d "." -f 1)

    for report in $(cat $DIR/$URL-$DATE/part4.txt); do

      if [[ "$report" == *"$ID"* ]]; then

        echo "$report" >> $DIR/$URL-$DATE/part5.txt

      fi

    done

  echo -e "${GREEN} [+] File analysis performed [√]${END}"

}

### Function to segment ip and dns data 

function nameIp(){

  TEST=$(cat $DIR/$URL-$DATE/part5.txt)

    for NAMEIP in $TEST; do

      if [[ $NAMEIP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then

        echo $NAMEIP >> $DIR/$URL-$DATE/report.txt

        else

          host $NAMEIP | egrep "Host|has" >> $DIR/$URL-$DATE/report.txt

      fi

    done

  
### If you are not using Mac Os, comment the line below (for MacOs)

  #sed -i'.txt' 's/has IPv6\ address/-/g' $DIR/$URL-$DATE/report.txt
  
### If you are not using Linux, comment the line below (for Linux)

sed -i 's/has IPv6\ address/-/g' $DIR/$URL-$DATE/report.txt
  
  echo -e "${GREEN} [+] Segmentation of Name and Ip [√]${END}"

}

### Function to remove temporary files 

function cleanup(){

  rm $DIR/$URL-$DATE/part*.txt

  rm $DIR/$URL-$DATE/site.txt

  sleep 0.5

    echo -e "${GREEN} [+] Removing temporary files [√]${END}"

}

### Function to show the report on screen 

function report(){

echo ""

  echo -e "${GREEN} Report: ${END}"

  cat $DIR/$URL-$DATE/report.txt | column -t -s' ' | nl

echo ""

  TOTAL=$(cat $DIR/$URL-$DATE/report.txt | wc -l)

echo " "

  echo -e "${GREEN} [+] Your report can also be found at: $DIR/$URL-$DATE/report.txt ${END}"

  echo -e "${GREEN} [+] Total lines found: $TOTAL ${END}"


}

if [ -z "$URL" ] ; then

 helpPanel

else
 
 startFunc

 downloadCheck

 dataAnalysis

 nameIp

 cleanup

 report

fi
