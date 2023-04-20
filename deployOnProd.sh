#!/bin/sh

# this script is for tomcat/war deployment, but can be used for other platfroms too with slight modifications (or no modifications)
# This script helps you to deploy a war file from your test environment to your prod environment

# adding date to war filename to identify when was this war deployed 
# (some of you might say not needed, but I have an OCD of putting timestamp in almost everything 2016-03-08_11:56 IST :D )
myDate=`date +%Y-%m-%d_%H%M`
warName=$myDate"_ROOT.war"

# versionaLabel: what changes are you deploying in this build (try to keep it short)
# eg: "image_path_fixed" "user_profile_functionality_added", etc
versionLabel="$1"
if [ "$versionLabel" == "" ]; then
        echo "please_mention_a_comment_for_this_build_in_the_same_format_without_any_space"
        exit;
fi

case "$versionLabel" in
    *[[:space:]]*)
        echo "comment shouldn't contains any space" >&2
        exit 1
        ;;
esac

# the s3 bucket associated to your elastic beanstalk environment, where all the versions of builds are stored
# you can find it from S3 console, it will start with the name as below
s3=elasticbeanstalk-ap-southeast-1-012345678910 # 12-digit identifier (it may vary)

#appName=strollup-env
appName=my-first-college-project

#environment-name
environmentName=my-first-elastic-beanstalkapp

# Auto-Scaling Group Name, you can find it in Auto Scaling Groups tab of EC2's dashboard
# get the name of ASG (Auto Scaling Group: awseb-e-xxxxxxxxxx-stack-AWSEBAutoScalingGroup-XXXXXXXXXXXXX)
asgName=awseb-e-xxxxxxxxxx-stack-AWSEBAutoScalingGroup-XXXXXXXXXXXXX

# prod profile with which you have setup the AWS CLI
# aws configure --profile=prod
profile=prod

# copy war/build file from test's folder to S3 bucket
echo `date` copying $warName to s3 bucket
aws s3 cp /var/lib/tomcat7/webapps/ROOT.war s3://$s3/$warName --profile=$profile

# first Elaastic Beanstalk needs to create the environment
# you can see that in Elastic Beanstalk's Application version tab
echo `date` creating environment
aws elasticbeanstalk create-application-version --application-name $appName --version-label $versionLabel --source-bundle S3Bucket=$s3,S3Key=$warName --profile=$profile

# now update/deploy to your Elastic Beanstalk environment
echo `date` updating environment
aws elasticbeanstalk update-environment --environment-name $environmentName --version-label $versionLabel --profile=$profile

echo `date` done...

