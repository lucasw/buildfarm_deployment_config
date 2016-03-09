#!/bin/bash

set -o errexit

BUILDFARM_DEPLOYMENT_PATH=/root/buildfarm_deployment
BUILDFARM_DEPLOYMENT_URL=https://github.com/ros-infrastructure/buildfarm_deployment.git
BUILDFARM_DEPLOYMENT_BRANCH=master

if [ ! -d $1 ]; then
  echo "$1 is not a valid subdirectory"
  return 1
fi

echo "Running puppet"
puppet apply -v $BUILDFARM_DEPLOYMENT_PATH/$1/manifests/site.pp --modulepath=$BUILDFARM_DEPLOYMENT_PATH/$1:$BUILDFARM_DEPLOYMENT_PATH/$1/modules -l /var/log/puppet.log || { r=$?; echo "puppet failed, please check /var/log/puppet.log, the last 10 lines are:"; tail -n 10 /var/log/puppet.log; exit $r; }
