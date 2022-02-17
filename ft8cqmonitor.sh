#! /bin/bash

tail -f decoded.txt 2>/dev/null \
  | awk '($7 == "CQ") {print}'
