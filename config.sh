#!/usr/bin/env bash

# Run configurations
# --------------------------------------------------
export SHARK_HOME=~/shark

# Log of Shark output
export BENCHMARK_LOG=benchmark.log

# Directory with queries to execute
export QUERIES_DIR=queries

# Full query file created by concatenating queries in the directory of queries
export ALL_QUERY=allQuery.hive


# Shark configurations
# --------------------------------------------------
# (Required) Amount of memory used per slave node. This should be in the same
# format as the JVM's -Xmx option, e.g. 300m or 1g.
export SPARK_MEM=5g

# (Required) Set the master program's memory
export SHARK_MASTER_MEM=5g

# (Required) Point to your Scala installation.
export SCALA_HOME="~/scala-2.9.2"

# (Required) Point to the patched Hive binary distribution
export HIVE_HOME="~/hive/build/dist"

# (Optional) Specify the location of Hive's configuration directory. By default,
# it points to $HIVE_HOME/conf
#export HIVE_CONF_DIR="$HIVE_HOME/conf"

# For running Shark in distributed mode, set the following:
export HADOOP_HOME="~/hadoop-mesos"
export SPARK_HOME="~/spark"
export MASTER=""
export MESOS_NATIVE_LIBRARY=/usr/local/lib/libmesos.so

# (Optional) Extra classpath
#export SPARK_LIBRARY_PATH=""

# Java options
# On EC2, change the local.dir to /mnt/tmp
SPARK_JAVA_OPTS="-Dspark.local.dir=/mnt/tmp "
SPARK_JAVA_OPTS+="-Dspark.kryoserializer.buffer.mb=10 "
SPARK_JAVA_OPTS+="-verbose:gc -XX:-PrintGCDetails -XX:+PrintGCTimeStamps "
export SPARK_JAVA_OPTS

