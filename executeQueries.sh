#!/bin/bash
source config.sh
queryFiles=(`ls $QUERIES_DIR`)

# Empty log file and query file
echo "" > $BENCHMARK_LOG
echo "" > $ALL_QUERY

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

  # Delimiter for start of actual query.
  echo "" >> $ALL_QUERY
  echo "; -- start timing queries for $queryFile " >> $ALL_QUERY
  # Append the actual query 10 times 
  for i in {1..2}
  do
    #echo "; -- Iteration "$i >> $ALL_QUERY
    cat $QUERIES_DIR/$queryFile >> $ALL_QUERY
  done
  # Delimiter for end of query
  echo ";--stop timing queries for $queryFile" >> $ALL_QUERY
  echo "SHOW TABLES;" >> $ALL_QUERY
done


# Execute queries
echo "Executing $ALL_QUERY" | tee -a $BENCHMARK_LOG
$SHARK_HOME/bin/shark-withinfo -f $ALL_QUERY 2>&1 | tee -a $BENCHMARK_LOG 
# Extract times
actualQuery=false
while read line; do
  if [[ "$line" == *start\ timing* ]] && [[ "$actualQuery" == "false" ]] ; then
    echo $line
    actualQuery=true
  elif [[ "$line" == *stop\ timing* ]] && $actualQuery ; then
    echo $line
    actualQuery=false
  fi
  
  if $actualQuery ; then
    if [[ "$line" == Time\ taken* ]] ; then
      echo $line
    elif [[ "$line" == *--\ Iteration* ]]; then
      echo $line
    fi
  fi
done < $BENCHMARK_LOG

echo "Check $BENCHMARK_LOG for errors."
