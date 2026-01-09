#! /bin/bash

USERID=$(id -u)
red="\e[31m"
green="\e[32m"
reset="\e[0m"
LOGS_FOLDER="/var/logs/roboshop-log"
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p ${LOGS_FOLDER}
app_name=mongodb

source ./common.sh

check_root

cp mongodb.repo /etc/yum.repos.d/mongodb.repo &>> $LOG_FILE
Validate $? "Copying of repo folder"

dnf install mongodb-org -y &>> $LOG_FILE
Validate $? "mongodb installation"

systemctl enable mongod &>> $LOG_FILE
Validate $? "mongodb enabled"

systemctl start mongod &>> $LOG_FILE
Validate $? "mongodb server started" 

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
Validate $? "Configuration changed"

systemctl restart mongod &>> $LOG_FILE
Validate $? "mongodb server restarted"
