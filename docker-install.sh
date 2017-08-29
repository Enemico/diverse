#!/bin/bash


## sequence to install docker on centos 7
sudo yum update -y
sudo yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
sudo yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
sudo yum-config-manager --enable docker-ce-edge
sudo yum makecache fast
sudo yum install -y docker-ce ntp bind-utils
sudo systemctl enable docker 
sudo systemctl start docker
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo setenforce 0 
