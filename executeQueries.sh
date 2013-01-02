#!/bin/bash
source config.sh
rm -rf tempQueries
cp -r $QUERIES_DIR tempQueries
QUERIES_DIR=tempQueries
queryFiles=(`ls $QUERIES_DIR | sort`)

# Set up result file and log files
cat /dev/null > $RESULTS
cat /dev/null > $BENCHMARK_LOG
cat /dev/null > temp.log
echo "query name,iteration number,seconds" > $RESULTS

queryFiles=( ${queryFiles[@]/setup.hive/} )
queryFiles=( ${queryFiles[@]/*_setup/} )

while [ ${#queryFiles[@]} -gt 0 ]
do
  # Generate query file
  cat /dev/null > $ALL_QUERY
  if [ -f $QUERIES_DIR"/setup.hive" ]; then
    cat $QUERIES_DIR"/setup.hive" >> $ALL_QUERY
  fi

  for queryFile in ${queryFiles[@]}
  do
    if [ ! -f $QUERIES_DIR/$queryFile ]; then
      echo "$queryFile not found" | tee -a $BENCHMARK_LOG
      continue
    fi

    # Marks beginning of executing a query file
    echo "; -- start executing: $queryFile" >> $ALL_QUERY
    echo "SHOW TABLES;" >> $ALL_QUERY

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
    # Append the actual query ITERATIONS times 
    for (( i=0; i<ITERATIONS; i++ ))
    do
      cat $QUERIES_DIR/$queryFile >> $ALL_QUERY
    done
    # Delimiter for end of query
    echo "; -- stop timing $queryFile" >> $ALL_QUERY
    echo "SHOW TABLES;" >> $ALL_QUERY
  done


  # Execute queries
  echo "Executing $ALL_QUERY" | tee -a temp.log
  /root/shark/bin/shark-withinfo -f $ALL_QUERY 2>&1 | tee -a temp.log
  
  unset queryFiles[0] # ensure removal of the first query if setup query fails
  queryFiles=("${queryFiles[@]}")

  # Extract times
  actualQuery=false
  while read line; do
    if [[ "$line" == *start\ executing* ]] ; then
      words=($line)
      curQuery=${words[3]}
      queryFiles=( ${queryFiles[@]/$curQuery/} )
    elif [[ "$line" == *start\ timing* ]] && [[ "$actualQuery" == "false" ]] ; then
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
      if [[ "$line" == Time\ taken* ]]; then
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
  done < temp.log
  cat temp.log >> $BENCHMARK_LOG
  cat /dev/null > temp.log
done

cat $RESULTS
echo "Check $BENCHMARK_LOG for full output."
