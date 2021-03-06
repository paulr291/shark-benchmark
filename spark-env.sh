#!/usr/bin/env bash

# Set Spark environment variables for your site in this file. Some useful
# variables to set are:
# - MESOS_NATIVE_LIBRARY, to point to your Mesos native library (libmesos.so)
# - SCALA_HOME, to point to your Scala installation
# - SPARK_CLASSPATH, to add elements to Spark's classpath
# - SPARK_JAVA_OPTS, to add JVM options
# - SPARK_MEM, to change the amount of memory used per node (this should
#   be in the same format as the JVM's -Xmx option, e.g. 300m or 1g).
# - SPARK_LIBRARY_PATH, to add extra search paths for native libraries.

export SCALA_HOME=/root/scala-2.9.2
export MESOS_NATIVE_LIBRARY=/usr/local/lib/libmesos.so

# Set Spark's memory per machine; note that you can also comment this out
# and have the master's SPARK_MEM variable get passed to the workers.
export SPARK_MEM=6154m

# Set JVM options and Spark Java properties
export SPARK_JAVA_OPTS="-Dspark.local.dir=/mnt"
