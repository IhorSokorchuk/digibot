#! /bin/bash

# ft8vata.sh - FT8 skimmer, version 2022.02.17-1 beta
# Copyright (C) 2022, Ihor Sokorchuk, UR3LCM <ur3lcm@gmail.com>
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
# This is free software; you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

# FT8 FREQ:
# 1.840 3.573 5.357 7.074 10.136 14.074 18.100 
# 21.074 24.915 28.074 50.313 50.323

trap 'exit' SIGINT
trap 'rm tmp-??.wav' EXIT

while :; do

  utcLabel=0
  while (( ((utcLabel % 1000) % 150) < 147 )); do
    utcLabel="$(date -u '+%y%m%d%H%M%S%1N')"
    sleep 0.1
  done

  recFile="tmp-${utcLabel:10:2}.wav"

  arecord -q -r 12000 -f S16_LE -c 1 -d 14 ${recFile}

  ( jt9 -8 -d 3 ${recFile} 2>/dev/null | awk -v utc=${utcLabel:0:12} \
    '($6 ~ /^R|^U[A-I]|^D[0-1]/) && ($7 ~ /^U[R-Z]|^E[M-O]|^D[0-1]/) {
     print utc " " $0 }' >>ft8vata.txt 2>/dev/null ) &

done >/dev/null 2>&1

# EOF
