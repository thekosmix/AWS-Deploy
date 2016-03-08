#!/bin/sh

# This script scans the given log files and if found the keywords to scan, mails to the concerned person
# I use to mail me the stacktrace of java exceptions
# below eample is for tomcat8 deployed on Elastic Beanstalk, but it can be modified to be used with other platforms as well

# this is what we will grep from the log file
exception="Exception" # "Error", "HTTP 1.1 \" 500", etc

# log file to scan 
logFileToScan=/var/log/tomcat8/catalina.out

# file where we will keep log of this script
logFilePath=/home/ec2-user/exception.log

# a file where we store till what line the log file has been scanned
# initalize it with 0 
countPath=/home/ec2-user/lineCount

# subject with which you want to receive the mail regading Exception
subject="[ALERT] Exception !!!"

# from whom do you want to send the mail regarding Exception
from="abc@xyz.com"

# to whom do you want to send the mail
to="dev@xyz.com,testers@xyz.com,admin@xyz.com"

# number of lines, before the line containing the word to be scanned, to be sent in the mail
linesBefore=1

# number of lines, before the line containing the word to be scanned, to be sent in the mail
linesAfter=4

# start line
fromLine=`cat $countPath`

# current line count in the file
toLine=`wc -l $logFileToScan | awk '{print $1}'`

#logs are rolling so if fromLine has a value greater than toLine then fromLine has to be set to 0
if [ "$fromLine" == "" ]; then
	fromLine=0
	echo `date` fromLine values was empty, set to 0 >> $logFilePath
elif [ $fromLine -gt $toLine ]; then
	echo `date` logfile was rolled, updating fromLine from $fromLine to 0 >> $logFilePath
	fromLine=0
fi

# if from n to lines are equal then no logs has been generated since last scan
if [ "$fromLine" == "$toLine" ]; then
	echo `date` no logs genetared after last scan >> $logFilePath
else
	echo `date` updating linecount to $toLine >> $logFilePath
	echo $toLine > $countPath
	
	logContent=`tail -n +"$fromLine" $logFileToScan | head -n "$((toLine - fromLine))" | grep -A $linesAfter -B $linesBefore $exception`
	
	if [ "$logContent" == "" ]; then
		echo `date` no exception found >> $logFilePath
	else
		/usr/sbin/sendmail $to <<EOF
subject: $subject
from: $from

logContent=$logContent

EOF
	fi
fi

