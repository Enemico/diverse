#!/bin/bash
## script to create a marathon slave 


MASTER=$1
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
APTKEY=$(which apt-key)
APTGET=$(which apt-get)
SYSTEMCTL=$(which systemctl)
ADDRESS=$(ip addr | grep -Po '(?!(inet 127.\d.\d.1))(inet \K(\d{1,3}\.){3}\d{1,3})')
CURL=$(which curl)
ADDAPT=$(which add-apt-repository)

## sanity check we have the master argument
if [ -z $1 ]; then
  echo "Provide the master ip as an argument, pretty please?"
  exit 1
fi

## first add the key
$APTKEY adv --keyserver keyserver.ubuntu.com --recv E56151BF
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list

## then, update repo and install mesos
$APTGET update
$APTGET -y install mesos
if [ $? -ne "0" ]; then
  echo "error" 
  exit 1
fi

## add information about the master into the mesos configuration
echo "zk://$MASTER:2181/mesos" > /etc/mesos/zk

## stop zookeeper, set override to manual, disable autostart
$SYSTEMCTL stop zookeeper
echo manual | tee /etc/init/zookeeper.override
$SYSTEMCTL disable zookeeper

## same shit for mesos-master
$SYSTEMCTL stop mesos-master
echo manual | sudo tee /etc/init/mesos-master.override
$SYSTEMCTL disable mesos-master

## add ip address to mesos-slave configuration
echo $ADDRESS | tee /etc/mesos-slave/ip
cp /etc/mesos-slave/ip /etc/mesos-slave/hostname

## start mesos-slave
$SYSTEMCTL start mesos-slave
$SYSTEMCTL enable mesos-slave

## install docker-ce! 

## first we need tools to do it
$APTGET -y install apt-transport-https ca-certificates curl software-properties-common

## download the key
$CURL -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

## add the repository
$ADDAPT "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

## update repositories, install package
$APTGET update
$APTGET -y install docker-ce

## add docker to mesos configuration
echo 'docker,mesos' > /etc/mesos-slave/containerizers
echo '10mins' > /etc/mesos-slave/executor_registration_timeout

## restart mesos
$SYSTEMCTL restart mesos-slave





