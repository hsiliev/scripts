#/bin/bash -e
counter=0
while time $*; do
  (( counter++ ))
  echo "Executed $counter times"
done

echo "Failed after $counter executions"
