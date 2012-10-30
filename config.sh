#!/usr/bin/env bash

# Run configurations
# --------------------------------------------------
# Log of Shark output
export BENCHMARK_LOG="benchmark.log"

# Directory with queries to execute
export QUERIES_DIR="tpch_q1"

# Full query file created by concatenating queries in the directory of queries
export ALL_QUERY="allQuery.hive"

export SHARK_HOME=/root/shark
export SCALA_HOME=/root/scala-2.9.2
export HIVE_HOME=/root/hive/build/dist
export SPARK_HOME=/root/spark

