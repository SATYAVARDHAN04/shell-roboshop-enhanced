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
app_name=redis

source ./common.sh
check_root
Validate

dnf module disable redis -y &>> $LOG_FILE
Validate $? "Disabiling Redis"

dnf module enable redis:7 -y &>> $LOG_FILE
Validate $? "Enabling Redis module"

dnf install redis -y  &>> $LOG_FILE
Validate $? "Installing redis module"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
Validate $? "Changing the local host"

sed -i '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
Validate $? "Changing the local host"

systemctl enable redis  &>> $LOG_FILE
Validate $? "redis enabled"

systemctl start redis  &>> $LOG_FILE
Validate $? "Redis server started" 