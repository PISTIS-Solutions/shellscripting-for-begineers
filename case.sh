#!/bin/bash

echo "Enter a number (1-4): "
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
  4)
    echo "You entered 4"
    ;;
  *)
    echo "Invalid number"
    ;;
esac
