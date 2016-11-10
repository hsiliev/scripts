#/bin/bash -e
counter=0
while $*; do
  (( counter++ ))
  echo "Executed $counter times"
done

echo "Failed after $counter executions"
