#!/bin/bash

set -o errexit

BUILDFARM_DEPLOYMENT_PATH=/root/buildfarm_deployment
BUILDFARM_DEPLOYMENT_URL=https://github.com/ros-infrastructure/buildfarm_deployment.git
BUILDFARM_DEPLOYMENT_BRANCH=master

if [ ! -d $1 ]; then
  echo "$1 is not a valid subdirectory"
  return 1
fi

if [ ! -d /root/buildfarm_deployment ]; then
  echo "########################"
  echo "/root/buildfarm_deplyment did not exist, cloning."
  git clone $BUILDFARM_DEPLOYMENT_URL /root/buildfarm_deployment -b $BUILDFARM_DEPLOYMENT_BRANCH
fi

echo "########################"
echo "Copying in configuration"
mkdir -p /etc/puppet/hieradata
cp $1/hiera.yaml /etc/puppet
cp $1/common.yaml /etc/puppet/hieradata

echo "########################"
echo "Asserting latest version of $BUILDFARM_DEPLOYMENT_URL as $BUILDFARM_DEPLOYMENT_BRANCH"
cd $BUILDFARM_DEPLOYMENT_PATH && git fetch origin && git reset --hard origin/$BUILDFARM_DEPLOYMENT_BRANCH
echo "########################"
echo "Running librarian-puppet"
(cd $BUILDFARM_DEPLOYMENT_PATH/$1 && librarian-puppet install --verbose)
echo "########################"

echo "Running puppet"
puppet apply -v $BUILDFARM_DEPLOYMENT_PATH/$1/manifests/site.pp --modulepath=$BUILDFARM_DEPLOYMENT_PATH/$1:$BUILDFARM_DEPLOYMENT_PATH/$1/modules -l /var/log/puppet.log || { r=$?; echo "puppet failed, please check /var/log/puppet.log, the last 10 lines are:"; tail -n 10 /var/log/puppet.log; exit $r; }
echo "Finished"
#echo "Finished, run ./reconfigure_finish.bash $1 next"
