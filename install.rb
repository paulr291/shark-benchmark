#!/usr/bin/env ruby

if ARGV.size != 2
  $stderr.puts "Usage: ./install [Git Spark Commit Hash] [Git Shark Commit Hash]"
  exit 1
end

# Download scala, spark, shark, and hive to home directory
# Assumes existence of ~/mesos-ec2, shark-0.9 hive, and scala-2.9.2
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
$stderr.puts `cd spark; git checkout -b #{ARGV[0]} #{ARGV[0]};`
$stderr.puts `source ~/shark-benchmark/config.sh; cd spark; sbt/sbt clean publish-local`
$stderr.puts `cp ~/shark-benchmark/spark-env.sh ~/spark/conf`

$stderr.puts "Setting up hive(shark-0.9)"
$stderr.puts `yum -y install ant-antlr.noarch` # necessary on the EC2 instances
$stderr.puts `git clone https://github.com/amplab/hive.git` unless File.exists?("hive")
$stderr.puts `cd hive; git checkout shark-0.9; ant package`

$stderr.puts "Downloading Shark..."
$stderr.puts `git clone git://github.com/amplab/shark.git` unless File.exists?("shark")
$stderr.puts "Building branch #{ARGV[1]}. This may take a while."
$stderr.puts `source ~/shark-benchmark/config.sh; cd shark; git checkout -b #{ARGV[1]} #{ARGV[1]}; sbt/sbt products`
$stderr.puts `cp ~/shark-benchmark/shark-env.sh ~/shark/conf`

$stderr.puts `mesos-ec2/copy-dir spark`
$stderr.puts `mesos-ec2/copy-dir shark`
$stderr.puts `mesos-ec2/copy-dir hive`

# Copy data from s3
$stderr.puts `ephemeral-hdfs/bin/start-mapred.sh`
$stderr.puts "Copying tpch10g"
$stderr.puts `ephemeral-hdfs/bin/hadoop distcp s3n://tpch-data/tpch10g /tpch10g`
