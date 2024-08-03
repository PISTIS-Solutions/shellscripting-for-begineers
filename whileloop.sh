#!/bin/bash
x=3
while [ $x -le 6 ]
do
  echo "Welcome $x times"
  x=$(( $x + 1 ))
done