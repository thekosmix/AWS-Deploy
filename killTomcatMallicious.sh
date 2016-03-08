#!/bin/sh

logFilePath=/home/ec2-user/malicious.log
subject="[ALERT] Malicious Content !!!"
# email from which you want to send the malicious report
from="abc@xyz.com" 
# emailIds to which you want to send the malicious reports
to="dev@xyz.com,admin@xyz.com,tester@xyz.com"

#invoke every 10 seconds
for i in 1 2 3 4 5 6
do
	#malicious process cretaed by tomcat except java (main tomcat server)
	maliciousProcess=`ps aux | grep tomcat | grep -v JAVA_HOME | grep -v java | grep -v tomcat-elasticbeanstalk | grep -v root | grep -v build-classpath | grep -v tail | grep -v grep`
	
	if [ "$maliciousProcess" == "" ]; then
		echo `date` no malicious process found >> $logFilePath
	else
		kill -9 $(ps aux | grep tomcat | grep -v java | grep -v grep | awk '{print $2}')
		cd /tmp
		
		#list all files and directory with / appended to the directories, remove directories & total word, and then grep files created by tomcta from list, 
		maliciousFiles=`ls -lpa | grep -v / | grep -v total | grep tomcat`
		if [ "$maliciousFiles" != "" ]; then
			rm $(ls -lpa | grep -v / | grep -v total | grep tomcat | awk '{print $9}')
		fi

                /usr/sbin/sendmail $to <<EOF
subject: $subject
from: $from

maliciousProcess=$maliciousProcess
maliciousFiles=$maliciousFiles

EOF
	fi

	if [ "$i" != "6" ]; then
		sleep 10
	fi

done

