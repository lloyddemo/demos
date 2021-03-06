#!/bin/bash

## setup ssh keys
if [ ! -e ~/.ssh/id_rsa.pub ];
then
   ## generating a ssh key
   echo "Generating an rsa ssh key, please hit enter twice"
   ssh-keygen -t rsa
fi

PUB_KEY=$(cat ~/.ssh/id_rsa.pub)
if [ $(grep -e "${PUB_KEY}" ~/.ssh/authorized_keys | wc -l) -eq 0 ];
then
   echo "Adding ssh key to your authorized_keys file for demo"
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
   echo yes | ssh localhost
   exit
fi

echo "Downloading latest LTS jenkins"
curl -s -L -O http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war

## if you prefer living on the bleeding edge
##echo "Downloading latest jenkins"
##curl -s -L -O http://mirrors.jenkins-ci.org/war/latest/jenkins.war

## grab plugins
PLUGINS="github-api github git-client scm-api git ghprb greenballs token-macro email-ext postbuildscript dashboard-view"

for PLUGIN in ${PLUGINS}
do
   echo "Downloading plugin ${PLUGIN}"
   curl -s -L -O http://updates.jenkins-ci.org/latest/${PLUGIN}.hpi
done

for TYPE in master slave
do
   if [ ! -d "${TYPE}/jenkins" ];
   then
      echo "mkdir ${TYPE}/jenkins"
      mkdir ${TYPE}/jenkins
   fi
   if [ "${TYPE}" == "master" ];
   then
      echo "Moving installation files to master/jenkins"
      mv *.hpi jenkins.war master/jenkins
      cp cfg/.bashrc master/jenkins
   fi
done
