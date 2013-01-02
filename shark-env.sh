#!/usr/bin/env bash

# (Required) Amount of memory used per slave node. This should be in the same
# format as the JVM's -Xmx option, e.g. 300m or 1g.
export SPARK_MEM=5g

# (Required) Set the master program's memory
export SHARK_MASTER_MEM=5g

# (Required) Point to your Scala installation.
export SCALA_HOME=/root/scala-2.9.2

# (Required) Point to the patched Hive binary distribution
export HIVE_HOME=/root/hive-0.9.0-bin

# (Optional) Specify the location of Hive's configuration directory. By default,
# it points to $HIVE_HOME/conf
# export HIVE_CONF_DIR="$HIVE_HOME/conf"

# For running Shark in distributed mode, set the following:
export HADOOP_HOME=/root/hadoop-mesos
export SPARK_HOME=/root/spark
export MASTER=`cat /root/mesos-ec2/cluster-url`
export MESOS_NATIVE_LIBRARY=/usr/local/lib/libmesos.so

# (Optional) Extra classpath
#export SPARK_LIBRARY_PATH=""

# Java options
# On EC2, change the local.dir to /mnt/tmp
SPARK_JAVA_OPTS="-Dspark.local.dir=/mnt/tmp "
SPARK_JAVA_OPTS+="-Dspark.kryoserializer.buffer.mb=10 "
SPARK_JAVA_OPTS+="-verbose:gc -XX:-PrintGCDetails -XX:+PrintGCTimeStamps "
export SPARK_JAVA_OPTS
