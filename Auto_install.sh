#!/bin/bash

Daily_Build_path=/share/Qpkg_Daily/

NOW=$(date +%m%d)

Date=$(date +%Y_%m_%d)

model_name=x86

except_name=ce

# Change director to today's daily build folder

cd $Daily_Build_path$Date

file=$(ls | grep $model_name | grep -v $except_name)

if [ "$file" ]; then
  chmod 755 $file
  sh $file
else
  echo "file not found!"
fi
