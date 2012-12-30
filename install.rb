#!/usr/bin/env ruby

if ARGV.size != 2
  $stderr.puts "Usage: ./install.rb [Git Spark Commit Hash] [Git Shark Commit Hash]"
  exit 1
end

# Download scala, spark, shark, and hive to home directory
# Assumes existence of ~/mesos-ec2 and shark-0.9 hive
Dir.chdir
if !File.exists?("scala-2.9.2")
  $stderr.puts "Downloading scala..."
  $stderr.puts `wget http://www.scala-lang.org/downloads/distrib/files/scala-2.9.2.tgz`
  $stderr.puts `tar xf scala-2.9.2.tgz`
end

# Clone the Git repository and create a branch for the hash
$stderr.puts "Downloading Spark..."
$stderr.puts `git clone git://github.com/mesos/spark.git` unless File.exists?("spark")
$stderr.puts "Building branch #{ARGV[0]}. This may take a while."
$stderr.puts `cd spark; git pull origin master; git reset --hard #{ARGV[0]};`
$stderr.puts `cp ~/shark-benchmark/spark-env.sh ~/spark/conf`
$stderr.puts `source ~/shark-benchmark/config.sh; cd spark; sbt/sbt clean publish-local`

$stderr.puts "Downloading Shark..."
$stderr.puts `git clone git://github.com/amplab/shark.git` unless File.exists?("shark")
$stderr.puts "Building branch #{ARGV[1]}. This may take a while."
$stderr.puts `cd shark; git pull origin master; git reset --hard #{ARGV[1]};`
$stderr.puts `cp ~/shark-benchmark/shark-env.sh ~/shark/conf`
$stderr.puts `echo $(curl http://169.254.169.254/latest/meta-data/public-ipv4) >> `~/shark/conf/shark-env.sh`
$stderr.puts `source ~/shark-benchmark/config.sh; cd shark; sbt/sbt products`

$stderr.puts `mesos-ec2/copy-dir spark`
$stderr.puts `mesos-ec2/copy-dir shark`
$stderr.puts `mesos-ec2/copy-dir hive`

# Copy data from s3
$stderr.puts `ephemeral-hdfs/bin/start-mapred.sh`
$stderr.puts "Copying tpch10g"
$stderr.puts `ephemeral-hdfs/bin/hadoop distcp s3n://tpch-data/tpch10g /tpch10g`
