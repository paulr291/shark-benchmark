import os
import sys
import cluster_conf
import imp
import subprocess
import core_site

SPARK_EC2_VARS = cluster_conf.SPARK_EC2_VARS
ENV_VARS = cluster_conf.ENV_VARS
sparkEc2Path = '{0}/ec2'.format(SPARK_EC2_VARS['SPARK_HOME'])
sparkEc2Name = 'spark_ec2'
sys.path.append(sparkEc2Path + "/third_party/boto-2.4.1.zip/boto-2.4.1") 
(file, pathname, description) = imp.find_module(sparkEc2Name, [sparkEc2Path])
sparkEc2 = imp.load_module(sparkEc2Name, file, pathname, description)

for var in ENV_VARS:
  if ENV_VARS[var] != None:
    os.environ[var] = ENV_VARS[var]

import boto
from boto import ec2

def scpWithOpts(host, opts, local_file, remote_file, reverse=False, flags=''):
  command = "scp %s -q -o StrictHostKeyChecking=no -i %s '%s' '%s@%s:%s'" %\
    (flags, opts.identity_file, local_file, opts.user, host, remote_file)
  if reverse:
    command = "scp %s -q -o StrictHostKeyChecking=no -i %s '%s@%s:%s' '%s'" %\
      (flags, opts.identity_file, opts.user, host, remote_file, local_file)

  subprocess.check_call(command, shell=True)

def main():
  if len(sys.argv) != 3:
    print "Usage: python run [Git Spark Commit Hash] [Git Shark Commit Hash]"
    exit(1)

  benchmarkHome = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
  print benchmarkHome
  if os.getenv('AWS_ACCESS_KEY_ID') == None or os.getenv('AWS_SECRET_ACCESS_KEY') == None:
    print "Set AWS credentials"
    sys.exit(1)

  sparkHash = sys.argv[1]
  sharkHash = sys.argv[2]
  sparkEc2Args = "{0}/ec2/spark_ec2.py -k {1} -i {2} -s {3} -t {4} launch {5}".format(
    SPARK_EC2_VARS['SPARK_HOME'], SPARK_EC2_VARS['KEY_PAIR'], SPARK_EC2_VARS['KEY_FILE'],\
    SPARK_EC2_VARS['NUM_SLAVES'], SPARK_EC2_VARS['INSTANCE_TYPE'], SPARK_EC2_VARS['CLUSTER_NAME'])
  sys.argv = sparkEc2Args.split()
  print sparkEc2Args
  
  sparkEc2.main()

  (opts, action, cluster_name) = sparkEc2.parse_args()
  conn = ec2.connect_to_region(opts.region) #default region

  (master_nodes, slave_nodes, zoo_nodes) = sparkEc2.get_existing_cluster(
    conn, opts, SPARK_EC2_VARS['CLUSTER_NAME'])
  master = master_nodes[0].public_dns_name

  print "Updating copy-dir"
  scpWithOpts(master, opts, 'to_update/copy-dir', 'mesos-ec2/copy-dir') # ensure rsync has --delete

  # Add credentials to core-site.xml
  coreSiteFile = 'to_update/core-site.xml'
  print "Updating core-site.xml with credentials"
  scpWithOpts(master, opts, coreSiteFile, '~/ephemeral-hdfs/conf/core-site.xml', reverse=True)
  core_site.addCredentials(coreSiteFile)
  scpWithOpts(master, opts, coreSiteFile, '~/ephemeral-hdfs/conf/core-site.xml')
  print "Copying over shark-benchmark"

  scpWithOpts(master, opts, benchmarkHome, '~/shark-benchmark', flags='-r')
  print "Installing spark and shark on cluster"

  sparkEc2.ssh(master, opts, './shark-benchmark/install.rb %s %s' % (sparkHash, sharkHash))
  sparkEc2.ssh(master, opts, 'cd shark-benchmark; ./executeQueries.sh')

if __name__ == "__main__":
    main()
