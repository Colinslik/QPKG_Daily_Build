#!/bin/bash
mytime=$(date "+%Y%m%d%H%M.%S")
find . -print0 -path ./Kernel -prune -o -type f ! -name '*.c' | xargs -0 touch -t $mytime
echo "touch -t $mytime"
