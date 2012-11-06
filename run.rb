#!/usr/bin/env ruby

if ARGV.size != 2
  $stderr.puts "Usage: ./run [Git Spark Commit Hash] [Git Shark Commit Hash]"
  exit 1
end

$stderr.puts `./install.rb #{ARGV[0]} #{ARGV[1]}`
$stderr.puts `./executeQueries.sh`
