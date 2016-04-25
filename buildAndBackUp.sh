#!/bin/sh

#this script is sort of replacement of CI tools like jenkins/hudson for tomcat
#Jenkins/Hudson requires huge amount of RAM and with only 1GB RAM on t2.micro instances, it's nearly impossible to run
#Huson and also your webapp
#It works with only Git repo (but you can change it to work with svn as well) and requires to be run as root

#Prerequsites
#1. Git and maven installed
#2. Familiarity with git and mvn commands

#Steps:
#1. create a directory named war_backup in home (/home/ubuntu/war_backup)
#2. checkout your git project in folder named skyfall (/home/ubuntu/skyfall)


#stop tomcat as running mvn will consume lot of memory
service tomcat7 stop
# remove ROOT directory and copy exiting war to backup folder
# backups will be strored with timestamp
myDate=`date +%Y-%m-%d-%H-%M-%S`
rm -rf /var/lib/tomcat7/webapps/ROOT/
mv /var/lib/tomcat7/webapps/ROOT.war /home/ubuntu/war_backup/$myDate

#goto git root folder
cd /home/ubuntu/skyfall
#run git commands and fetch the latest versions
#you can change it to svn also
#running these commands will ask for password, you can cache it or 
#you can type the password, everytime you are going to build
git stash
git fetch
git rebase origin/master

#now go where pom.xml is present (in my case, it's root) and run maven install and 
#copy the generated war to webapp directory
cd /home/ubuntu/skyfall/root
mvn clean install
cp /home/ubuntu/skyfall/root/target/ROOT.war /var/lib/tomcat7/webapps/

#start tomcat
service tomcat7 start

