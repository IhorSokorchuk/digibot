#! /bin/bash

# Copyright (C)2022 Ihor Sokorchuk, UR3LCM
# ft8vata.sh - FT8 skimmer, version 2022.02.17 beta

# FT8 FREQ:
# 1.840 3.573 5.357 7.074 10.136 14.074 18.100 
# 21.074 24.915 28.074 50.313 50.323

trap 'exit' SIGINT
trap 'rm out-??.wav' EXIT

while :; do
  while (( (`date +10#%S%1N` % 150) < 140 )); do
    sleep 0.1
  done
  #outFile="out-$(date '+%Y%m%d%H%M%S').wav"
  outFile="out-$(date '+%S').wav"
  arecord -q -r 12000 -f S16_LE -c 1 -d 14 ${outFile}
  (jt9 -8 -d 3 "${outFile}" 2>/dev/null \
    | awk '($6 ~ /^R|^U[A-I]|^D[0-1]/) && ($7 ~ /^U[R-Z]/) {print}'\
      >>ft8vata.txt) &
done >/dev/null 2>&1
