#/bin/bash
counter=0
while true; do
  time $*
  ((counter++))
  echo "Executed $counter times"
done
