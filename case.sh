#!/bin/bash

echo "Enter a number (1-3): "
read number

case $number in
  1)
    echo "You entered 1"
    ;;
  2)
    echo "You entered 2"
    ;;
  3)
    echo "You entered 3"
    ;;
  *)
    echo "Invalid number"
    ;;
esac
