#!/bin/bash
source config.sh
queryFiles=(`ls $QUERIES_DIR | sort`)

# Empty result file, log file and query file
cat /dev/null > $RESULTS
cat /dev/null > $BENCHMARK_LOG
cat /dev/null > $ALL_QUERY

# Generate query file
if [ -f $QUERIES_DIR"/setup.hive" ]; then
  cat $QUERIES_DIR"/setup.hive" >> $ALL_QUERY
fi

for queryFile in ${queryFiles[@]}
do
  if [[ "$queryFile" == "setup.hive" ]]; then 
    continue
  fi

  if [[ "$queryFile" ==  *_setup ]]; then
    continue
  fi

  if [ ! -f $QUERIES_DIR/$queryFile ]; then
    echo "$queryFile not found" | tee -a $BENCHMARK_LOG
    continue
  fi

  # If setup queries exist, add them to the query file first.
  setupFile=$QUERIES_DIR/$queryFile"_setup"
  echo $queryFile
  echo $setupFile
  if [ -f $setupFile ]
  then
    cat $setupFile >> $ALL_QUERY
  fi

  numQueries=`grep -c ";$" $QUERIES_DIR/$queryFile`
  # Delimiter for start of actual query.
  echo "" >> $ALL_QUERY
  echo "; -- start timing $queryFile $numQueries" >> $ALL_QUERY
  # Append the actual query 10 times 
  for (( i=0; i<ITERATIONS; i++ ))
  do
    cat $QUERIES_DIR/$queryFile >> $ALL_QUERY
  done
  # Delimiter for end of query
  echo "; -- stop timing $queryFile" >> $ALL_QUERY
  echo "SHOW TABLES;" >> $ALL_QUERY
done


# Execute queries
echo "Executing $ALL_QUERY" | tee -a $BENCHMARK_LOG
/root/shark/bin/shark-withinfo -f $ALL_QUERY 2>&1 | tee -a $BENCHMARK_LOG 
# Extract times
actualQuery=false
while read line; do
  if [[ "$line" == *start\ timing* ]] && [[ "$actualQuery" == "false" ]] ; then
    echo $line
    words=($line)
    curQuery=${words[3]}
    numQueries=${line##*\ }
    iteration=0
    queryNum=0
    actualQuery=true
  elif [[ "$line" == *stop\ timing* ]] && $actualQuery ; then
    echo $line
    actualQuery=false
  fi
  
  if $actualQuery ; then
    if [[ "$line" == Time\ taken* ]] || [[ "$line" == FAILED:* ]]; then
      echo "Iteration "$iteration" "$line
      words=($line)
      seconds=${words[2]}
      echo $curQuery","$iteration","$seconds >> $RESULTS
      (( queryNum++ ))
      if [ $queryNum -eq $numQueries ] ; then
        (( iteration++ ))
        queryNum=0
      fi
    fi
  fi
done < $BENCHMARK_LOG

echo "Check $BENCHMARK_LOG for full output."
