#! /bin/bash

# ft8vata.sh - FT8 skimmer, version 2022.02.23-1 beta
# Copyright (C) 2022, Ihor Sokorchuk, UR3LCM <ur3lcm@gmail.com>
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
# This is free software; you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# FT8 FREQ:
# 1.840 3.573 5.357 7.074 10.136 14.074 18.100 
# 21.074 24.915 28.074 50.313 50.323

logLevel=1

function setFreq() {
  case $1 in
  1.840|3.573|5.357|7.074|10.136|14.074 \
  |18.100|21.074|24.915|28.074|50.313|50.323) freq="${1//./''}"
  ;;
  1840|3573|5357|7074|10136|14074 \
  |18100|21074|24915|28074|50313|50323) freq=$1
  ;;
  esac
}

function setBand() {
  case $1 in
    160m) freq=1840  ;;
    80m)  freq=3573  ;;
    60m)  freq=5357  ;;
    40m)  freq=7074  ;;
    30m)  freq=10136 ;;
    20m)  freq=14074 ;;
    17m)  freq=18100 ;;
    15m)  freq=21074 ;;
    12m)  freq=24915 ;;
    10m)  freq=28074 ;;
  esac
}

function showHelp() {
  echo 'USAGE: ft8vata.sh [ -h ] -f FREQ | -b BAND [ -v LEVEL ]'
  echo
  echo 'FT8 HF FREQ:'
  echo '1.840 3.573 5.357 7.074 10.136 14.074 18.100 '
  echo '21.074 24.915 28.074 50.313 50.323'
  echo
  echo 'FT8 HF BAND:'
  echo '160m 80m 60m 40m 30m 20m 17m 15m 12m 10m'
}

while getopts "hb:f:v:q" opt; do
  case "${opt}" in
    h) showHelp; exit ;;
    b) setBand "${OPTARG}"  ;;
    f) setFreq "${OPTARG}"  ;;
    v) logLevel="${OPTARG}" ;;
    q) logLevel=0 ;;
  esac
done

if [ -z ${freq} ]; then
  showHelp
  exit
fi

if [ "${logLevel}" -gt 0 ]; then
  echo "FREQ: ${freq} kHz"
fi

trap 'exit' SIGINT
trap 'rm record_?s.wav' EXIT

while :; do

  decisecUnixtime=0
  while (( ((decisecUnixtime % 600) % 150) < 140 )); do
    sleep 0.1
    decisecUnixtime="$(date -u '+%s%1N')"
  done

  unixtime=$(( (decisecUnixtime / 10) + 1 ))
  recFileName="record_$(( unixtime % 10 ))s.wav"

  arecord -q -r 12000 -f S16_LE -c 1 -d 14 ${recFileName}

  ( jt9 -8 -d 3 ${recFileName} 2>/dev/null \
    | awk -v unixtime=${unixtime} -v freq=${freq} \
    '($6 ~ /^R|^U[A-I]|^D[0-1]/) && ($7 ~ /^U[R-Z]|^E[M-O]|^D[0-1]/) {
     print  unixtime " " freq " " $0 }' >>ft8vata.txt 2>/dev/null ) &

done >/dev/null 2>&1

# EOF
