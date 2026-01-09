#! /bin/bash

USERID=$(id -u)
red="\e[31m"
green="\e[32m"
reset="\e[0m"
LOGS_FOLDER="/var/logs/roboshop-log"
SCRIPT_NAME=$(echo $0|cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p ${LOGS_FOLDER}
app_name=catalogue

source ./common.sh
check_root
Node_js_installation
Create_user
Code_dependencies
Systemctl_commands

cp $SCRIPT_DIR/mongodb.repo /etc/yum.repos.d/mongo.repo
Validate $? "mongodb repo copied"

dnf install mongodb-mongosh -y &>> $LOG_FILE
Validate $? "Installing Mongodb client"

STATUS=$(mongosh --host mongodb.satyology.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.satyology.site </app/db/master-data.js &>>$LOG_FILE
    Validate $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... SKIPPING"
fi